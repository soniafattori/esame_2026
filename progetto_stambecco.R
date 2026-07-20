# 1. INSTALLAZIONE PACCHETTI E CARICAMENTO LIBRERIE

install.packages("terra")                 # Gestione dei dati raster geografici
install.packages("tidyterra")             # Integrazione nativa di oggetti SpatRaster in ggplot2
install.packages("ggplot2")               # Visualizzazione grafica avanzata e la mappatura
install.packages("viridis")               # Palette di colori per l'accessibilità visiva
install_github("ducciorocchini/imageRy")  # Repository di dati e funzioni del corso

library(terra)
library(tidyterra)
library(ggplot2)
library(viridis)
library(imageRy)

# 2. IMPORTAZIONE DEI DATI SATELITARI STAGIONALI (SENTINEL-2 - Passo Falzarego) 
# Visualizziamo la lista dei dataset interni disponibili nel pacchetto

im.list()

# Importiamo i file raster (mappe) dell'NDVI del 2020 relativi al Passo Falzarego (Dolomiti). 
# Ogni file rappresenta un indice spettrale pre-calcolato in una specifica stagione.

ndvi_feb <- im.import("Sentinel2_NDVI_2020-02-21.tif") # Mappa invernale (presenza di neve/dormienza)
ndvi_mag <- im.import("Sentinel2_NDVI_2020-05-21.tif") # Mappa primaverile (fase di "greening" o risveglio)
ndvi_ago <- im.import("Sentinel2_NDVI_2020-08-01.tif") # Mappa estiva (picco di biomassa / stress idrico)
ndvi_nov <- im.import("Sentinel2_NDVI_2020-11-27.tif") # Mappa autunnale (senescenza / dormienza)

# Creiamo un "RasterStack" concatenando i singoli layer con la funzione c() di terra. 
# Lo stack permette di manipolare e visualizzare i dataset multitemporali in modo sincrono.

punti_stagionali <- c(ndvi_feb, ndvi_mag, ndvi_ago, ndvi_nov)

# Rinominiamo i layer dello stack per garantire la leggibilità dei plot successivi

names(punti_stagionali) <- c("Febbraio", "Maggio", "Agosto", "Novembre")

# Visualizzazione della serie temporale completa con palette viridis standard (100 sfumature)

plot(punti_stagionali, col=viridis(100))   # 01_serie_stagionale.png

# 3. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (CAMBIAMENTO ESTIVO) 
# Applichiamo un'operazione di algebra dei raster sottraendo il pixel primaverile da quello estivo. 
# Obiettivo: Evidenziare quantitativamente il viraggio o il disseccamento del pascolo.

diff_estate_primavera <- ndvi_ago - ndvi_mag

# Plottiamo la differenza per vedere dove la vegetazione è aumentata o diminuita: I valori negativi indicano una perdita di vigoria vegetativa (NDVI diminuito da Maggio ad Agosto)
# Usiamo una mappa di colore divergente (magma) per evidenziare i contrasti

plot(diff_estate_primavera, col=magma(100), 
     main="Variazione dell'NDVI (Agosto vs Maggio)")   # 02_differenza_ndvi.png

# 4. ANALISI DELLA DISTRIBUZIONE SPETTRALE TRAMITE ISTOGRAMMI
# Generiamo un pannello con due istogrammi per osservare lo shift matematico dei pixel

im.multiframe(1, 2)
hist(ndvi_mag, main = "Distribuzione NDVI Maggio", col = "darkgreen", xlab = "Valori NDVI", ylim = c(0, 65000)) # Blocca il limite da 0 a 65.000
hist(ndvi_ago, main = "Distribuzione NDVI Agosto", col = "orange", xlab = "Valori NDVI", ylim = c(0, 65000)) # Blocca il limite da 0 a 65.000     # 04_istogrammi_confronto.png

# Reset del pannello grafico

dev.off()

# 5. RICLASSIFICAZIONE E CALCOLO DELLE PERCENTUALI DI COPERTURA
# Definiamo una matrice di riclassificazione basata su soglie ecologiche:
# Classe 1 (< 0.2): Roccia nuda / Suolo nudo
# Classe 2 (0.2 - 0.5): Pascolo degradato o fortemente stressato/secco
# Classe 3 (> 0.5): Pascolo sano, rigoglioso e ad alta vigoria

matrice_classi <- matrix(c(-Inf, 0.2, 1, 
                           0.2, 0.5, 2, 
                           0.5, Inf, 3), ncol = 3, byrow = TRUE)

# Applichiamo la riclassificazione ai raster di Maggio e Agosto

classi_mag <- classify(ndvi_mag, matrice_classi)
classi_ago <- classify(ndvi_ago, matrice_classi)

# Estrazione delle frequenze
f_mag <- freq(classi_mag)
f_ago <- freq(classi_ago)

# Calcolo delle percentuali escludendo i pixel NA dal totale
tot_pixel_mag <- sum(f_mag$count)
tot_pixel_ago <- sum(f_ago$count)

perc_mag <- (f_mag$count / tot_pixel_mag) * 100
perc_ago <- (f_ago$count / tot_pixel_ago) * 100

# Organizziamo i dati in un dataframe strutturato per la tabella e per ggplot2

tabella_esame <- data.frame(
  Stato_Pascolo = factor(c("Roccia/Suolo Nudo", "Pascolo Degradato", "Pascolo Sano"),
                         levels = c("Roccia/Suolo Nudo", "Pascolo Degradato", "Pascolo Sano")),
  Maggio = round(perc_mag, 2),
  Agosto = round(perc_ago, 2)
)

print(tabella_esame)

# 6. GENERAZIONE DEI GRAFICI COMPARATIVI CON GGPLOT2

# Riorganizziamo il dataframe in formato "long" per facilitare il plotting
tabella_long <- data.frame(
  Stato_Pascolo = rep(tabella_esame$Stato_Pascolo, 2),
  Mese = c(rep("Maggio", 3), rep("Agosto", 3)),
  Percentuale = c(tabella_esame$Maggio, tabella_esame$Agosto)
)

# Inseriamo l'ordine cronologico (Maggio prima di Agosto)
tabella_long$Mese <- factor(tabella_long$Mese, levels = c("Maggio", "Agosto"))

# Grafico a barre raggruppate
ggplot(tabella_long, aes(x = Stato_Pascolo, y = Percentuale, fill = Mese)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("darkgreen", "orange")) +
  labs(title = "Evoluzione delle Classi di Pascolo al Passo Falzarego",
       x = "Tipologia di Copertura", y = "Percentuale sul totale (%)") +
  theme_minimal()                                              #05_barre_percentuali.png

# 7. CALCOLO DELL'ETEROGENEITÀ SPAZIALE SULLA MAPPA DI AGOSTO
# Utilizziamo una funzione locale (focal) basata sul concetto di finestra mobile (moving window). 
# w = matrix(1,3,3) definisce una matrice quadrata di 3x3 pixel centrata sul pixel target. 
# fun = sd stabilisce che la metrica calcolata all'interno della finestra è la Deviazione Standard. 
# na.rm = TRUE garantisce che eventuali pixel mancanti (NA) ai bordi non interrompano il calcolo.

eterogeneita_ago <- focal(ndvi_ago, w=matrix(1,3,3), fun=sd, na.rm=TRUE)
names(eterogeneita_ago) <- "Eterogeneita"

# 8. VISUALIZZAZIONE AVANZATA CON GGPLOT2
ggplot() +
  geom_spatraster(data = eterogeneita_ago, aes(fill = Eterogeneita)) +
  scale_fill_viridis_c(option = "inferno", na.value = "transparent") +
  labs(title = "Eterogeneità Spaziale del Pascolo Alpino in Estate",
       subtitle = "Analisi di frammentazione dell'habitat per lo Stambecco (Dolomiti)",
       x = "Longitudine", y = "Latitudine",
       fill = "Deviazione\nStandard") +
  theme_minimal()    # 03_eterogeneita_ggplot.png

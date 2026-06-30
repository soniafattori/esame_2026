# 1. Installazione pacchetti e caricamento librerie

install.packages("terra")                 # Gestione dei dati raster geografici
install.packages("ggplot2")               # Utilizzato per la visualizzazione grafica avanzata e la mappatura
install.packages("viridis")               # Palette di colori per l'accessibilità visiva
install.packages("rasterdiv")             # Il pacchetto per il calcolo dell'eterogeneità spaziale
install.packages("devtools")              # Necessario per scaricare pacchetti da GitHub
install_github("ducciorocchini/imageRy")  # Repository di dati e funzioni didattiche del corso
install.packages("patchwork")             # Necessario per affiancare grafici ggplot2 diversi

library(terra)
library(ggplot2)
library(viridis)
library(rasterdiv)
library(imageRy)
library(devtools)
library(patchwork)

# 2. IMPORTAZIONE E STACKING DEI DATI SATELITARI (SENTINEL-2) 
# Visualizziamo la lista dei dataset interni disponibili nel pacchetto per verifica

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

# 3. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (FALZAREGO STRESS) 
# Applichiamo un'operazione di algebra dei raster sottraendo il pixel primaverile da quello estivo. 
# Obiettivo: Evidenziare quantitativamente il viraggio o il disseccamento del pascolo.

diff_estate_primavera <- ndvi_ago - ndvi_mag

# Plottiamo la differenza per vedere dove la vegetazione è aumentata o diminuita, I valori negativi indicano una perdita di vigoria vegetativa (NDVI diminuito da Maggio ad Agosto)
# Usiamo una mappa di colore divergente (magma) per evidenziare i contrasti

plot(diff_estate_primavera, col=magma(100), 
     main="Variazione dell'NDVI (Agosto vs Maggio)")   # 02_differenza_ndvi.png

# 4. ANALISI DELLA DISTRIBUZIONE SPETTRALE (ISTOGRAMMI)
# Generiamo un pannello con due istogrammi per osservare lo shift matematico dei pixel

im.multiframe(1, 2)
hist(ndvi_mag, main = "Distribuzione NDVI Maggio", col = "darkgreen", xlab = "Valori NDVI")
hist(ndvi_ago, main = "Distribuzione NDVI Agosto", col = "orange", xlab = "Valori NDVI")     # 04_istogrammi_confronto.png

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

# Calcoliamo le frequenze dei pixel e ricaviamo le percentuali sul totale delle celle

perc_mag <- freq(classi_mag)$count * 100 / ncell(classi_mag)
perc_ago <- freq(classi_ago)$count * 100 / ncell(classi_ago)

# Organizziamo i dati in un dataframe strutturato per la tabella e per ggplot2

tabella_esame <- data.frame(
  Stato_Pascolo = c("Roccia/Suolo Nudo", "Pascolo Degradato", "Pascolo Sano"),
  Maggio_Perc = round(perc_mag, 2),
  Agosto_Perc = round(perc_ago, 2)
)

# Stampiamo a schermo la tabella finale per estrarre i dati numerici della relazione

print(tabella_esame)

# Generiamo il grafico a barre comparative affiancate sfruttando il pacchetto patchwork
# Grafico Maggio (Primavera)

p1 <- ggplot(tabella_esame, aes(x = Stato_Pascolo, y = Maggio_Perc, fill = Stato_Pascolo)) +    
  geom_bar(stat = "identity") + 
  scale_fill_viridis_d(option = "viridis") + 
  ylim(0, 100) +
  labs(title = "Copertura a Maggio (Primavera)", y = "Percentuale (%)", x = NULL) + 
  theme_minimal() + 
  theme(legend.position = "none")

# Grafico Agosto (Estate)

p2 <- ggplot(tabella_esame, aes(x = Stato_Pascolo, y = Agosto_Perc, fill = Stato_Pascolo)) +
  geom_bar(stat = "identity") + 
  scale_fill_viridis_d(option = "viridis") + 
  ylim(0, 100) +
  labs(title = "Copertura ad Agosto (Estate)", y = "%", x = NULL) + 
  theme_minimal()

# Visualizzazione e unione dei due grafici affiancati

p1 + p2    # 05_barre_percentuali.png

# 6. CALCOLO DELL'ETEROGENEITÀ SPAZIALE (APPROCCIO RASTERDIV) SULLA MAPPA DI AGOSTO
# Utilizziamo una funzione locale (focal) basata sul concetto di finestra mobile (moving window). 
# w = matrix(1,3,3) definisce una matrice quadrata di 3x3 pixel centrata sul pixel target. 
# fun = sd stabilisce che la metrica calcolata all'interno della finestra è la Deviazione Standard. 
# na.rm = TRUE garantisce che eventuali pixel mancanti (NA) ai bordi non interrompano il calcolo.

eterogeneita_ago <- focal(ndvi_ago, w=matrix(1,3,3), fun=sd, na.rm=TRUE)

# 7. VISUALIZZAZIONE AVANZATA CON GGPLOT2
# Per utilizzare ggplot2 dobbiamo convertire il formato spaziale 'SpatRaster' in un comune dataframe. 
# xy = TRUE estrae esplicitamente le coordinate geografiche (Longitudine e Latitudine) di ogni pixel. 
# na.rm = TRUE elimina i record vuoti per alleggerire la memoria del dataset.
# Trasformiamo in dataframe per fare un grafico elegante con ggplot2

df_het <- as.data.frame(eterogeneita_ago, xy=TRUE, na.rm=TRUE)

# Rinominiamo le colonne del dataframe per assegnare le variabili a ggplot

colnames(df_het) <- c("x", "y", "Eterogeneita")

# Generiamo la mappa finale con la sintassi formale di ggplot2

ggplot(df_het, aes(x=x, y=y, fill=Eterogeneita)) +
  geom_raster() +
  scale_fill_viridis_c(option = "inferno") +
  labs(title="Eterogeneità Spaziale del Pascolo Alpino in Estate",
       subtitle="Analisi di frammentazione dell'habitat per lo Stambecco (Dolomiti)",
       x="Longitudine", y="Latitudine") +
  theme_minimal()    # 03_eterogeneita_ggplot.png

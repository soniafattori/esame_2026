# Analisi Multitemporale della fenologia del pascolo alpino: implicazioni ecologiche per lo stambecco (*Capra ibex*) nelle Dolomiti 🐐

## 📌 Introduzione e Obiettivi Ecologici
Il cambiamento climatico sta provocando profonde alterazioni negli ecosistemi d'alta quota, modificando i ritmi stagionali della vegetazione. Questo progetto applica le tecniche di **Telerilevamento** per monitorare la dinamica temporale e la struttura spaziale dei pascoli montani nel **Passo Falzarego (Dolomiti)** nel corso dell'anno 2020, utilizzando i dati del satellite **Sentinel-2**.

L'obiettivo ecologico è mappare lo stress vegetativo estivo e la frammentazione paesaggistica per comprendere i pattern di movimento dello **Stambecco Alpino (*Capra ibex*)**. Lo stambecco è un erbivoro d'alta quota fortemente condizionato dalla qualità nutrizionale del pascolo. L'aumento delle temperature estive causa un precoce disseccamento della vegetazione a quote medio-basse, costringendo la specie a una migrazione verticale verso nicchie di rifugio climatico ad altitudini elevate, dove la fusione tardiva della neve garantisce erba fresca e digeribile.

<img width="640" height="425" alt="stambecco_1" src="https://github.com/user-attachments/assets/83246e42-8929-457f-a535-a25442d94362" />

---

## 🔬 Metodi e Formulazione Matematica

### 1. Indice di Vegetazione (NDVI)
Per quantificare la biomassa e lo stato di salute della vegetazione nelle quattro stagioni, è stato utilizzato l'**NDVI (Normalized Difference Vegetation Index)**. L'indice sfrutta il comportamento spettrale delle foglie clorofilliane, che assorbono fortemente la radiazione nel rosso ($RED$) e riflettono quella nel vicino infrarosso ($NIR$):

$$NDVI = \frac{NIR - RED}{NIR + RED}$$

L'indice varia tra $-1$ e $+1$. Valori prossimi allo zero o negativi indicano superfici prive di vegetazione (neve, roccia nuda), mentre valori prossimi a $+1$ indicano massima vigoria vegetativa.

### 2. Algebra dei Raster (Rilevamento del Cambiamento)
Per misurare l'intensità del deperimento estivo del pascolo rispetto al picco primaverile, è stata applicata un'operazione di algebra dei raster sottrattiva tra il mese di Agosto ($NDVI_{ago}$) e il mese di Maggio ($NDVI_{mag}$):

$$\Delta NDVI = NDVI_{ago} - NDVI_{mag}$$

* Valori **negativi** indicano aree soggette a senescenza o stress idrico (perdita di vigoria).
* Valori **positivi** indicano un incremento della biomassa fogliare.

### 3. Classificazione Ecologica del Territorio
Al fine di quantificare la risorsa trofica disponibile, i pixel continui di NDVI sono stati discretizzati in classi discrete tramite una funzione di riclassificazione a matrice basata su tre soglie ecologiche:
* **Classe 1 (Roccia nuda / Suolo nudo):** NDVI < 0.2 (aree rocciose, detriti o neve residua).
* **Classe 2 (Pascolo degradato / Stressato):** 0.2 ≤ NDVI < 0.5 (vegetazione rada o in fase di stress idrico).
* **Classe 3 (Pascolo sano / Rigoglioso):** NDVI ≥ 0.5 (prateria alpina al picco della vigoria e biomassa).

### 4. Eterogeneità Spaziale (Standard Deviation)
L'eterogeneità spaziale dell'habitat è stata calcolata applicando una funzione a **finestra mobile (*moving window*)** di dimensioni $3 \times 3$ pixel sull'NDVI estivo. Come metrica di diversità paesaggistica locale è stata computata la **Deviazione Standard ($SD$)**:

$$SD = \sqrt{\frac{\sum_{i=1}^{N}(x_i - \bar{x})^2}{N}}$$

Dove $x_i$ rappresenta il valore di NDVI del singolo pixel all'interno della finestra, $\bar{x}$ la media locale e $N$ il numero totale di pixel ($9$).

---

## 💻 Codice R DA RIVEDERE
Il seguente script contiene l'intero lavoro commentato.

### 1. CARICAMENTO DELLE LIBRERIE NECESSARIE
```r
library(terra)      # Gestione dei dati raster geografici
library(tidyterra)  # Integrazione nativa di oggetti SpatRaster in ggplot2
library(ggplot2)    # Visualizzazione grafica avanzata e mappatura
library(viridis)    # Palette di colori per l'accessibilità visiva
library(imageRy)    # Database con dati e funzioni del corso
```

### 2. IMPORTAZIONE DEI DATI SATELITARI STAGIONALI (Sentinel-2 - Passo Falzarego)
```r
# Importiamo i file raster (mappe) dell'NDVI del 2020 relativi al Passo Falzarego (Dolomiti)
ndvi_feb <- im.import("Sentinel2_NDVI_2020-02-21.tif") # Inverno (Dormienza/Neve)
ndvi_mag <- im.import("Sentinel2_NDVI_2020-05-21.tif") # Primavera (Greening)
ndvi_ago <- im.import("Sentinel2_NDVI_2020-08-01.tif") # Estate (Picco/Siccità)
ndvi_nov <- im.import("Sentinel2_NDVI_2020-11-27.tif") # Autunno (Senescenza)

# Creazione del RasterStack multitemporale
punti_stagionali <- c(ndvi_feb, ndvi_mag, ndvi_ago, ndvi_nov)
names(punti_stagionali) <- c("Febbraio", "Maggio", "Agosto", "Novembre")

# Visualizzazione della serie temporale completa con lapette viridis
plot(punti_stagionali, col=viridis(100))

# 01_serie_stagionale.png
```

### 3. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (CAMBIAMENTO ESTIVO)
```r
# Applichiamo un'operazione di algebra dei raster sottraendo il pixel primaverile da quello estivo per evidenziare quantitativamente il viraggio o il disseccamento del pascolo
diff_estate_primavera <- ndvi_ago - ndvi_mag
plot(diff_estate_primavera, col=magma(100), 
     main="Variazione dell'NDVI (Agosto vs Maggio)")

# 02_differenza_ndvi.png
```

### 4. ANALISI DELLA DISTRIBUZIONE SPETTRALE TRAMITE ISTOGRAMMI
```r
# Generiamo un pannello con due istogrammi per osservare lo shift matematico dei pixel
im.multiframe(1, 2)
hist(ndvi_mag, main = "Distribuzione NDVI Maggio", col = "darkgreen", xlab = "Valori NDVI", ylim = c(0, 65000)) # Blocca il limite da 0 a 65.000
hist(ndvi_ago, main = "Distribuzione NDVI Agosto", col = "orange", xlab = "Valori NDVI", ylim = c(0, 65000)) # Blocca il limite da 0 a 65.000

# 04_istogrammi_confronto.png

dev.off() # Reset del pannello grafico
```

### 5. RICLASSIFICAZIONE E CALCOLO DELLE PERCENTUALI DI COPERTURA
```r
# Definizione delle matrici di soglia ecologica
matrice_classi <- matrix(c(-Inf, 0.2, 1,                              # Classe 1 (< 0.2): Roccia nuda / Suolo nudo
                           0.2, 0.5, 2,                               # Classe 2 (0.2 - 0.5): Pascolo degradato o fortemente stressato/secco
                           0.5, Inf, 3), ncol = 3, byrow = TRUE)      # Classe 3 (> 0.5): Pascolo sano, rigoglioso e ad alta vigoria

# Riclassificazione dei raster di Maggio e Agosto
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
```

### 6. GENERAZIONE DEI GRAFICI COMPARATIVI CON GGPLOT2
```r
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
  theme_minimal()

#05_barre_percentuali.png
```

### 7. CALCOLO DELL'ETEROGENEITÀ SPAZIALE SULLA MAPPA DI AGOSTO
```r
# Utilizziamo una funzione locale (focal) basata sul concetto di finestra mobile (moving window). 
# w = matrix(1,3,3) definisce una matrice quadrata di 3x3 pixel centrata sul pixel target. 
# fun = sd stabilisce che la metrica calcolata all'interno della finestra è la Deviazione Standard. 
# na.rm = TRUE garantisce che eventuali pixel mancanti (NA) ai bordi non interrompano il calcolo.
eterogeneita_ago <- focal(ndvi_ago, w=matrix(1,3,3), fun=sd, na.rm=TRUE)
names(eterogeneita_ago) <- "Eterogeneita"
```

### 8. VISUALIZZAZIONE TRAMITE PLOT CARTOGRAFICO
```r
ggplot() +
  geom_spatraster(data = eterogeneita_ago, aes(fill = Eterogeneita)) +
  scale_fill_viridis_c(option = "inferno", na.value = "transparent") +
  labs(title = "Eterogeneità Spaziale del Pascolo Alpino in Estate",
       subtitle = "Analisi di frammentazione dell'habitat per lo Stambecco (Dolomiti)",
       x = "Longitudine", y = "Latitudine",
       fill = "Deviazione\nStandard") +
  theme_minimal()

# 03_eterogeneita_ggplot.png
```

---

## 📊 Visualizzazione dell'Output Cartografico 
### 1. Dinamica stagionale della biomassa vegetale e dell'indice NDVI (Passo Falzarego, 2020)
La figura seguente mostra la variazione della biomassa vegetale nel Passo Falzarego durante le quattro stagioni dell'anno 2020, evidenziando il ciclo di crescita e dormienza:

<img width="1536" height="738" alt="01_serie_stagionale" src="https://github.com/user-attachments/assets/bf7574cb-37fb-4eba-96c2-7cb7b1bd8567" />

---
L'**NDVI** (*Normalized Difference Vegetation Index*) misura il grado di vigoria e densità della vegetazione fotosinteticamente attiva, quantificando la differenza tra la riflettanza nel vicino infrarosso e nel rosso. Nella visualizzazione basata sulla palette *Viridis*:

* **Valori negativi e vicini allo 0 ($\approx -0.4$ a $0.2$) – Tonalità Viola scuro / Blu:** Indicano la totale assenza di vegetazione fotosintetica attiva. Corrispondono a superfici coperte da manto nevoso, ghiaccio, corpi idrici o roccia affiorante priva di copertura vegetale.
* **Valori intermedi ($\approx 0.2$ a $0.5$) – Tonalità Verde / Azzurro:** Rappresentano fasi transitorie, come la vegetazione in fase di risveglio o senescenza, pascoli radi o aree a copertura mista (roccia e prateria sparso).
* **Valori elevati ($\approx 0.5$ a $0.8+$) – Tonalità Giallo brillante:** Indicano una vegetazione densa, rigogliosa e al picco dell'attività fotosintetica.

---

#### 📅 Analisi Stagionale del Ciclo Vegetativo

* **Febbraio (Inverno):** 
  * Prevalenza quasi assoluta di tonalità **viola scuro e blu** (valori compresi tra $-0.2$ e $0.2$).
  * Il territorio si trova in piena dormienza invernale, dominato da un'estesa copertura nevosa che azzera la risposta fotosintetica della prateria. Solo limitate pareti rocciose scoperte mostrano valori di poco superiori allo zero.

* **Maggio (Primavera / *Greening*):** 
  * Marcata transizione verso il **verde e il giallo** (valori compresi tra $0.4$ e $0.8$), specialmente nei versanti a quota inferiore o meglio esposti.
  * Coincide con la fase di risveglio vegetativo (*greening*). Con il progressivo scioglimento delle nevi e l'innalzamento delle temperature, la prateria alpina riattiva rapidamente la fotosintesi e incrementa la densità fogliare.

* **Agosto (Estate / Picco di Biomassa & Stress):** 
  * Massima estensione delle aree in **giallo brillante** (valori tra $0.6$ e $>0.8$).
  * Rappresenta il momento di massimo sviluppo della biomassa vegetale. Tuttavia, nelle porzioni centro-meridionali si notano prime chiazze viranti al verde-azzurro, sintomo di un iniziale disseccamento o stress idrico estivo del pascolo.

* **Novembre (Autunno / Senescenza):** 
  * Regressione generalizzata verso sfumature **blu scuro e verde cupo** (valori che scendono sotto $0.2$).
  * Fasi conclusive della stagione vegetativa. La perdita di clorofilla e il calo delle temperature riducono drasticamente la vigoria del pascolo; le prime spolverate di neve ad alta quota contribuiscono al riabbassamento generale dell'indice.

### 2. Valutazione dell'incremento di fotosintesi netta tramite differenziazione NDVI (Agosto vs Maggio)
La mappa seguente mostra la variazione differenziale dell'indice NDVI ($\Delta\text{NDVI}$) calcolata tra il mese di agosto e il mese di maggio. L'analisi evidenzia i cambiamenti netti nella copertura e nella vigoria della vegetazione tra la tarda primavera e il picco estivo:

<img width="1536" height="738" alt="02_differenza_ndvi" src="https://github.com/user-attachments/assets/cb070c63-793c-4876-8488-ccbbe1c6d5ae" />

---

La legenda a destra quantifica la differenza di valore dell'NDVI tra i due periodi ($\text{NDVI}_{\text{Agosto}} - \text{NDVI}_{\text{Maggio}}$), su una scala che varia indicativamente da $-0.6$ a $+0.8$:

* **Valori negativi ($\approx -0.6$ a $0.0$) – Tonalità Viola scuro / Blu / Magenta cupo:** Indicano una diminuzione o una stabilità dell'indice NDVI da maggio ad agosto. Nelle aree montane ciò è legato a zone prive di vegetazione fotosintetica (roccia nuda, pareti scoscese, scree o ghiaioni) oppure a superfici che a maggio erano già libere da neve e la cui vigoria non è aumentata ulteriormente.
* **Valori moderatamente positivi ($\approx 0.1$ a $0.4$) – Tonalità Arancione / Rosa intenso:** Rappresentano un incremento moderato della biomassa e dell'attività fotosintetica. Corrispondono a praterie di fondo valle e pascoli che a maggio avevano già avviato il ciclo vegetativo e che in estate consolidano la propria copertura.
* **Valori fortemente positivi ($\approx 0.5$ a $0.8+$) – Tonalità Giallo chiaro / Bianco brillante:** Evidenziano i massimi incrementi netti dell'indice NDVI. Corrispondono alle porzioni di territorio (spesso a quote medio-alte o in versanti in ombra/a nord) che a maggio erano ancora coperte da neve residua o in forte ritardo fenologico, e che ad agosto raggiungono il loro massimo sviluppo vegetativo.

---

#### 📝 Commento Ecologico e Territoriale

* **Dinamica di fusione della neve e rigoglio estivo:** Le diffuse macchie di colore **giallo e arancione chiaro** concentrate nella porzione centro-meridionale e lungo i canaloni mostrano dove il disgelo tardivo ha permesso alla vegetazione alpina di emergere e svilupparsi rapidamente nell'arco dei tre mesi estivi.
* **Stabilità delle pareti rocciose:** Le estese zone in **viola scuro e arancione scuro** nella metà settentrionale e nord-orientale evidenziano le pareti dolomitiche e i ghiaioni ad alta quota, dove l'assenza di suolo o la presenza di sola roccia nuda impedisce variazioni significative della copertura vegetale tra le due stagioni.

### 3. Istogrammi di Distribuzione Spettrale
Confronto delle frequenze dei pixel di NDVI, evidenziando lo shift e la ristrutturazione della popolazione dei pixel tra primavera ed estate:

<img width="1536" height="715" alt="04_istogrammi_confronto" src="https://github.com/user-attachments/assets/ec65b960-e236-454c-ba89-acc2a17257b5" />

### 4. Grafico di Copertura Percentuale Estratta
Come evidenziato dall'elaborazione statistica ggplot2, la ripartizione del territorio mostra un incremento netto del pascolo sano nel mese estivo dovuto alla deglaciazione delle vette:

<img width="1536" height="715" alt="05_barre_percentuali" src="https://github.com/user-attachments/assets/09857ac9-e611-483f-8f4c-da1b8615dee0" />

### 5. Mappa Finale dell'Eterogeneità Spaziale
Grafico ad alta risoluzione generato con `ggplot2` che mappa la frammentazione ecologica locale (Deviazione Standard su finestra mobile $3 \times 3$):

<img width="1136" height="470" alt="03_eterogeneita_ggplot" src="https://github.com/user-attachments/assets/7b812826-0a02-421b-b809-c017a39198dd" />

---

## 🔢 Analisi Quantitativa ed Estrazione dei Dati
La riclassificazione computerizzata ha prodotto i seguenti risultati percentuali relativi alla ripartizione del territorio nelle due stagioni chiave:

| Stato Pascolo | Maggio (%) | Agosto (%) |
| :--- | :---: | :---: |
| **Roccia/Suolo Nudo** | 23.06 | 10.33 |
| **Pascolo Degradato** | 23.61 | 10.58 |
| **Pascolo Sano** | 53.33 | 79.09 |
| **Totale** | 100.00 | 100.00 |

---

## 📈 Discussione e conclusioni ecologiche NON MI PIACE

L'applicazione del telerilevamento satellitare multitemporale, unita all'integrazione di metriche di classificazione d'immagine e analisi statistica locale, ha permesso di mappare quantitativamente le dinamiche eco-fenologiche nel Passo Falzarego. I risultati ottenuti non solo risolvono un apparente paradosso numerico, ma forniscono la chiave di lettura spaziale e matematica per comprendere l'ecologia del comportamento e le strategie di sopravvivenza dello Stambecco Alpino (*Capra ibex*).

### 1. Il Fenomeno della "Green Wave" Ritardata ad Alta Quota (Dinamica Trofica)
L'analisi quantitativa delle frequenze dei pixel rivela un pattern macro-ecologico apparentemente controintuitivo: **la classe Pascolo Sano aumenta in modo significativo nel passaggio dal picco primaverile di Maggio (~51%) allo stress estivo di Agosto (~75%)**. Questo trend differisce radicalmente dalle dinamiche degli ecosistemi di pianura, collina o macro-mediterranei, dove l'estate coincide con una senescenza generalizzata e il disseccamento della volta vegetativa. 

Negli ambienti alpini d'alta quota delle Dolomiti, la fenologia vegetale è rigidamente governata dalla criosfera e dalla dinamica del manto nevoso. A Maggio, ampie porzioni del Passo Falzarego (specialmente i versanti esposti a nord, i canaloni e i pianori sommitali oltre i 2100 m) si trovano ancora in una fase di profonda dormienza invernale o risultano fisicamente coperte da nevai stagionali. Questo si traduce nei dati spettrali in elevati tassi di "Roccia / Suolo Nudo" (~22%) e "Pascolo Degradato/Rado" (~23%). Ad Agosto, il completo disgelo e l'incremento dell'orto-radiazione solare innescano un'esplosione vegetativa tardiva, sincrona e impulsiva sulle vette (*delayed green wave*). Questo risveglio di massa comprime drasticamente le aree abiotiche o stentate (~11% ciascuna), convertendole in una prateria d'alta quota continua, caratterizzata da alti valori di NDVI (Classe 3 al 75%) e ricca di tessuti vegetali giovani.

### 2. Spostamento Spaziale della Risorsa e Migrazione Verticale dell'Erbivoro
Sebbene l'estensione complessiva del pascolo sano aumenti su scala di matrice paesaggistica, la mappa di rilevamento del cambiamento ($\Delta NDVI$) svela un'eterogeneità spaziale critica e un forte gradiente altitudinale. I fondovalle stabili e le quote inferiori mostrano diffuse anomalie negative (colorazioni scure nella palette *magma*), indizio di un principio di senescenza precoce e perdita di turgore fogliare indotti dallo stress termico estivo. Al contrario, il segno positivo del cambiamento si concentra esclusivamente lungo i margini superiori.

Per lo stambecco, questa asincronia rappresenta la vera **ragione principale della migrazione verticale estiva**. La *Capra ibex* è un grande erbivoro altamente specializzato ma fortemente termosensibile, che manifesta alterazioni fisiologiche e stress metabolico già sopra i 15 °C. La risalita verso le creste ad Agosto risponde quindi a un trade-off vitale:
1. **Inseguimento della qualità trofica:** L'animale abbandona i fondovalle caldi dove l'erba è ormai lignificata, indigeribile e povera di nutrienti, muovendosi verso l'alto per intercettare quel 75% di pascolo fresco, tenero e ad altissimo contenuto di azoto e proteine.
2. **Oasi termica:** Lo spostamento in quota consente la frequentazione di microclimi ventilati e freschi, riducendo i costi energetici di termoregolazione.

### 3. Eterogeneità Ambientale come Nicchia di Rifugio e Sicurezza
La mappa finale dell'eterogeneità spaziale, computata mediante deviazione standard locale su finestra mobile $3 \times 3$, evidenzia come i massimi valori di frammentazione strutturale (aree calde in palette *inferno*) non siano distribuiti casualmente, ma ricalchino fedelmente gli ecotoni geomorfologici. Si tratta delle fasce di transizione dove la prateria alpina d'alta quota si frammenta e si incastra con pareti di roccia verticale, ghiaioni e detriti di falda.

Dal punto di vista dell'ecologia comportamentale, questi habitat ad alta eterogeneità rappresentano la principale nicchia di rifugio estiva per la specie, garantendo una strategia di ottimizzazione dello spazio:
* **Anti-predazione e Riposo:** La contiguità spaziale con le pareti rocciose verticali offre vie di fuga immediate ed esclusive contro predatori d'avanguardia (come il lupo) e fornisce zone d'ombra stabili per il riposo diurno.
* **Foraggiamento di precisione:** Le piccole nicchie erbose confinate tra i blocchi rocciosi, seppur frammentate, beneficiano dell'umidità rilasciata dalla fusione delle nevi perenni, restando protette dall'inaridimento di massa e permettendo un pascolamento sicuro senza l'obbligo per l'animale di esporsi in campo aperto a quote inferiori.

### 4. Il Ruolo del Telerilevamento Open-Source nella Conservazione Attiva
In conclusione, l'integrazione di indici spettrali standardizzati ($NDVI$), matrici di riclassificazione quantitativa e metriche di variabilità spaziale (*focal standard deviation*) si dimostra uno strumento diagnostico e predittivo fondamentale per l'ecologia della conservazione. I cambiamenti climatici globali rischiano di accelerare i processi di disgelo, alterando il timing della *green wave* e riducendo la finestra temporale di alimentazione ottimale per gli erbivori d'alta quota (*mismatch fenologico*).




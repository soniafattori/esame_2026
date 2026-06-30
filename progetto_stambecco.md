# Analisi Multitemporale della fenologia del pascolo alpino: implicazioni ecologiche per lo stambecco (*Capra ibex*) nelle Dolomiti

## 📌 Introduzione e Obiettivi Ecologici
Il cambiamento climatico sta provocando profonde alterazioni negli ecosistemi d'alta quota, modificando i ritmi stagionali della vegetazione (*mismatch fenologico*). Questo progetto applica le tecniche di **Telerilevamento (Remote Sensing)** per monitorare la dinamica temporale e la struttura spaziale dei pascoli montani nel **Passo Falzarego (Dolomiti)** nel corso dell'anno 2020, utilizzando i dati del satellite **Sentinel-2**.

L'obiettivo ecologico è mappare lo stress vegetativo estivo e la frammentazione paesaggistica per comprendere i pattern di movimento dello **Stambecco Alpino (*Capra ibex*)**. Lo stambecco è un erbivoro d'alta quota fortemente condizionato dalla qualità nutrizionale del pascolo. L'aumento delle temperature estive causa un precoce disseccamento della vegetazione a quote medio-basse, costringendo la specie a una migrazione verticale verso nicchie di rifugio climatico ad altitudini elevate, dove la fusione tardiva della neve garantisce erba fresca e digeribile.

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

### 3. Eterogeneità Spaziale (Standard Deviation)
In linea con l'approccio metodologico del corso, l'eterogeneità spaziale dell'habitat è stata calcolata applicando una funzione a **finestra mobile (*moving window*)** di dimensioni $3 \times 3$ pixel sull'NDVI estivo. Come metrica di diversità paesaggistica locale è stata computata la **Deviazione Standard ($SD$)**:

$$SD = \sqrt{\frac{\sum_{i=1}^{N}(x_i - \bar{x})^2}{N}}$$

Dove $x_i$ rappresenta il valore di NDVI del singolo pixel all'interno della finestra, $\bar{x}$ la media locale e $N$ il numero totale di pixel ($9$).

---

## 💻 Codice R Completo e Riproducibile
Il seguente script contiene l'intero flusso di lavoro commentato, dall'importazione dei dati del pacchetto `imageRy` fino alla generazione della cartografia finale in `ggplot2`.

```r
# ==============================================================================
# PROGETTO DI TELERILEVAMENTO 2026 - CORSO PROF. DUCCIO ROCCHINI
# Monitoraggio della Fenologia del Pascolo Alpino per lo Stambecco 
# ==============================================================================

# Caricamento delle librerie necessarie
library(terra)      # Gestione dei dati raster geografici
library(ggplot2)    # Visualizzazione grafica avanzata e mappatura
library(viridis)    # Palette cromatiche percettivamente uniformi
library(rasterdiv)  # Calcolo dell'eterogeneità spaziale 
library(imageRy)    # Database con dati e funzioni del corso

# 1. IMPORTAZIONE DEI DATI SATELITARI STAGIONALI (Sentinel-2 - Passo Falzarego)
ndvi_feb <- im.import("Sentinel2_NDVI_2020-02-21.tif") # Inverno (Dormienza/Neve)
ndvi_mag <- im.import("Sentinel2_NDVI_2020-05-21.tif") # Primavera (Greening)
ndvi_ago <- im.import("Sentinel2_NDVI_2020-08-01.tif") # Estate (Picco/Siccità)
ndvi_nov <- im.import("Sentinel2_NDVI_2020-11-27.tif") # Autunno (Senescenza)

# Creazione del RasterStack multitemporale
punti_stagionali <- c(ndvi_feb, ndvi_mag, ndvi_ago, ndvi_nov)
names(punti_stagionali) <- c("Febbraio", "Maggio", "Agosto", "Novembre")

# Visualizzazione della serie fenologica stagionale
plot(punti_stagionali, col=viridis(100))

# 01_serie_stagionale.png

# 2. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (CAMBIAMENTO ESTIVO)
diff_estate_primavera <- ndvi_ago - ndvi_mag
plot(diff_estate_primavera, col=magma(100), 
     main="Variazione dell'NDVI (Agosto vs Maggio)")

 # 02_differenza_ndvi.png

# 3. CALCOLO DELL'ETEROGENEITÀ SPAZIALE CON FINESTRA MOBILE 3x3
eterogeneita_ago <- focal(ndvi_ago, w=matrix(1,3,3), fun=sd, na.rm=TRUE)

# 4. VISUALIZZAZIONE FINALE AVANZATA CON GGPLOT2
# Conversione del raster in dataframe per ggplot
df_het <- as.data.frame(eterogeneita_ago, xy=TRUE, na.rm=TRUE)
colnames(df_het) <- c("x", "y", "Eterogeneita")

# Generazione del plot cartografico
ggplot(df_het, aes(x=x, y=y, fill=Eterogeneita)) +
  geom_raster() +
  scale_fill_viridis_c(option = "inferno") +
  labs(title="Eterogeneità Spaziale del Pascolo Alpino in Estate",
       subtitle="Analisi di frammentazione dell'habitat per lo Stambecco (Dolomiti)",
       x="Longitudine", y="Latitudine") +
  theme_minimal()

# 03_eterogeneita_ggplot.png

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

# 2. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (CAMBIAMENTO ESTIVO)
diff_estate_primavera <- ndvi_ago - ndvi_mag
plot(diff_estate_primavera, col=magma(100), 
     main="Variazione dell'NDVI (Agosto vs Maggio)")

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
```

---

## 📊 Visualizzazione dell'Output Cartografico 
### 1. Dinamica Fenologica Stagionale (NDVI)
La figura seguente mostra la variazione della biomassa vegetale nel Passo Falzarego durante le quattro stagioni dell'anno 2020, evidenziando il ciclo di crescita e dormienza:

![Serie Temporale NDVI](./01_serie_stagionale.png)

### 2. Mappa di Rilevamento del Cambiamento ($\Delta NDVI$)
Sottrazione spettrale tra Agosto e Maggio. I toni scuri indicano le aree soggette a forte disseccamento estivo della risorsa trofica:

![Mappa Differenza NDVI](./02_differenza_ndvi.png)

### 3. Mappa Finale dell'Eterogeneità Spaziale
Grafico ad alta risoluzione generato con `ggplot2` che mappa la frammentazione ecologica locale (Deviazione Standard su finestra mobile $3 \times 3$):

![Eterogeneità Spaziale](./03_eterogeneita_ggplot.png)

---

## 📈 Discussione e conclusioni ecologiche

L'applicazione del telerilevamento satellitare multitemporale ha permesso di estrarre informazioni cruciali sulla dinamica dei pascoli d'alta quota nel Passo Falzarego, fornendo una chiave di lettura spaziale per l'ecologia del comportamento dello Stambecco Alpino (*Capra ibex*).

### 1. Dinamica Fenologica e Risveglio Primaverile (*Greening*)
La serie temporale dell'NDVI evidenzia i classici ritmi degli ecosistemi alpini fortemente condizionati dal fattore neve. 
* A **Febbraio**, i valori di NDVI prossimi allo zero testimoniano la dominanza della copertura nevosa e la totale dormienza della vegetazione. In questa fase, gli stambecchi riducono al minimo i movimenti e il metabolismo, sopravvivendo grazie alle riserves adipose.
* A **Maggio**, l'aumento delle temperature e la conseguente fusione della neve innescano l'esplosione vegetativa (*greening*). La mappa mostra picchi di NDVI elevati nelle valli e sui versanti ben esposti. Questo incremento corrisponde ecologicamente alla massima disponibilità di foraggio fresco, tenero, povero di fibra grezza e ricchissimo di azoto. Gli stambecchi scendono temporaneamente di quota per sfruttare questa risorsa primaria, fondamentale per recuperare il peso perso in inverno e per supportare l'allattamento dei capretti.

### 2. Stress Idrico Estivo e Spostamento Altitudinale
La transizione verso il mese di **Agosto** rappresenta il punto di svolta ecologico, quantificato matematicamente tramite la mappa di differenza ($\Delta NDVI = Agosto - Maggio$). 
L'analisi mostra diffuse anomalie negative (colorazioni scure nella palette *magma*), concentrate soprattutto nelle fasce altitudinali inferiori e nei fondovalle stabili. Questo gradiente negativo indica un fenomeno di senescenza precoce e disseccamento dell'erba causato dallo stress termico estivo. 

Per lo stambecco, l'inaridimento del pascolo di bassa quota si traduce in una perdita drastica della qualità nutritiva (l'erba diventa legnosa e indigeribile). Inoltre, lo stambecco è un animale fortemente adattato al freddo, che manifesta segni di stress termico già sopra i 15 °C. La mappa di differenza giustifica spazialmente la **migrazione verticale obbligata**: l'animale abbandona i fondovalle inariditi per risalire verso le quote superiori e le aree vicine alle creste rocciose, dove la fusione tardiva dei nevai perenni mantiene attive piccole nicchie di pascolo fresco e idoneo anche in piena estate.

### 3. Eterogeneità Ambientale come Nicchia di Rifugio
La mappa finale dell'eterogeneità spaziale, calcolata mediante deviazione standard spaziale su una finestra mobile $3 \times 3$, rivela i pattern di frammentazione del paesaggio alpino in estate. Valori elevati di eterogeneità (aree luminose in palette *inferno*) si riscontrano in corrispondenza degli ecotoni geomorfologici, ovvero le zone di transizione dove le pareti rocciose scoscese e i ghiaioni si mescolano a frammenti di prateria alpina.

Dal punto di vista ecologico, queste zone ad alta eterogeneità rappresentano il perfetto **trade-off comportamentale** e la principale nicchia di rifugio estiva per lo stambecco:
1. **Termoregolazione e Sicurezza:** La vicinanza alle pareti di roccia verticale offre all'animale vie di fuga immediate dai predatori (come il lupo) e zone d'ombra fresca dove riposare durante le ore centrali e più calde della giornata.
2. **Alimentazione di precisione:** Le piccole chiazze di vegetazione incastonate tra i detriti rocciosi d'alta quota, seppur frammentate, sono protette dall'inaridimento di massa e forniscono il nutrimento necessario senza costringere l'animale a scendere a valle.

In conclusione, l'integrazione di indici spettrali come l'NDVI con metriche di variabilità spaziale (*focal standard deviation*) si dimostra uno strumento predittivo fondamentale per monitorare la perdita di idoneità degli habitat alpini causata dal global warming e per pianificare le strategie di conservazione delle specie sensibili d'alta quota.






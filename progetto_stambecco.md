# Analisi Multitemporale della fenologia del pascolo alpino: implicazioni ecologiche per lo stambecco (*Capra ibex*) nelle Dolomiti 🐐

## 📌 Introduzione e Obiettivi Ecologici
Il cambiamento climatico sta provocando profonde alterazioni negli ecosistemi d'alta quota, modificando i ritmi stagionali della vegetazione (*mismatch fenologico*). Questo progetto applica le tecniche di **Telerilevamento (Remote Sensing)** per monitorare la dinamica temporale e la struttura spaziale dei pascoli montani nel **Passo Falzarego (Dolomiti)** nel corso dell'anno 2020, utilizzando i dati del satellite **Sentinel-2**.

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

## 💻 Codice R
Il seguente script contiene l'intero lavoro commentato, dall'importazione dei dati del pacchetto `imageRy` fino alla generazione della cartografia finale in `ggplot2`.

### 1. Caricamento delle librerie necessarie
```r
library(terra)      # Gestione dei dati raster geografici
library(ggplot2)    # Visualizzazione grafica avanzata e mappatura
library(viridis)    # Palette cromatiche percettivamente uniformi
library(rasterdiv)  # Calcolo dell'eterogeneità spaziale 
library(imageRy)    # Database con dati e funzioni del corso
library(patchwork)  # Assemblaggio grafico multiframe per ggplot2
```

### 2. IMPORTAZIONE DEI DATI SATELITARI STAGIONALI (Sentinel-2 - Passo Falzarego)
```r
ndvi_feb <- im.import("Sentinel2_NDVI_2020-02-21.tif") # Inverno (Dormienza/Neve)
ndvi_mag <- im.import("Sentinel2_NDVI_2020-05-21.tif") # Primavera (Greening)
ndvi_ago <- im.import("Sentinel2_NDVI_2020-08-01.tif") # Estate (Picco/Siccità)
ndvi_nov <- im.import("Sentinel2_NDVI_2020-11-27.tif") # Autunno (Senescenza)

# Creazione del RasterStack multitemporale
punti_stagionali <- c(ndvi_feb, ndvi_mag, ndvi_ago, ndvi_nov)
names(punti_stagionali) <- c("Febbraio", "Maggio", "Agosto", "Novembre")

# Visualizzazione della serie fenologica stagionale
plot(punti_stagionali, col=viridis(100))
```

### 3. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (CAMBIAMENTO ESTIVO)
```r
diff_estate_primavera <- ndvi_ago - ndvi_mag
plot(diff_estate_primavera, col=magma(100), 
     main="Variazione dell'NDVI (Agosto vs Maggio)")
```

### 4. ANALISI DELLA DISTRIBUZIONE SPETTRALE TRAMITE ISTOGRAMMI
```r
im.multiframe(1, 2)
hist(ndvi_mag, main = "Distribuzione NDVI Maggio", col = "darkgreen", xlab = "Valori NDVI")
hist(ndvi_ago, main = "Distribuzione NDVI Agosto", col = "orange", xlab = "Valori NDVI")
dev.off() # Reset del pannello grafico
```

### 5. RICLASSIFICAZIONE IN CLASSI ESTRATTE E CALCOLO DELLE PERCENTUALI
```r
# Definizione delle matrici di soglia ecologica
matrice_classi <- matrix(c(-Inf, 0.2, 1, 
                           0.2, 0.5, 2, 
                           0.5, Inf, 3), ncol = 3, byrow = TRUE)

classi_mag <- classify(ndvi_mag, matrice_classi)
classi_ago <- classify(ndvi_ago, matrice_classi)

# Computazione delle frequenze relative percentuali
perc_mag <- freq(classi_mag)$count * 100 / ncell(classi_mag)
perc_ago <- freq(classi_ago)$count * 100 / ncell(classi_ago)

# Costruzione del dataframe per l'analisi statistica quantitativa
tabella_esame <- data.frame(
  Stato_Pascolo = c("Pascolo Degradato", "Pascolo Sano", "Roccia/Suolo Nudo"),
  Maggio_Perc = round(perc_mag, 2),
  Agosto_Perc = round(perc_ago, 2)
)
print(tabella_esame)
```

### 6. GENERAZIONE DEI GRAFICI COMPARATIVI CON GGPLOT2
```r
p1 <- ggplot(tabella_esame, aes(x = Stato_Pascolo, y = Maggio_Perc, fill = Stato_Pascolo)) +    
  geom_bar(stat = "identity") + scale_fill_viridis_d(option = "viridis") + ylim(0, 100) +
  labs(title = "Copertura a Maggio (Primavera)", y = "Percentuale (%)", x = NULL) + 
  theme_minimal() + theme(legend.position = "none")

p2 <- ggplot(tabella_esame, aes(x = Stato_Pascolo, y = Agosto_Perc, fill = Stato_Pascolo)) +
  geom_bar(stat = "identity") + scale_fill_viridis_d(option = "viridis") + ylim(0, 100) +
  labs(title = "Copertura ad Agosto (Estate)", y = "%", x = NULL) + theme_minimal()

p1 + p2
```

### 7. CALCOLO DELL'ETEROGENEITÀ SPAZIALE CON FINESTRA MOBILE 3x3
```r
eterogeneita_ago <- focal(ndvi_ago, w=matrix(1,3,3), fun=sd, na.rm=TRUE)

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

<img width="1536" height="738" alt="01_serie_stagionale" src="https://github.com/user-attachments/assets/bf7574cb-37fb-4eba-96c2-7cb7b1bd8567" />

### 2. Mappa di Rilevamento del Cambiamento ($\Delta NDVI$)
Sottrazione spettrale tra Agosto e Maggio. I toni scuri indicano le aree soggette a forte disseccamento estivo della risorsa trofica:

<img width="1536" height="738" alt="02_differenza_ndvi" src="https://github.com/user-attachments/assets/cb070c63-793c-4876-8488-ccbbe1c6d5ae" />

### 3. Istogrammi di Distribuzione Spettrale
Confronto delle frequenze dei pixel di NDVI, evidenziando lo shift e la ristrutturazione della popolazione dei pixel tra primavera ed estate:

<img width="1536" height="738" alt="04_istogrammi_confronto" src="https://github.com/user-attachments/assets/dd898a84-79fa-4eea-8432-327884d19443" />

### 4. Grafico di Copertura Percentuale Estratta
Come evidenziato dall'elaborazione statistica ggplot2, la ripartizione del territorio mostra un incremento netto del pascolo sano nel mese estivo dovuto alla deglaciazione delle vette:

<img width="1536" height="738" alt="05_barre_percentuali" src="https://github.com/user-attachments/assets/cb23114d-0516-47b6-9804-fa5750f37afd" />

### 5. Mappa Finale dell'Eterogeneità Spaziale
Grafico ad alta risoluzione generato con `ggplot2` che mappa la frammentazione ecologica locale (Deviazione Standard su finestra mobile $3 \times 3$):

<img width="1536" height="738" alt="03_eterogeneita_ggplot" src="https://github.com/user-attachments/assets/005b5b94-5041-4a4e-8b85-ad4d343ffcaf" />

---

## 🔢 Analisi Quantitativa ed Estrazione dei Dati
La riclassificazione computerizzata ha prodotto i seguenti risultati percentuali relativi alla ripartizione del territorio nelle due stagioni chiave:

| Stato del Pascolo Alpino | Copertura Maggio (%) | Copertura Agosto (%) | Variazione Netta (%) |
| :--- | :---: | :---: | :---: |
| **Pascolo Degradato / Stressato** | ~23% | ~11% | -12% |
| **Roccia / Suolo Nudo** | ~22% | ~11% | -11% |
| **Pascolo Sano / Rigoglioso** | **~51%** | **~75%** | **+24%** |

---

## 📈 Discussione e conclusioni ecologiche

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




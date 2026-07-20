# Analisi multitemporale della fenologia del pascolo alpino: implicazioni ecologiche per lo stambecco (*Capra ibex*) nelle Dolomiti 🐐

## 📌 Introduzione e obiettivi ecologici
Il cambiamento climatico sta provocando profonde alterazioni negli ecosistemi d'alta quota, modificando i ritmi stagionali della vegetazione. Questo progetto applica le tecniche di **Telerilevamento** per monitorare la dinamica temporale e la struttura spaziale dei pascoli montani nel **Passo Falzarego (Dolomiti)** nel corso dell'anno 2020, utilizzando i dati del satellite **Sentinel-2**.

L'obiettivo ecologico è mappare lo stress vegetativo estivo e la frammentazione paesaggistica per comprendere i pattern di movimento dello **Stambecco Alpino (*Capra ibex*)**. Lo stambecco è un erbivoro d'alta quota fortemente condizionato dalla qualità nutrizionale del pascolo. L'aumento delle temperature estive causa un precoce disseccamento della vegetazione a quote medio-basse, costringendo la specie a una migrazione verticale verso nicchie di rifugio climatico ad altitudini elevate, dove la fusione tardiva della neve garantisce erba fresca e digeribile.

<img width="640" height="425" alt="stambecco_1" src="https://github.com/user-attachments/assets/83246e42-8929-457f-a535-a25442d94362" />

---

## 🔬 Metodi e formulazione matematica

### 1. Indice di vegetazione (NDVI)
Per quantificare la biomassa e lo stato di salute della vegetazione nelle quattro stagioni, è stato utilizzato l'**NDVI (Normalized Difference Vegetation Index)**. L'indice sfrutta il comportamento spettrale delle foglie clorofilliane, che assorbono fortemente la radiazione nel rosso ($RED$) e riflettono quella nel vicino infrarosso ($NIR$):

$$NDVI = \frac{NIR - RED}{NIR + RED}$$

L'indice varia tra $-1$ e $+1$. Valori prossimi allo zero o negativi indicano superfici prive di vegetazione (neve, roccia nuda), mentre valori prossimi a $+1$ indicano massima vigoria vegetativa.

### 2. Algebra dei raster
Per misurare l'intensità del deperimento estivo del pascolo rispetto al picco primaverile, è stata applicata un'operazione di algebra dei raster di sottrazione tra il mese di Agosto ($NDVI_{ago}$) e il mese di Maggio ($NDVI_{mag}$):

$$\Delta NDVI = NDVI_{ago} - NDVI_{mag}$$

* Valori **negativi** indicano aree soggette a senescenza o stress idrico (perdita di vigoria).
* Valori **positivi** indicano un incremento della biomassa fogliare.

### 3. Classificazione ecologica del territorio
Per quantificare le risorse trofiche disponibili, i valori continui di NDVI sono stati suddivisi in tre classi ecologiche distinte tramite una matrice di riclassificazione:
* **Classe 1 (Roccia nuda / Suolo nudo):** NDVI < 0.2 (aree rocciose, detriti o neve residua).
* **Classe 2 (Pascolo degradato / Stressato):** 0.2 ≤ NDVI < 0.5 (vegetazione rada o in fase di stress idrico).
* **Classe 3 (Pascolo sano / Rigoglioso):** NDVI ≥ 0.5 (prateria alpina al picco della vigoria e biomassa).

### 4. Eterogeneità spaziale (deviazione standard)
L'eterogeneità dell'habitat è stata stimata calcolando la Deviazione Standard ($SD$) dell'NDVI estivo mediante una finestra mobile (moving window) di $3 \times 3$ pixel:

$$SD = \sqrt{\frac{\sum_{i=1}^{N}(x_i - \bar{x})^2}{N}}$$

Dove $x_i$ rappresenta il valore di NDVI del singolo pixel all'interno della finestra, $\bar{x}$ la media locale e $N$ il numero totale di pixel ($9$).

---

## 💻 Codice R 
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

Visualizziamo la lista dei dataset interni disponibili nel pacchetto
```r
im.list()
```

Importiamo i file raster (mappe) dell'NDVI del 2020 relativi al Passo Falzarego (Dolomiti)
```r
ndvi_feb <- im.import("Sentinel2_NDVI_2020-02-21.tif") # Inverno (Dormienza/Neve)
ndvi_mag <- im.import("Sentinel2_NDVI_2020-05-21.tif") # Primavera (Greening)
ndvi_ago <- im.import("Sentinel2_NDVI_2020-08-01.tif") # Estate (Picco/Siccità)
ndvi_nov <- im.import("Sentinel2_NDVI_2020-11-27.tif") # Autunno (Senescenza)
```

Creiamo il RasterStack multitemporale concatenando i singoli layer per visualizzare i dataset contemporaneamente (e rinominiamo i layer)
```r
punti_stagionali <- c(ndvi_feb, ndvi_mag, ndvi_ago, ndvi_nov)
names(punti_stagionali) <- c("Febbraio", "Maggio", "Agosto", "Novembre")
```

Visualizziamo la serie temporale completa con palette viridis
```r
plot(punti_stagionali, col=viridis(100))

# 01_serie_stagionale.png
```

### 3. ALGEBRA DEI RASTER: MAPPA DI DIFFERENZA (CAMBIAMENTO ESTIVO)
```r
# Applichiamo un'operazione di algebra dei raster sottraendo il pixel primaverile da quello estivo per evidenziare quantitativamente il viraggio o il disseccamento del pascolo
diff_estate_primavera <- ndvi_ago - ndvi_mag

# Plottiamo la differenza per vedere dove la vegetazione è aumentata o diminuita
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

# Reset del pannello grafico
dev.off() # Reset del pannello grafico
```

### 5. RICLASSIFICAZIONE E CALCOLO DELLE PERCENTUALI DI COPERTURA
```r
# Definiamo una matrice di riclassificazione basata su soglie ecologiche:
# Classe 1 (< 0.2): Roccia nuda / Suolo nudo
# Classe 2 (0.2 - 0.5): Pascolo degradato o fortemente stressato/secco
# Classe 3 (> 0.5): Pascolo sano, rigoglioso e ad alta vigoria
matrice_classi <- matrix(c(-Inf, 0.2, 1,
                           0.2, 0.5, 2,
                           0.5, Inf, 3), ncol = 3, byrow = TRUE)

# Riclassifichiamo i raster di Maggio e Agosto
classi_mag <- classify(ndvi_mag, matrice_classi)
classi_ago <- classify(ndvi_ago, matrice_classi)

# Estraiamo le frequenze
f_mag <- freq(classi_mag)
f_ago <- freq(classi_ago)

# Calcoliamo le percentuali escludendo i pixel NA dal totale
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

# Creiamo il rafico a barre raggruppate
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
# Creiamo la mappa di distribuzione dell'eterogeneità spaziale dell'NDVI
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

### 3. Confronto della distribuzione della biomassa vegetale tra il risveglio primaverile e il picco estivo
I due istogrammi seguenti mostrano la distribuzione di frequenza dei pixel per le diverse classi di valore NDVI nell'area del Passo Falzarego, mettendo a diretto confronto la situazione primaverile (Maggio) e quella estiva (Agosto):

<img width="1536" height="715" alt="04_istogrammi_confronto" src="https://github.com/user-attachments/assets/ec65b960-e236-454c-ba89-acc2a17257b5" />

---

* **Asse delle Ascisse (X - Valori NDVI):** Rappresenta i valori continui dell'indice NDVI, estesi da $-0.4$ a $0.85$. I valori inferiori a $0.2$ indicano superfici prive di vegetazione (roccia, neve, suolo nudo), mentre i valori superiori a $0.5$ indicano vegetazione densa e fotosinteticamente attiva.
* **Asse delle Ordinate (Y - Frequency):** Indica il numero di pixel (frequenza) presenti nella mappa per ciascun intervallo di NDVI. Entrambi gli istogrammi sono stati bloccati sul medesimo limite massimo ($65.000$ pixel) per garantire un confronto quantitativo e visivo immediato.
* **Verde Scuro (Maggio):** Simboleggia il risveglio vegetativo primaverile (*greening*).
* **Arancione (Agosto):** Rappresenta la fase di maturazione estiva e il picco di accumulo della biomassa.

---

#### 📊 Commento Statistico ed Ecologico

* **Distribuzione a Maggio (Primavera):** 
  * L'istogramma presenta una **distribuzione bimodale** o più dispersa.
  * Si osserva un primo picco significativo centrato attorno al valore $0.0$ (circa $18.000$ pixel), dovuto alla presenza di neve residua e suolo/roccia ancora scoperta ad alta quota.
  * Il secondo picco si colloca tra $0.5$ e $0.6$ (con una frequenza massima di circa $32.000$ pixel), rappresentando la porzione di pascolo che ha già avviato l'attività fotosintetica nei versanti più caldi.

* **Distribuzione ad Agosto (Estate):** 
  * Si assiste a uno spiccato **slittamento verso destra (shift positivo)** dell'intera curva di frequenza.
  * Il picco legato alla neve/roccia (attorno allo $0.0$) crolla quasi del tutto, testimoniando la completa fusione del manto nevoso.
  * Si forma una **fortissima concentrazione di pixel (modalità acuta)** nei valori alti dell'NDVI, precisamente tra $0.65$ e $0.75$, dove la frequenza supera i **$65.000$ pixel**. Questo picco rappresenta l'acme dello sviluppo fogliare e della biomassa del pascolo alpino.

* **Sintesi Ecologica:** Il confronto evidenzia quantitativamente la transizione della prateria da una fase eterogenea e parzialmente dormiente a Maggio verso una fase di omogeneità ad elevata attività fotosintetica ad Agosto.

### 4. Confronto percentuale delle classi di pascolo (Maggio vs Agosto)
Il grafico a barre seguente mostra la variazione percentuale delle tre classi ecologiche di copertura del suolo riclassificate a partire dai valori NDVI, mettendo a confronto il periodo primaverile (Maggio) e quello estivo (Agosto):

<img width="1536" height="715" alt="05_barre_percentuali" src="https://github.com/user-attachments/assets/09857ac9-e611-483f-8f4c-da1b8615dee0" />

---

* **Asse delle Ascisse (X - Tipologia di Copertura):** Riporta le tre categorie ecologiche determinate tramite riclassificazione:
  1. **Roccia/Suolo Nudo ($\text{NDVI} < 0.2$):** Superfici prive di vegetazione fotosinteticamente attiva o ancora innevate.
  2. **Pascolo Degradato ($\text{NDVI}$ tra $0.2$ e $0.5$):** Vegetazione scarseggiante, in fase iniziale di crescita o soggetta a stress/secchezza.
  3. **Pascolo Sano ($\text{NDVI} > 0.5$):** Prateria alpina densa, rigogliosa e in piena attività fotosintetica.
* **Asse delle Ordinate (Y - Percentuale sul totale %):** Esprime l'incidenza percentuale di ciascuna classe rispetto alla superficie totale analizzata.
  * **Verde Scuro (Maggio):** Stato delle coperture nella tarda primavera (fase di risveglio vegetativo).
  * **Arancione (Agosto):** Stato delle coperture nel pieno dell'estate (acme della biomassa).

---

#### 📊 Commento Quantitativo ed Ecologico

* **Riduzione di Roccia/Suolo Nudo:** 
  * A Maggio questa classe rappresenta circa il **23-24%** del territorio, a causa della presenza di chiazze di neve residua e ampie porzioni di suolo non ancora inattivo.
  * Ad Agosto la percentuale si dimezza, scendendo a circa l'**10-11%**, corrispondente alle sole pareti rocciose primarie ed esposte privabili di vegetazione.

* **Riduzione del Pascolo Degradato/Scarso:**
  * A Maggio attesta circa il **24%**, riflettendo una vegetazione che ha appena iniziato il ciclo di crescita e non ha ancora sviluppato una chioma densa.
  * Ad Agosto si riduce a circa l'**11%**, poiché la maggior parte della prateria transita verso la classe di massima vigoria.

* **Forte Espansione del Pascolo Sano:**
  * Passa da circa il **53-54%** a Maggio a quasi l'**80%** ad Agosto.
  * Questo incremento netto dimostra quantitativamente la risposta della prateria alpina all'innalzamento termico estivo e alla disponibilità di luce, che porta quasi i quattro quinti dell'area ad alte prestazioni fotosintetiche.

### 5. Eterogeneità spaziale dell'NDVI e analisi di frammentazione dell'habitat estivo per lo Stambecco (*Capra ibex*) nelle Dolomiti
La mappa seguente mostra la distribuzione dell'eterogeneità spaziale dell'NDVI, calcolata come Deviazione Standard locale tramite una finestra mobile focalizzata (focal/focal statistical analysis) durante il periodo estivo. L'analisi identifica la frammentazione del paesaggio e i margini di transizione nell'habitat dello stambecco:

<img width="1136" height="470" alt="03_eterogeneita_ggplot" src="https://github.com/user-attachments/assets/7b812826-0a02-421b-b809-c017a39198dd" />

---

La scala cromatica (palette *Inferno*) misura la variabilità locale dei valori di NDVI tra pixel adiacenti:

* **Tonalità Scure / Viola scuro e Nero (Bassa Deviazione Standard, $< 0.1$):** Indicano zone omogenee. Si tratta di aree uniformi dove i pixel vicini hanno valori di NDVI quasi identici:
  * Praterie contigue e dense al picco di biomassa (NDVI uniformemente alto).
  * Pareti rocciose o corpi d'acqua interni (NDVI uniformemente basso/nullo).
* **Tonalità Intermedie / Viola-Rosa e Magenta ($\approx 0.15$ a $0.25$):** Rappresentano zone a moderata variabilità, tipiche dei pascoli sparsi, dei conoidi di deiezione o dei margini tra vegetazione e roccia.
* **Tonalità Chiare / Arancione e Giallo brillante (Alta Deviazione Standard, $> 0.3$):** Evidenziano forti discontinuità spaziali e zone di ecotono (margini netti):
  * Il bordo del lago/bacino in alto a sinistra (netta transizione acqua-vegetazione).
  * I crestali, le scarpate e i canaloni rocciosi dove la roccia nuda si alterna a chiazze isolate di vegetazione alpina.

---

#### 📊 Commento Ecologico e Applicativo (Habitat dello Stambecco)

Le linee arancione/giallo tracciano i contorni netti tra pareti rocciose e praterie, evidenziando i margini di ecotono ad elevata eterogeneità spaziale. In estate, gli stambecchi prediligono proprio queste fasce di transizione: la diretta vicinanza tra le scarpate scoscese (usate come rifugio anti-predatorio) e il pascolo adiacente garantisce il bilanciamento ottimale tra alimentazione e sicurezza. Al contrario, le aree omogenee in viola scuro indicano ambienti meno idonei, poiché costituiti da soli pascoli aperti e privi di riparo o da pareti rocciose prive di risorse trofiche.

---

## 🔢 Tabella delle coperture stagionali
La tabella seguente riporta la ripartizione percentuale del territorio del Passo Falzarego nelle tre classi di vigoria vegetativa: 

| Stato Pascolo | Maggio (%) | Agosto (%) |
| :--- | :---: | :---: |
| **Roccia/Suolo Nudo** | 23.06 | 10.33 |
| **Pascolo Degradato** | 23.61 | 10.58 |
| **Pascolo Sano** | 53.33 | 79.09 |
| **Totale** | 100.00 | 100.00 |

#### 📈 Analisi dei Risultati Quantitativi

Dall'estrazione dei dati di riclassificazione emergono tre dinamiche principali:

* **Forte espansione del Pascolo Sano (+25.8%):** Rappresenta la variazione di maggiore impatto. Con l'innalzamento termico e il completamento del ciclo vegetativo, quasi i quattro quinti dell'intero territorio ($79.1\%$) raggiungono condizioni di elevata vigoria e densità fotosintetica ($\text{NDVI} > 0.5$).
* **Dimezzamento delle superfici prive di vegetazione (-12.8%):** La quota di territorio classificata come *Roccia / Suolo Nudo* scende dal $23.1\%$ di maggio al $10.3\%$ di agosto, come conseguenza diretta della fusione del manto nevoso residuo ad alta quota.
* **Maturazione del Pascolo Degradato (-13.0%):** Le aree a vegetazione rada o in fase iniziale di crescita si riducono dal $23.6\%$ al $10.6\%$. Tale contrazione è dovuta alla transizione di queste praterie verso la classe a massima biomassa (*Pascolo Sano*).

---

#### 💡 Sintesi Ecologica

Tra maggio e agosto si assiste a una netta **omogeneizzazione verso l'alto della qualità del pascolo**. La combinazione di disgelo e stabilità termica estiva converta oltre un quarto del paesaggio analizzato ($+25.8\%$) da superfici scoperte o a bassa biomassa in prateria alpina ad alto valore nutrizionale.

---

## 📈 Discussione e Conclusioni Ecologiche

L’analisi satellitari multitemporale ha permesso di mappare con precisione le dinamiche ambientali al Passo Falzarego, fornendo chiavi di lettura fondamentali per comprendere l'ecologia dello **Stambecco alpino** (*Capra ibex*). A differenza delle zone di pianura, in alta montagna l'estate non porta secchezza ma innesca un **risveglio vegetazionale tardivo**: tra maggio e agosto, con lo scioglimento della neve, la copertura a pascolo sano cresce dal 53,3% al 79,1%, riducendo le superfici rocciose e improduttive a poco più del 10%. Questa asincronia della vegetazione guida la migrazione estiva dello stambecco verso le quote elevate per un duplice motivo: da un lato l'animale segue la crescita di erba fresca ad alto valore nutrizionale, dall'altro evita lo stress termico (che insorge sopra i 15 °C) cercando il refrigerio dei crinali ventilati. L'analisi della variabilità spaziale (Deviazione Standard) dimostra inoltre che l'habitat di elezione dell'erbivoro si concentra negli ecotoni, ossia dove le praterie incontrano le pareti rocciose. Queste fasce di transizione garantiscono sia una via di fuga immediata dai predatori sia nicchie di pascolo di alta qualità, mantenute fresche dall'umidità residua del disgelo.
In conclusione, il telerilevamento si conferma uno strumento indispensabile per la tutela della fauna alpina. Permette di monitorare la qualità dell'habitat su ampie superfici senza disturbare gli animali, fornendo dati preziosi per pianificare la gestione della specie di fronte ai cambiamenti climatici.

<img width="1920" height="1280" alt="camera-man-capra-ibex-5948849_1920" src="https://github.com/user-attachments/assets/b8bb6ed5-f160-4714-8b55-bd179f145025" />


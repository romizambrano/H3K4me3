# H3K4me3 exhibits length-dependent deposition patterns at transcription initiation regions in *Trypanosoma cruzi* and correlates with transcriptional activity

## Overview

This repository contains the scripts and input data required to reproduce the analyses, figures, and supplementary tables associated with the manuscript.

The workflow identifies divergent and convergent strand switch regions (SSRs), defines directional gene clusters (DGCs), integrates H3K4me3 peak data, and generates the figures and supplementary materials reported in the study.

---

## Repository structure

```text
H3K4me3_analysis/
│
├── H3K4me3_analysis.Rproj
├── install_packages.R
├── run_all.R
│
├── scripts/
│   ├── 01_Load_DGCs_SSRs.R
│   ├── 02_Load_peaks.R
│   ├── 03_Boundaries_exporter.R
│   ├── 04_S1_Fig.R
│   ├── 05_S2_Fig.R
│   ├── 06_S2_Table.R
│   ├── 07_S3_FigB.R
│   ├── 08_S4_FigA.R
│   └── 09_S4_FigB_Violin.R
│
├── raw_data/
│   ├── Core_disrruptivo_Balouz_T2Tgenome.csv
│   ├── TcDm28cT2T_manualCurated.gff
│   │
│   └── H3K4me3/
│       ├── Epis_H3K4me3_1_IgG (narrow Peaks)].bed
│       ├── Epis_H3K4_me3_2_IgG (narrow Peaks)].bed
│       ├── Tryp_H3K4me3_1_igGc(narrow Peaks)].bed
│       └── Try_H3K4me3_2_IgG (narrow Peaks)].bed
│
└── output/
    ├── figures/
    │   ├── S1 Fig (peak locations).pdf
    │   ├── S2 Fig C (Epimastigote_vs_Trypomastigote_Average_Peaks).pdf
    │   ├── S3 Fig B (dSSR lengths).pdf
    │   ├── S4 Fig A.pdf
    │   └── S4 Fig B (dSSR lengths by compartment)_violin.pdf
    │
    ├── tables/
    │   └── S3 Table.xlsx
    │
    └── DGC_Boundaries/
        └── +10000/
```


---

## Requirements

* R (version 4.4 or later)
* RStudio (recommended)


---

## Running the analysis

1. Clone or download this repository.
2. Open `H3K4me3_analysis.Rproj` in RStudio.
3. Install the required packages:

```r
source("install_packages.R")
```

4. Run the complete workflow:

```r
source("run_all.R")
```

All figures, tables, and exported files will be generated automatically in the `output/` directory.

---

## Script description

| Script                   | Description                                                                                              |
| ------------------------ | -------------------------------------------------------------------------------------------------------- |
| 01_Load_DGCs_SSRs.R      | Loads genome annotation and identifies directional gene clusters (DGCs) and strand switch regions (SSRs) |
| 02_Load_peaks.R          | Loads H3K4me3 peak data and associates peaks with SSRs and DGCs                                          |
| 03_Boundaries_exporter.R | Exports DGC boundary annotations                                                                         |
| 04_S1_Fig.R              | Generates Supplementary Figure S1                                                                        |
| 05_S2_FigC.R              | Generates Supplementary Figure S2C                                                                        |
| 06_S2_Table.R            | Generates Supplementary Table S2                                                                         |
| 07_S3_FigB.R             | Generates Supplementary Figure S3B                                                                       |
| 08_S4_FigA.R             | Generates Supplementary Figure S4A                                                                       |
| 09_S4_FigB_Violin.R      | Generates Supplementary Figure S4B                                                                       |

```
```










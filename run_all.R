cat("\n01 - Loading DGCs and SSRs ----------------------\n")
source("scripts/01_Load_DGCs_SSRs.R")

cat("\n02 - Loading H3K4me3 peaks ----------------------\n")
source("scripts/02_Load_peaks.R")

cat("\n03 - Exporting DGC boundaries -------------------\n")
source("scripts/03_Boundaries_exporter.R")

cat("\n04 - Generating Supplementary Figure S1 ---------\n")
source("scripts/04_S1_Fig.R")

cat("\n05 - Generating Supplementary Figure S2 ---------\n")
source("scripts/05_S2_FigC.R")

cat("\n06 - Generating Supplementary Table S2 ----------\n")
source("scripts/06_S2_Table.R")

cat("\n07 - Generating Supplementary Figure S3B --------\n")
source("scripts/07_S3_FigB.R")

cat("\n08 - Generating Supplementary Figure S4A --------\n")
source("scripts/08_S4_FigA.R")

cat("\n09 - Generating Supplementary Figure S4B --------\n")
source("scripts/09_S4_FigB_Violin.R")

cat("\nAnalysis completed successfully! \n")
# ============================================================
# Install required packages
# Run this script once before executing the analysis pipeline
# ============================================================

packages <- c(
  "ape",
  "data.table",
  "dplyr",
  "stringr",
  "tidyr",
  "ggplot2",
  "ggtext",
  "writexl",
  "legendry",
  "ggsignif"
)

missing_packages <- packages[
  !packages %in% installed.packages()[, "Package"]
]

if (length(missing_packages) > 0) {
  
  message(
    "Installing packages: ",
    paste(missing_packages, collapse = ", ")
  )
  
  install.packages(missing_packages)
  
  message(
    "Successfully installed: ",
    paste(missing_packages, collapse = ", ")
  )
  
} else {
  
  message("All required packages are already installed.")
  
}

# Check for missing packages.
# If the output is character(0), all required packages are already installed.
setdiff(
  packages,
  rownames(installed.packages())
)

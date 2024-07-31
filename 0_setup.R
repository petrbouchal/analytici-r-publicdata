install.packages(c("czso", "statnipokladna", "dplyr", "tidyr", "forcats",
                   "lubridate", "RCzechia", "ggplot2", "readr"))

library(statnipokladna)
library(readr)
library(nanoparquet)
library(dplyr)

options(statnipokladna.dest_dir = "data-input/sp")

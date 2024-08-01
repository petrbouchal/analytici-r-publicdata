install.packages(c("czso", "statnipokladna", "dplyr", "tidyr", "forcats",
                   "ggiraph", "tmap",
                   "lubridate", "RCzechia", "ggplot2", "readr", "nanoparquet"))

library(statnipokladna)
library(readr)
library(nanoparquet)
library(dplyr)

options(statnipokladna.dest_dir = "data-input/sp")
options(czso.dest_dir = "data-input/czso")

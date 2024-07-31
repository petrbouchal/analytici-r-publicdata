library(czso)
library(statnipokladna)
library(dplyr)
library(ggplot2)
library(tidyr)
library(forcats)
library(ggiraph)
library(nanoparquet)


# Nastavení ---------------------------------------------------------------

# Kam se ukládají stažené soubory
options(statnipokladna.dest_dir = "data-input/sp")
options(czso.dest_dir = "data-input/czso")

# nepoužívat exponenciální zobrazení čísel
options(scipen = 99)

# Prozkoumat katalog ČSÚ --------------------------------------------------

czso_kat <- czso_get_catalogue()
czso_kat |>
  czso_filter_catalogue(c("vazba", "obec", "orp")) |>
  select(description, dataset_id, title)

czso_kat |>
  czso_filter_catalogue(c("struktura", "území")) |>
  select(description, dataset_id, title)

obce_cis <- czso_get_codelist("cis43")
obce_vaz_kraj <- czso_get_codelist("cis108vaz43")
orp_vaz_kraj <- czso_get_codelist("cis108vaz65")

obce_vaz_orp_centrum <- czso_get_codelist("cis43vaz65")
obce_vaz_orp <- czso_get_codelist("cis65vaz43")

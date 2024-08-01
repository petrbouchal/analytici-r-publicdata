library(czso)
library(statnipokladna)
library(dplyr)
library(tidyr)
library(nanoparquet)


# Nastavení ---------------------------------------------------------------

options(statnipokladna.dest_dir = "data-input/sp")
options(czso.dest_dir = "data-input/czso")

options(scipen = 99)

# Údaje o obcích  --------------------------------------------------

struktura_uzemi <- czso_get_table("struktura_uzemi_cr")

## Obce a jejich počty obyvatel  -----------------------------------------

obyv_obce0 <- czso_get_table("130149")

obyv_obce <- obyv_obce0 |>
  filter(uzemi_typ == "obec", obdobi == "2023-12-31",
         is.na(pohlavi_kod), is.na(vek_kod)) |>
  # Přejmenovat sloupce, abychom se v tom vyznali
  select(pocobyv = hodnota, obec_kod = uzemi_kod)

## Vybrat obce, které jsou sídlem ORP --------------------------------------

centra_orp <- struktura_uzemi |>
  filter(obec_kod == orp_sidlo_obec_kod)

## Načíst metadata organizací ve SP ----------------------------------------

orgs <- read_parquet("data-processed/orgs_proc.parquet")

# Slepit vše dohromady

dta <- rozp_mist |>
  sp_add_codelist(orgs, by = "ico") |>
  inner_join(centra_orp, by = join_by(zuj_id == obec_kod)) |>
  left_join(obyv_obce, by = join_by(zuj_id == obec_kod)) |>
  sp_add_codelist("polozka")

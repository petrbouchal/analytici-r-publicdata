library(statnipokladna)
library(readr)
library(nanoparquet)
library(dplyr)

options(statnipokladna.dest_dir = "data-input/sp")

orgs <- sp_get_codelist("ucjed")
write_parquet(orgs, "data-processed/orgs_raw.parquet")

orgs <- read_rds("data-processed/orgs_raw.rds")
orgs <- read_parquet("data-processed/orgs_raw.parquet")

orgs_proc <- orgs |>
  filter(start_date <= "2023-01-01", end_date >= "2023-12-31") |>
  sp_add_codelist("druhuj") |>
  sp_add_codelist("poddruhuj") |>
  filter(druhuj_nazev %in% c("Obce", "Dobrovolné svazky obcí", "Krajské úřady"))

write_parquet(orgs_proc, "data-processed/orgs_proc.parquet")

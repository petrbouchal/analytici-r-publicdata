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
options(czso.dest_dir = "data-input/czso")

# nepoužívat exponenciální zobrazení čísel
options(scipen = 99)

# Prozkoumat katalog ČSÚ --------------------------------------------------

# Otevřená data v katalogu ČSÚ:
# https://csu.gov.cz/otevrena-data-v-katalogu-produktu-csu?pocet=10&start=0&vlastnostiVystupu=22&pouzeVydane=true&razeni=-datumVydani

czso_kat <- czso_get_catalogue()
czso_kat |>
  czso_filter_catalogue(c("vazba", "obec", "orp")) |>
  select(description, dataset_id, title)

czso_get_catalogue(c("skot")) |> select(title, dataset_id, description)
czso_get_catalogue(c("hrubý domácí")) |> select(title, dataset_id, description)

czso_kat |>
  czso_filter_catalogue(c("struktura", "území")) |>
  select(description, dataset_id, title)

# Číselníky a další metainformace v databázi ČSÚ
# https://apl2.czso.cz/iSMS/

obce_cis <- czso_get_codelist("cis43")
obce_cis
obce_vaz_kraj <- czso_get_codelist("cis108vaz43")
obce_vaz_kraj
orp_vaz_kraj <- czso_get_codelist("cis108vaz65")
orp_vaz_kraj

obce_vaz_orp_centrum <- czso_get_codelist("cis43vaz65")
obce_vaz_orp_centrum
obce_vaz_orp <- czso_get_codelist("cis65vaz43")
obce_vaz_orp

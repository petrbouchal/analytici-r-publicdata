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

# Načíst rozpočtová data obcí za rok 2023 --------------------------------

rozp_mist <- sp_get_table("budget-local", year = 2023, month = 12)
colnames(rozp_mist)

# Údaje o obcích  --------------------------------------------------

struktura_uzemi <- czso_get_table("struktura_uzemi_cr")


## Obce a jejich počty obyvatel  -----------------------------------------

kkk |>
  czso_filter_catalogue(c("obyv", "obce")) |>
  select(description, title, dataset_id, )

# Načíst tuto sadu

obyv_obce0 <- czso_get_table("130149")

# Co znamenají položky?

czso_get_table_schema("130149")

# Pozor, obsahuje data za různé typy území

obyv_obce0 |>
  count(uzemi_cis, obdobi) |>
  spread(uzemi_cis, n)

# A taky věkový rozpad

obyv_obce0 |>
  count(vek_txt)

# Vyberme tedy jen to, co potřebujeme

obyv_obce <- obyv_obce0 |>
  filter(uzemi_cis == "43", obdobi == "2023-12-31",
         is.na(pohlavi_kod), is.na(vek_kod)) |>
# Přejmenovat sloupce, abychom se v tom vyznali
  select(pocobyv = hodnota, obec_kod = uzemi_kod)

## Vybrat obce, které jsou sídlem ORP --------------------------------------

struktura_sidla_orp <- struktura_uzemi |>
  filter(obec_kod == orp_sidlo_obec_kod)

## Načíst metadata organizací ve SP ----------------------------------------

orgs <- read_parquet("data-processed/orgs_proc.parquet")
names(orgs)

# Slepit vše dohromady

dta <- rozp_mist |>
  # funkce na správné přiřazení číselníku k datům SP
  sp_add_codelist(orgs, by = "ico") |>
  # připojíme číselník obcí ORP, necháme jen jejich data
  inner_join(struktura_sidla_orp, by = join_by(zuj_id == obec_kod)) |>
  # připojíme údaje o počty obyvatel
  left_join(obyv_obce, by = join_by(zuj_id == obec_kod)) |>
  # přidáme číselník druhového členění rozpočtové skladby
  sp_add_codelist("polozka")

names(dta)

# Jak se dobrat daně z nemovitosti? ---------------------------------------

dta |>
  filter(druhuj_nazev == "Obce", trida == "Daňové příjmy") |>
  count(polozka_nazev)


# Ha! ---------------------------------------------------------------------

ggg <- dta |>
  filter(polozka_nazev == "Příjem z daně z nemovitých věcí", druhuj_nazev == "Obce") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending/pocobyv, kraj_text)) +
  geom_jitter_interactive(aes(tooltip = obec_text, colour = pocobyv)) +
  scale_color_viridis_b(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  guides() +
  geom_boxplot_interactive(outliers = FALSE)

ggg

girafe(ggobj = ggg)


gga <- dta |>
  filter(polozka_nazev == "Příjem z daně z nemovitých věcí") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending/pocobyv, pocobyv/1000))+
  geom_point_interactive(aes(tooltip = obec_text), alpha = .4) +
  scale_y_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 4, base = 10))

girafe(ggobj = gga)

ggb <- dta |>
  filter(polozka_nazev == "Příjem z daně z nemovitých věcí") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending/pocobyv, pocobyv/1000))+
  geom_point_interactive(aes(tooltip = obec_text), alpha = .4) +
  scale_y_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 4, base = 10)) +
  facet_wrap(~kraj_text)

girafe(ggobj = ggb)

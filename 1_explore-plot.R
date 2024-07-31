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

# Načíst rozpočtová data obcí za rok 2023 --------------------------------

sp_tables

rozp_mist <- sp_get_table("budget-local", year = 2023, month = 12)
colnames(rozp_mist)
skimr::skim(rozp_mist)

# Údaje o obcích  --------------------------------------------------

struktura_uzemi <- czso_get_table("struktura_uzemi_cr")

## Obce a jejich počty obyvatel  -----------------------------------------

czso_kat <- czso_get_catalogue()

czso_kat |>
  czso_filter_catalogue(c("obyv", "obce")) |>
  select(title, description, dataset_id)

# Načíst tuto sadu

obyv_obce0 <- czso_get_table("130149")

# Co znamenají položky?

czso_get_table_schema("130149")

# Pozor, obsahuje data za různé typy území

skimr::skim(obyv_obce0)

obyv_obce0 |>
  count(uzemi_cis, obdobi) |>
  spread(uzemi_cis, n)

obyv_obce0 |>
  count(uzemi_typ)

# A taky věkový rozpad

obyv_obce0 |>
  count(vek_txt)

# Vyberme tedy jen to, co potřebujeme

obyv_obce <- obyv_obce0 |>
  filter(uzemi_typ == "obec", obdobi == "2023-12-31",
         is.na(pohlavi_kod), is.na(vek_kod)) |>
# Přejmenovat sloupce, abychom se v tom vyznali
  select(pocobyv = hodnota, obec_kod = uzemi_kod)

## Vybrat obce, které jsou sídlem ORP --------------------------------------

centra_orp <- struktura_uzemi |>
  filter(obec_kod == orp_sidlo_obec_kod)

## Načíst metadata organizací ve SP ----------------------------------------

# Ty jsou předpřipravané, viz 00_preprocess.R
# obsahují jen obce platné v roce 2023

orgs <- read_parquet("data-processed/orgs_proc.parquet")
names(orgs)

# Slepit vše dohromady

dta <- rozp_mist |>
  # funkce na správné přiřazení číselníku k datům SP
  sp_add_codelist(orgs, by = "ico") |>
  # připojíme číselník obcí ORP, necháme jen jejich data
  inner_join(centra_orp, by = join_by(zuj_id == obec_kod)) |>
  # připojíme údaje o počty obyvatel
  left_join(obyv_obce, by = join_by(zuj_id == obec_kod)) |>
  # přidáme číselník druhového členění rozpočtové skladby
  sp_add_codelist("polozka")

names(dta)

length(unique(dta$ico))

# Jak se dobrat daně z nemovitosti? ---------------------------------------

dta |>
  distinct(druh, trida)

dta |>
  distinct(druh, seskupeni)

dta |>
  filter(trida == "Daňové příjmy", seskupeni == "Příjem z majetkových daní") |>
  distinct(podseskupeni, polozka_nazev, polozka)

# Ha! ---------------------------------------------------------------------

## Jak to vypadá? ---------------------------------------------------------

dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending, kraj_text)) +
  geom_jitter_interactive(aes(tooltip = obec_text)) +
  scale_color_viridis_b(breaks = scales::breaks_log(n = 8, base = 10)) +
  guides() +
  geom_boxplot(outliers = FALSE)

dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending, kraj_text)) +
  geom_jitter_interactive(aes(tooltip = obec_text)) +
  scale_color_viridis_b(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  guides() +
  geom_boxplot(outliers = FALSE)

dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending, kraj_text)) +
  geom_jitter(aes(colour = pocobyv)) +
  scale_color_viridis_b(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  guides() +
  geom_boxplot(outliers = FALSE)

dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(pocobyv, budget_spending))+
  geom_point(alpha = .4)

dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(pocobyv/1000, budget_spending))+
  geom_point(alpha = .4) +
  scale_y_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 4, base = 10))

p_boxplot <- dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(budget_spending/pocobyv, kraj_text)) +
  geom_jitter_interactive(aes(tooltip = obec_text, colour = pocobyv)) +
  scale_color_viridis_b(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  guides() +
  geom_boxplot_interactive(outliers = FALSE)

p_boxplot

girafe(ggobj = p_boxplot)


p_dotplot <- dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(pocobyv/1000, budget_spending/pocobyv))+
  geom_point_interactive(aes(tooltip = obec_text), alpha = .4) +
  scale_y_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 4, base = 10))

girafe(ggobj = p_dotplot)

p_dotplot_facet <- dta |>
  filter(polozka == "1511") |>
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |>
  ggplot(aes(pocobyv/1000, budget_spending/pocobyv))+
  geom_point_interactive(aes(tooltip = obec_text), alpha = .4) +
  scale_y_log10(breaks = scales::breaks_log(n = 8, base = 10)) +
  scale_x_log10(breaks = scales::breaks_log(n = 4, base = 10)) +
  facet_wrap(~kraj_text)

girafe(ggobj = p_dotplot_facet)

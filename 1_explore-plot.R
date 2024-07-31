library(czso)
library(statnipokladna)
library(dplyr)
library(ggplot2)
library(tidyr)
library(forcats)
library(ggiraph)

kkk <- czso_get_catalogue()
kkk |> 
  czso_filter_catalogue(c("vazba", "obec", "orp")) |> 
  select(description, dataset_id, title)

kkk |> 
  czso_filter_catalogue(c("struktura", "území")) |> 
  select(description, dataset_id, title)

kkk |> 
  czso_filter_catalogue(c("obyv", "obce")) |> 
  select(description, title, dataset_id, )

obyv_obce <- czso_get_table("130149") |> 
  filter(uzemi_cis == "43", obdobi == "2023-12-31", 
         is.na(pohlavi_kod), is.na(vek_kod))


obce_cis <- czso_get_codelist("cis43")
obce_vaz_kraj <- czso_get_codelist("cis108vaz43")
orp_vaz_kraj <- czso_get_codelist("cis108vaz65")

obce_vaz_orp_centrum <- czso_get_codelist("cis43vaz65")
obce_vaz_orp <- czso_get_codelist("cis65vaz43")

struktura_uzemi <- czso_get_table("struktura_uzemi_cr")

rozp_mist <- sp_get_table("budget-local", year = 2023, month = 12)

# srovnat variabilitu příjmu DzN v obcích všech ORP JČ kraje
# srovnat variabilitu příjmu DzN v centrech ORP podle kraje


struktura_sidla_orp <- struktura_uzemi |> 
  filter(obec_kod == orp_sidlo_obec_kod)

orgs <- readRDS("data-processed/orgs_raw.rds")

dta <- rozp_mist |>
  select(-kraj) |> 
  sp_add_codelist(orgs) |>
  sp_add_codelist("druhuj") |> 
  sp_add_codelist("poddruhuj") |> 
  left_join(struktura_sidla_orp, by = join_by(zuj_id == obec_kod)) |> 
  left_join(obyv_obce |> select(pocobyv = hodnota, zuj_id = uzemi_kod)) |> 
  sp_add_codelist("polozka")

dta |> 
  count(druhuj_nazev)
  
dta |> 
  count(trida)

names(dta)

dta |> 
  filter(trida == "Daňové příjmy") |> 
  count(druhuj_nazev, polozka_nazev)

ggg <- dta |> 
  filter(polozka_nazev == "Příjem z daně z nemovitých věcí", druhuj_nazev == "Obce") |> 
  drop_na(kraj_text) |> 
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |> 
  ggplot(aes(budget_spending/pocobyv, kraj_text)) +
  geom_jitter_interactive(aes(tooltip = obec_text, colour = log(pocobyv))) +
  scale_color_viridis_c() +
  # scale_x_log10() +
  geom_boxplot_interactive()

girafe(ggobj = ggg)


dta |> 
  filter(polozka_nazev == "Příjem z daně z nemovitých věcí", druhuj_nazev == "Obce") |> 
  drop_na(kraj_text) |> 
  mutate(kraj_text = as.factor(kraj_text) |> fct_reorder(budget_spending / pocobyv)) |> 
  ggplot(aes(budget_spending/pocobyv, pocobyv))+
  geom_point() +
  scale_y_log10()

orgs_proc <- readRDS("data-processed/orgs_proc.rds")

dta2 <- rozp_mist |> 
  select(-kraj) |> 
  sp_add_codelist(orgs_proc, by = "ico")

dta2 |> 
  count(druhuj_nazev)

orgs_proc |> 
  count(druhuj_nazev)

table(dta$ico %in% orgs_proc$ico)

skimr::skim(dta2)

debug(sp_add_codelist)

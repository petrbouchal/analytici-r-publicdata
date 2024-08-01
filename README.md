# R workshop pro analytiky: jak na veřejná data

Tento repozitář obsahuje podklady pro workshop o veřejných datech v R:

- kód pro práci - ke stažení na <https://github.com/petrbouchal/analytici-r-publicdata/archive/refs/heads/main.zip> resp. <https://github.com/petrbouchal/analytici-r-publicdata/>
- část předpřipravených vstupních dat
- slidy - quarto zdroj a HTML výstup, který se ukazuje na <https://petrbouchal.xyz/analytici-r-publicdata/>

Co dělají které soubory:

- 00_preprocess.R: předpřipravuje podmnožinu dat, která by trvala příliš dlouho (číselník organizací) při workshopu. Není třeba pouštět.
- data-processed/orgs_proc.parquet: předpřipravený číselník organizací
- 0_setup.R: instalace potřebných balíků
- 1_explorace.R: kód na zkoušení hledání v katalogu a načtení dat ČSÚ
- 2_ukol.R: skript i s komentáři pro řešení ukázkového úkolu
- 2_ukol.qmd: totéž ve formě Quarto dokumentu - [vygenerovaná verze online](https://petrbouchal.xyz/analytici-r-publicdata/2_ukol.html)
- 3_ukol-usporne.R: úkol bez komentářů a náhledů dat
- 4_eurostat.R: řešení úkolu k mezinárodnímu srovnání
- index.qmd: zdrojový soubor slides

Balíčky jsou zachyceny v `renv.lock`, ale systém renv je vypnutý. Lze zapnout pomocí `renv::activate()` a následně `renv::restore()`.

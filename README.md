# Demo: commons over a replication package

A working [commons](https://opensource.posit.co/blog/2026-09-15_commons-0-1-0/) agent whose
trusted measures **are** a published paper's own analysis, and whose context is the paper.

## Run it

```r
# one-off setup
install.packages("estimatr")
pak::pak("posit-dev/commons/pkg-r")
install.packages("duckdb", repos = "https://duckdb.r-universe.dev")  # see Gotchas

cp .Renviron.example .Renviron   # then add your ANTHROPIC_API_KEY

Rscript verify_measures.R        # confirms measures == published Table 1
shiny::runApp("app.R")
```

## The paper

"Black Workers in White Places: Daytime Racial Diversity and White Public Opinion",
*Journal of Politics*. Chosen because the package is small (10 MB), pure R, entirely
self-contained (`.RData`, no external downloads), and independently verified — it is a
gold-score-4 instance in [REPRO-Bench](https://arxiv.org/abs/2507.18901), and the JOP
replication analyst verified it at publication.

**It is political science, not economics.** For this demo the discipline is
irrelevant — what matters is that the package runs unattended. Swapping in an econ paper
is a matter of rewriting `measures/` and `context/`.

## What is wired up

| commons concept | what it is here |
|---|---|
| data source | `dta` — 166,180 CCES respondent-years merged to zip-code workplace and residence characteristics |
| data dictionary | `data-dict.yaml` — column meanings, with the traps spelled out |
| semantic layer | `measures/table1.R` — 3 measures, the paper's own Table 1 specifications |
| context layer | `context/paper.md` — the argument, what Table 1 reports, and the variables that are easy to misread |

The measures are the point. `fit_table1_model()` is the paper's specification copied from
`an_main.R` without alteration: same outcome, same 16 covariates, same whites-only
subsample, same zip-code clustering, same Stata-style SEs. `verify_measures.R` refits each
one longhand from the original script and asserts the coefficients and N match:

```
president              coef -0.001571  se 0.000323  n  54098  matches paper
house                  coef -0.001363  se 0.000318  n  74852  matches paper
racial_resentment      coef +0.004755  se 0.000838  n  88055  matches paper
affirmative_action     coef +0.003180  se 0.000629  n  98752  matches paper
```

That check is the whole basis of the trust label. If it ever fails, the green shield in the
app is a lie, and the agent is quietly answering with a different model than the one in the
journal.

## Questions that make the point

Ask these in the app. The first three should route to a trusted measure; the last two
should not, and the interesting part is whether the agent says so rather than guessing.

- *What is the effect of racial flux on presidential vote?* → `racial_flux_effect`.
- *Show me Table 1.* → `table1`.
- *How many respondents is this estimated on?* → `analysis_sample`. The honest answer is
  54,098 for the presidential model, not the 166,180 rows in the data frame — the models
  are whites-only and the outcomes have different missingness. An agent reading the raw
  script has to notice a `filter(white == 1)` buried inside a call to get this right.
- *Does racial flux cause white voters to become more conservative?* → no measure covers
  this. The context layer says the design is observational.
- *What happens if you drop the resident percent-Black control?* → no measure covers this
  either. It is a different specification from the published one, and the agent should say
  so before computing anything.

## Gotchas

- **duckdb.** Dev `commons` calls `duckdb::duckdb(shared_home = FALSE, ...)`, which CRAN
  duckdb 1.5.4.2 does not accept — it fails with `... must be empty`. Install duckdb from
  `https://duckdb.r-universe.dev` (1.5.5.9023+).
- **commons version.** CRAN `commons` is 0.0.1 and exports only three functions, with no
  `context_layer` or `commons_app`. You need the dev build from `posit-dev/commons/pkg-r`
  (0.1.0.9000) for the API in the blog post.
- **`data_source()` takes frames in `...`,** not in `tables =`.
- **Data is gitignored.** `data/` holds a third-party replication package with no clear
  redistribution licence. It is not committed. Re-fetch it from the REPRO-Bench dataset
  (`huggingface.co/datasets/chuxuan/REPRO-Bench`, instance 4) — and note the full dataset
  is ~183 GB, so pull the single instance over the HTTP API rather than cloning.

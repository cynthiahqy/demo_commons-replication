# Paper context

"Black Workers in White Places: Daytime Racial Diversity and White Public Opinion",
*Journal of Politics* short article. Replication files are in the JOP Dataverse, and
the empirical analysis was verified by the JOP replication analyst.

## The argument

Research on racial context usually measures context by *residents*. That ignores how a
place's composition changes during the day, when non-resident workers are present. The
paper introduces a zip code-level measure, **racial flux**, capturing Black workers
relative to Black residents in a zip code, and merges it with Cooperative Congressional
Election Study (CCES) survey data.

Finding: greater racial flux is associated with more conservative voting behaviour and
racial attitudes among whites who live in that zip code. Whites appear politically
responsive to non-resident minorities much as they are to resident minorities.

## What Table 1 reports

Four OLS models, each regressing one outcome on racial flux plus 16 covariates,
estimated on **whites only**, with standard errors clustered by zip code
(Stata-style). The four outcomes are:

| column | outcome variable | meaning |
|---|---|---|
| President | `pres_dem` | voted Democratic for president |
| U.S. House | `house_dem` | voted Democratic for U.S. House |
| Racial Resentment | `mean_rr` | racial resentment scale |
| Affirmative Action | `affirm` | support for affirmative action |

## Variables that are easy to misread

- `racial_flux` — the paper's constructed measure: Black *workers* relative to Black
  *residents* in a zip code. It is not a count, and not a share of the population. It is
  built by merging workplace-area characteristics against residence-area characteristics.
- `wac_pct_black` — percent Black among **workers** in the zip code (workplace area).
- `rac_pct_black` — percent Black among **residents** in the zip code (residence area).
- `pct_black` — resident percent Black, used as a control **separately** from racial flux,
  so that flux is not just picking up resident composition.
- `white` — respondent is white. Every Table 1 model is fit on `white == 1` only. The
  full data frame has many more rows than the analysis sample.
- Higher `pres_dem` / `house_dem` means voting Democratic, so a negative racial flux
  coefficient means flux is associated with **more conservative** voting.

## Scope

The analysis is observational and zip code-level. It supports associational claims about
racial flux and white opinion, not causal identification of a treatment effect.

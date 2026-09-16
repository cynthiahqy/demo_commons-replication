# Checks that every trusted measure reproduces the paper's own estimate.
#
# This is the whole basis of the "trusted" label: if these stop matching
# `data/an_main.R.original`, the measures are no longer the published analysis
# and the green shield in the app would be a lie.

suppressMessages({library(estimatr); library(dplyr)})
load("data/dta.RData")
source("measures/table1.R")

outcomes <- c(pres_dem = "president", house_dem = "house",
              mean_rr = "racial_resentment", affirm = "affirmative_action")

ok <- TRUE
for (v in names(outcomes)) {
  # The paper's specification, written out longhand exactly as in an_main.R.
  f <- as.formula(paste(v, "~ racial_flux + pid7 + ideo5 + female + age + faminc",
    "+ educ + pct_white + pct_black + pct_unemployed + pct_college",
    "+ log_per_cap_inc + gini + south + non_rural + log_pop_density"))
  orig <- lm_robust(f, data = dta %>% filter(white == 1),
                    clusters = zipcode, se_type = "stata")
  mine <- fit_table1_model(dta, v)

  same <- isTRUE(all.equal(coef(orig), coef(mine))) && orig$nobs == mine$nobs
  ok <- ok && same
  cat(sprintf("%-22s coef %+0.6f  se %0.6f  n %6d  %s\n",
              outcomes[[v]],
              coef(mine)[["racial_flux"]],
              summary(mine)$coefficients["racial_flux", "Std. Error"],
              mine$nobs,
              if (same) "matches paper" else "DIVERGES"))
}
cat("\n", if (ok) "All measures reproduce the published Table 1.\n"
         else "MISMATCH - measures are not the published analysis.\n", sep = "")
if (!ok) quit(status = 1)

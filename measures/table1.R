# Trusted measures for the replication package.
#
# Every model below is the paper's own Table 1 specification, copied from the
# authors' `an_main.R` without alteration: same outcome, same 16 covariates,
# same whites-only subsample, same zip-code clustering, same Stata-style SEs.
# That is what makes them trusted — an answer routed through these functions is
# the published estimate, not something the agent re-derived.

flux_controls <- paste(
  "racial_flux + pid7 + ideo5 + female + age + faminc + educ +",
  "pct_white + pct_black + pct_unemployed + pct_college +",
  "log_per_cap_inc + gini + south + non_rural + log_pop_density"
)

fit_table1_model <- function(dta, outcome) {
  f <- stats::as.formula(paste(outcome, "~", flux_controls))
  estimatr::lm_robust(
    f,
    data = dta[dta$white == 1, ],
    clusters = zipcode,
    se_type = "stata"
  )
}

tidy_flux <- function(m, outcome, label) {
  s <- summary(m)$coefficients
  data.frame(
    outcome        = label,
    term           = "racial_flux",
    estimate       = unname(s["racial_flux", "Estimate"]),
    std_error      = unname(s["racial_flux", "Std. Error"]),
    p_value        = unname(s["racial_flux", "Pr(>|t|)"]),
    conf_low       = unname(s["racial_flux", "CI Lower"]),
    conf_high      = unname(s["racial_flux", "CI Upper"]),
    observations   = m$nobs,
    stringsAsFactors = FALSE
  )
}

#' Racial flux effect on a Table 1 outcome
#'
#' Returns the published coefficient on racial flux for one of the four
#' outcomes in Table 1, with the paper's clustered standard errors.
#'
#' @param outcome `string` One of "president", "house", "racial_resentment",
#'   "affirmative_action".
#' @measure
racial_flux_effect <- function(hamel, outcome) {
  map <- c(
    president          = "pres_dem",
    house              = "house_dem",
    racial_resentment  = "mean_rr",
    affirmative_action = "affirm"
  )
  outcome <- match.arg(outcome, names(map))
  dta <- dplyr::collect(dplyr::tbl(hamel, "dta"))
  tidy_flux(fit_table1_model(dta, map[[outcome]]), map[[outcome]], outcome)
}

#' Full Table 1
#'
#' Reproduces all four columns of Table 1 — the racial flux coefficient for
#' presidential vote, U.S. House vote, racial resentment, and affirmative
#' action — in one call.
#'
#' @measure
table1 <- function(hamel) {
  dta <- dplyr::collect(dplyr::tbl(hamel, "dta"))
  outcomes <- c(
    president          = "pres_dem",
    house              = "house_dem",
    racial_resentment  = "mean_rr",
    affirmative_action = "affirm"
  )
  do.call(rbind, lapply(names(outcomes), function(nm) {
    tidy_flux(fit_table1_model(dta, outcomes[[nm]]), outcomes[[nm]], nm)
  }))
}

#' Analysis sample size
#'
#' The number of respondents the paper actually analyses, which is the
#' whites-only subsample, not the full CCES extract.
#'
#' @measure
analysis_sample <- function(hamel) {
  dta <- dplyr::collect(dplyr::tbl(hamel, "dta"))
  data.frame(
    all_respondents   = nrow(dta),
    white_respondents = sum(dta$white == 1, na.rm = TRUE),
    zip_codes         = length(unique(dta$zipcode[dta$white == 1])),
    years             = paste(sort(unique(dta$year)), collapse = ", "),
    stringsAsFactors  = FALSE
  )
}

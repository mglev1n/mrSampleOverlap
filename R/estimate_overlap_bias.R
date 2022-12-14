# WARNING - Generated by {fusen} from /dev/estimate_overlap_bias.Rmd: do not edit by hand

#' Estimate bias due to sample overlap
#'
#' @param samplesize_exposure (numeric) Sample size of population used to define genetic instrument for the exposure of interest
#' @param samplesize_outcome (numeric) Sample size of population used for the outcome of interest
#' @param n_variants (numeric) Number of genetic variants included in genetic instrument for the exposure of interest
#' @param rsq_exposure (numeric) \eqn{R^2} value (coefficient of determination) of genetic instrument for the exposure of interest; used to estimate F-statistic
#' @param exp_f (numeric; optional) F-statistic for the genetic instrument (if provided, this value will be used, rather than an estimate based on the \eqn{R^2})
#' @param lci_95 (logical; default = FALSE) If TRUE, the function will return estimates of bias and type 1 error based on the lower limit of the one-sided 95% confidence interval of the F-statistic, which may represent a more conservative/less optimistic estimate of bias
#' @param case_prop (numeric; optional) Proportion of cases (eg. cases/total samplesize) if outcome is binary
#' @param ols_bias (numeric) Observational (biased) effect estimate (if known); otherwise, provide a hypothetical value
#' @param overlap_prop (numeric; range = 0 to 1) Proportion of overlapping samples between exposure and outcome studies (if known); otherwise, provide a hypothetical value
#' @param var_x (numeric) Variance in the exposure; default is 1 when the exposure is reported in standard deviation units
#' @param var_y (numeric) Variance in the exposure; default is 1 when the exposure is reported in standard deviation units
#'
#' @import dplyr
#' @importFrom stats pnorm
#'
#' @return A [tibble][tibble::tibble-package] containing columns for the bias and type1_error
#' @export
#'
#' @examples
#' # Binary outcome
#' estimate_overlap_bias(
#'   samplesize_exposure = 361194,
#'   samplesize_outcome = 1125328,
#'   case_prop = 0.035,
#'   rsq_exposure = 0.068,
#'   n_variants = 196,
#'   ols_bias = 0.2,
#'   overlap_prop = 0.3
#' )
#' 
#' # Continuous outcome
#' estimate_overlap_bias(
#'   samplesize_exposure = 361194,
#'   samplesize_outcome = 1125328,
#'   rsq_exposure = 0.068,
#'   n_variants = 196,
#'   ols_bias = 0.2,
#'   overlap_prop = 0.3
#' )
estimate_overlap_bias <- function(samplesize_exposure, samplesize_outcome, n_variants, rsq_exposure, exp_f = NULL, lci_95 = FALSE, case_prop = 0, ols_bias, overlap_prop, var_x = 1, var_y = 1) {
  # adapted from Burgess et. al. (2016) PMID: 27625185

  if (!is.null(exp_f)) {
    expf <- exp_f
  } else {
    expf <- estimate_f(samplesize_exposure, n_variants, rsq_exposure, lci_95)
  }

  if (case_prop == 0) {
    var <- var_y / (samplesize_outcome * var_x * rsq_exposure)
  } else {
    var <- 1 / (samplesize_outcome * rsq_exposure * var_x * case_prop * (1 - case_prop))
  }

  bias <- ols_bias * overlap_prop * (1 / expf)

  type1_error <- 2 - pnorm(1.96 + bias / sqrt(var)) - pnorm(1.96 - bias / sqrt(var))

  return(tibble(bias = bias, type1_error = type1_error))
}

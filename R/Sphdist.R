#' Spherical Empirical Distribution
#'
#' This function calculates the empirical distribution of the pivotal random
#' variable that can be used to perform the Sphericity test of the population covariance matrix
#' \eqn{\boldsymbol{\Sigma}} that is \eqn{\boldsymbol{\Sigma} = \sigma^2 \mathbf{I}_p},
#' based on the released Single Synthetic data generated under Plug-in Sampling,
#' assuming that the original dataset is normally distributed.
#'
#' We define
#' \deqn{T_2^\star = \frac{|\boldsymbol{S}^{\star}|^{\frac{1}{p}}}{tr(\boldsymbol{S}^{\star})/p}}
#' where \eqn{\boldsymbol{S}^\star = \sum_{i=1}^n (v_i - \bar{v})(v_i - \bar{v})^{\top}},
#' \eqn{v_i} is the \eqn{i}th observation of the synthetic dataset.
#' For \eqn{\boldsymbol{\Sigma} = \sigma^2 \mathbf{I}_p}, its distribution is
#' stochastic equivalent to
#' \deqn{\frac{|\boldsymbol{\Omega}_{1}\boldsymbol{\Omega}_{2}|^{\frac{1}{p}}}{tr(\boldsymbol{\Omega}_{1}\boldsymbol{\Omega}_{2})/p}}
#' where \eqn{\boldsymbol{\Omega}_1} and \eqn{\boldsymbol{\Omega}_2} are
#' Wishart random variables,
#' \eqn{\boldsymbol{\Omega}_1 \sim \mathcal{W}_p(n-1, \frac{\mathbf{I}_p}{n-1})}
#' is independent of \eqn{\boldsymbol{\Omega}_2 \sim \mathcal{W}_p(n-1, \mathbf{I}_p)}.
#' To test \eqn{\mathcal{H}_0: \boldsymbol{\Sigma} = \sigma^2 \mathbf{I}_p}, compute the observed value of
#' \eqn{T_{2}^\star}, \eqn{\widetilde{T_{2}^\star}},  with the observed values
#' and reject the null hypothesis if
#' \eqn{\widetilde{T_{2}^\star}>t^\star_{2,\alpha}}
#' for \eqn{\alpha}-significance level, where \eqn{t^\star_{2,\gamma}}
#' is the \eqn{\gamma}th percentile of \eqn{T_2^\star}.
#'
#' @param nsample Sample size.
#' @param pvariates Number of variables.
#' @param iterations Number of iterations for simulating values from the
#'  distribution and finding the quantiles. Default is \code{10000}.
#'
#' @return a vector of length \code{iterations} that recorded the empirical distribution's values.
#'
#' @references
#' Klein, M., Moura, R. and Sinha, B. (2021). Multivariate Normal Inference based on Singly Imputed Synthetic Data under Plug-in Sampling. Sankhya B 83, 273–287.
#' @importFrom stats rWishart
#'
#' @examples
#'# Original data created
#'library(MASS)
#'mu <- c(1,2,3,4)
#'Sigma <- matrix(c(1, 0, 0, 0,
#'                   0, 1, 0, 0,
#'                   0, 0, 1, 0,
#'                   0, 0, 0, 1), nrow = 4, ncol = 4, byrow = TRUE)
#' seed = 1
#' n_sample = 100
#' # Create original simulated dataset
#' df = mvrnorm(n_sample, mu = mu, Sigma = Sigma)
#'
#'# Synthetic data created
#'
#'df_s = simSynthData(df)
#'
#'
#'# Gather the 0.95 quantile
#'
#'p = dim(df_s)[2]
#'
#'T_sph <- Sphdist(nsample = n_sample, pvariates = p, iterations = 10000)
#'q95 <- quantile(T_sph, 0.95)
#'
#'# Compute the observed value of T from the synthetic dataset
#'S_star = cov(df_s*(n_sample-1))
#'
#'T_obs = (det(S_star)^(1/p))/(sum(diag(S_star))/p)
#'
#'print(q95)
#'print(T_obs)
#'
#'#Since the observed value is bigger than the 95% quantile,
#'#we don't have statistical evidences to reject the Sphericity property.
#'#
#'#Note that the value is very close to one
#' @export

Sphdist <- function(nsample, pvariates, iterations) {
  T <- rep(NA, iterations)
  W1 <- stats::rWishart(iterations, nsample - 1, diag(pvariates) / (nsample - 1))
  W2 <- stats::rWishart(iterations, nsample - 1, diag(pvariates))
  for (i in 1:iterations) {
    inner_prod <- crossprod(W1[,,i], W2[,,i])
    T[i] <- det(inner_prod)^(1/pvariates) / sum(inner_prod)  }
  return(T)
}

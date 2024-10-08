#' Canonical Empirical Distribution
#'
#' This function calculates the empirical distribution of the pivotal random
#' variable that can be used to perform inferential procedures for the regression of one subset of variables on the other based on the
#' released Single Synthetic data generated under Plug-in Sampling, assuming
#' that the original dataset is normally distributed.
#'
#' We define
#' \deqn{T_4^\star|\boldsymbol{\Delta} =
#' \frac{(|\boldsymbol{S}^{\star}_{12}
#' (\boldsymbol{S}^{\star}_{22})^{-1}-\boldsymbol{\Delta})
#' \boldsymbol{S}^{\star}_{22}(\boldsymbol{S}^{\star}_{12})
#' (\boldsymbol{S}^{\star}_{22})^{-1}-\boldsymbol{\Delta})^\top|}
#' {|\boldsymbol{S}^{\star}_{11.2}|}}
#' where \eqn{\boldsymbol{S}^\star = \sum_{i=1}^n (v_i - \bar{v})(v_i - \bar{v})^{\top}},
#' \eqn{v_i} is the \eqn{i}th observation of the synthetic dataset,
#' considering \eqn{\boldsymbol{S}^\star} partitioned as
#' \deqn{\boldsymbol{S}^{\star}=\left[\begin{array}{lll}
#' \boldsymbol{S}^{\star}_{11}& \boldsymbol{S}^{\star}_{12}\\
#' \boldsymbol{S}^{\star}_{21} & \boldsymbol{S}^{\star}_{22}
#' \end{array}\right].}
#' For \eqn{\Delta = \boldsymbol{\Sigma}_{12}\boldsymbol{\Sigma}_{22}^{-1}},
#' where \eqn{\boldsymbol{\Sigma}} is partitioned the same way as \eqn{\boldsymbol{S}^{\star}}
#' its distribution is stochastic equivalent to
#' \deqn{\frac{|\boldsymbol{\Omega}_{12}\boldsymbol{\Omega}_{22}^{-1}
#' \boldsymbol{\Omega}_{21}|}{|\boldsymbol{\Omega}_{11}-\boldsymbol{\Omega}_{12}
#' \boldsymbol{\Omega}_{22}^{-1}\boldsymbol{\Omega}_{21}|}}
#' where \eqn{\boldsymbol{\Omega} \sim \mathcal{W}_p(n-1, \frac{\boldsymbol{W}}{n-1})},
#' \eqn{\boldsymbol{W} \sim \mathcal{W}_p(n-1, \mathbf{I}_p)} and
#' \eqn{\boldsymbol{\Omega}} partitioned in the same way as
#' \eqn{\boldsymbol{S}^{\star}}.
#' To test \eqn{\mathcal{H}_0: \boldsymbol{\Delta} =\boldsymbol{\Delta}_0}, compute the value
#'  of \eqn{T_{4}^\star}, \eqn{\widetilde{T_{4}^\star}},  with the observed
#'  values and reject the null hypothesis if
#' \eqn{\widetilde{T_{4}^\star}>t^\star_{4,1-\alpha}} for
#' \eqn{\alpha}-significance level, where \eqn{t^\star_{4,\gamma}} is the
#' \eqn{\gamma}th percentile of \eqn{T_4^\star}.
#'
#'
#' @param part Number of variables in the first subset.
#' @param nsample Sample size.
#' @param pvariates Number of variables.
#' @param iterations Number of iterations for simulating values from the distribution and finding the quantiles. Default is \code{10000}.
#'
#' @return a vector of length \code{iterations} that recorded the empirical distribution's values.
#'
#' @references
#'  Klein, M., Moura, R. and Sinha, B. (2021). Multivariate Normal Inference based on Singly Imputed Synthetic Data under Plug-in Sampling. Sankhya B 83, 273–287.
#'
#' @importFrom stats rWishart
#' @examples
#' # generate original data
#' library(MASS)
#' n_sample = 100
#' p = 4
#' mu <- c(1,2,3,4)
#' Sigma = matrix(c(1,   0.5, 0.1, 0.7,
#'                  0.5,   2, 0.4, 0.9,
#'                  0.1, 0.4,   3, 0.2,
#'                  0.7, 0.9, 0.2,   4), nr = 4, nc = 4, byrow = TRUE)
#'
#' df = mvrnorm(n_sample, mu = mu, Sigma = Sigma)
#' # generate synthetic data
#' df_s = simSynthData(df)
#' #Decompose Sigma and Sstar
#' part = 2
#' Sigma_12 = partition(Sigma,nrows = part, ncol = part)[[2]]
#' Sigma_22 = partition(Sigma,nrows = part, ncol = part)[[4]]
#' Delta0 = Sigma_12 %*% solve(Sigma_22)
#'
#' Sstar = cov(df_s)
#' Sstar_11 = partition(Sstar,nrows = part, ncol = part)[[1]]
#' Sstar_12 = partition(Sstar,nrows = part, ncol = part)[[2]]
#' Sstar_21 = partition(Sstar,nrows = part, ncol = part)[[3]]
#' Sstar_22 = partition(Sstar,nrows = part, ncol = part)[[4]]
#'
#'
#' DeltaEst = Sstar_12 %*% solve(Sstar_22)
#' Sstar11_2 = Sstar_11 - Sstar_12 %*% solve(Sstar_22) %*% Sstar_21
#'
#'
#' T4_obs = det((DeltaEst-Delta0)%*%Sstar_22%*%t(DeltaEst-Delta0))/det(Sstar11_2)
#'
#' T4 <- canodist(part = part, nsample = n_sample, pvariates = p, iterations = 10000)
#' q95 <- quantile(T4, 0.95)
#'
#' T4_obs > q95 #False means that we don't have statistical evidences to reject Delta0
#' print(T4_obs)
#' print(q95)
#' # When the observed value is smaller than the 95% quantile,
#' # we don't have statistical evidences to reject the Sphericity property.
#' #
#' # Note that the value is very close to zero
#' @export

canodist <- function(part, nsample, pvariates, iterations) {
  T <- rep(NA, iterations)
  W1 <- stats::rWishart(iterations, nsample - 1, diag(pvariates))
  for (i in 1:iterations) {
    W2 <- stats::rWishart(1, nsample - 1, W1[, , i] / (nsample - 1))
    A <- partition(W2[, , 1], part, part)
    W2_11 <- A[[1]]
    W2_12 <- A[[2]]
    W2_21 <- A[[3]]
    W2_22 <- A[[4]]
    Q <- W2_12 %*% solve(W2_22) %*% W2_21
    T[i] <- det(Q) / det(W2_11 - Q)
  }
  return(T)
}

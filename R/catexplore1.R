#'@title cat_explore1: exploratory analyses with one categorical variable
#'
#'@description cat_explore1 is designed for quick exploratory analyses of data frames with a continuous response variable and one explanatory categorical variable of interest. It produces plots and summary tables for investigating data distribution and comparing sample size, spread, and central tendency between levels of the categorical variable.
#'
#'@param data The data frame containing the continuous response variable and categorical explanatory variable of interest -> data is an intuitive name for the data set being analyzed by thus function
#'@param cont The data frame column containing the continuous response variable -> cont is as an abbreviation for continuous, the type of variable this argument specifies
#'@param cat1 The data frame column containing the categorical explanatory variable -> cat1 is as an abbreviation for continuous, the type of variable this argument specifies, plus a 1 to signify it is the first (and in this case, only) categorical variable being used for grouping
#'@param alpha The alpha value used to calculate the confidence interval used in plotting. Default is 0.05, producing a 95% confidence interval.
#'@param remove.na Logical argument specifying if summary statistics should remove na values for their calculations. Default is TRUE.
#'
#'@return A list containing 3 plots and 2 tibbles:
#'\itemize{
#'  \item {viz_hist}  is a figure with the histogram of the continuous variable
#'  \item {median_max_min} is a tibble with the median, maximum, minimum, and range of the continuous variable grouped by the categorical variable
#'  \item {viz_box} is a figure with boxplots of the continuous variable for each level categorical variable
#'  \item {mean_se_n} is a tibble with the mean, standard deviation, standard error of the mean, and sample size of the continuous variable grouped by the categorical variable
#'  \item {viz_conf} is a figure with plots of the mean and approximated confidence intervals for each level of the categorical variable.
#'}
#'
#'@examples
#'cat_explore1(gapminder::gapminder, lifeExp, continent)
#'cat_explore1(gapminder::gapminder, lifeExp, continent, alpha = 0.1)
#'@importFrom rlang .data
#'@export
cat_explore1 <- function(data, cont, cat1, alpha = 0.05, remove.na = TRUE) {
  if(!is.data.frame(data)) {
    stop("Sorry, but the first argument of this function requires a data frame!")
  }

  if(!is.numeric(eval(substitute({{cont}}), data))) {
    stop("Sorry, but the second argument of this function requires a numeric vector!")
  }

  if(is.character(eval(substitute({{cat1}}), data))) {
    as.factor(eval(substitute({{cat1}}), data))
  }

  if(!is.factor(eval(substitute({{cat1}}), data))) {
    stop("Sorry, but the third argument of this function requires a factor or character vector!")
  }

  if(!is.numeric(eval(substitute({{alpha}}), data))) {
    stop("Sorry, but the fourth argument of this function requires a numeric value!")
  }

  if(1 - {{alpha}}/2 <= 0) {
    stop("Sorry, but the fourth argument of this function must produce a value greater than zero when used in the formula 1-alpha/2")
  }

  if(1 - {{alpha}}/2 >= 1) {
    stop("Sorry, but the fourth argument of this function must produce a value less than one when used in the formula 1-alpha/2")
  }


  viz_hist <- data %>% tidyr::drop_na() %>% ggplot2::ggplot() +
    ggplot2::geom_histogram(ggplot2::aes({{cont}}))+
    ggplot2::theme_bw()

  median_max_min <- data  %>% dplyr::group_by({{cat1}}) %>% dplyr::summarize(median = stats::median({{cont}}, na.rm = remove.na), max = max({{cont}}, na.rm = remove.na), min = min({{cont}}, na.rm = remove.na), range = max({{cont}}, na.rm = remove.na) - min({{cont}}, na.rm = remove.na))

  viz_box <- data %>% tidyr::drop_na() %>% ggplot2::ggplot() +
    ggplot2::geom_boxplot(ggplot2::aes({{cat1}}, {{cont}}))+
    ggplot2::theme_bw()

  mean_se_n <- data  %>% dplyr::group_by({{cat1}}) %>% dplyr::summarize(mean = mean({{cont}}, na.rm = remove.na), sd = stats::sd({{cont}}, na.rm = remove.na), se = stats::sd({{cont}}, na.rm = remove.na)/sqrt(dplyr::n()), n = dplyr::n())

  viz_conf <- mean_se_n %>% tidyr::drop_na() %>% ggplot2::ggplot() +
    ggplot2::geom_point(ggplot2::aes({{cat1}}, mean)) +
    ggplot2::geom_errorbar(ggplot2::aes({{cat1}}, ymin = mean - stats::qnorm(1-alpha/2)*.data$se, ymax = mean + stats::qnorm(1-alpha/2)*.data$se)) +
    ggplot2::theme_bw()

  my_list <- list(viz_hist, median_max_min, viz_box, mean_se_n, viz_conf)
  return(my_list)
}

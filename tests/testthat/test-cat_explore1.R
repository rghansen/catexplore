test_that("cat_explore1 returns a list with 5 objects inside (three ggplot objects and two dataframes", {
  subject <- cat_explore1(palmerpenguins::penguins, body_mass_g, sex)

  expect_output(str(subject), "List of 5")
  expect_s3_class(subject[[1]], "ggplot")
  expect_s3_class(subject[[2]], "data.frame")
  expect_s3_class(subject[[3]], "ggplot")
  expect_s3_class(subject[[4]], "data.frame")
  expect_s3_class(subject[[5]], "ggplot")
})

test_that("cat_explore1 produces errors when arguments are the wrong class", {
  vector1 <- c()
  vector2 <- c(1:20)
  plot <- ggplot2::ggplot(palmerpenguins::penguins, ggplot2::aes(year, body_mass_g))

  expect_error(cat_explore1(vector1))
  expect_error(cat_explore1(vector2))
  expect_error(cat_explore1(plot))
  expect_error(cat_explore1(palmerpenguins::penguins$species, island, sex))
  expect_error(cat_explore1(palmerpenguins::penguins, island, sex))
  expect_error(cat_explore1(palmerpenguins::penguins, body_mass_g, year))
  expect_error(cat_explore1(palmerpenguins::penguins, island, year))
  expect_error(cat_explore1(palmerpenguins::penguins, body_mass_g, sex, "0.95"))
})

test_that("cat_explore1 produces errors when arguments are mathematicaly invalid", {
  expect_error(cat_explore1(palmerpenguins::penguins, body_mass_g, sex, 2))
  expect_error(cat_explore1(palmerpenguins::penguins, body_mass_g, sex, 0))
} )

test_that("cat_explore1 calculates numeric summarized values even when dataset contains NAs", {
  subject <- cat_explore1(palmerpenguins::penguins, body_mass_g, sex)

  expect_true(sum(is.na(subject[[2]]$median))== 0)
  expect_true(sum(is.na(subject[[4]]$mean))== 0)
})

test_that("cat_explore1 correctly calculates summarized values", {
  subject <- cat_explore1(palmerpenguins::penguins, body_mass_g, island)

  expect_length(subject[[2]]$median, nlevels(palmerpenguins::penguins$island))
  expect_equal(sum(subject[[4]]$n), length(palmerpenguins::penguins$body_mass_g))

  median <- palmerpenguins::penguins  %>% dplyr::group_by(island) %>% dplyr::summarize(median = stats::median(body_mass_g, na.rm = TRUE))
  mean <- palmerpenguins::penguins  %>% dplyr::group_by(island) %>% dplyr::summarize(mean = mean(body_mass_g, na.rm = TRUE))
  sample_size <- palmerpenguins::penguins  %>% dplyr::group_by(island) %>% dplyr::summarize(n = dplyr::n())

  expect_equal(subject[[2]]$median[1], median$median[1])
  expect_equal(subject[[4]]$mean[1], mean$mean[1])
})

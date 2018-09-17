library(tidyverse)
tmp <- list.files("/myfiles/las/research/csafe/ShoeImagingPermanent/", pattern = "_2_1_[12]_.*\\.tiff")
filedf <- extract(
  data_frame(file = tmp), file,
  into = c("PairID", "checksum", "LR", "Date", "Method", "Mode",
           "Replicate", "ScannerID"),
  "(\\d{3})(\\d{3})([LR])_(\\d{8})_(\\d{1,})_(\\d{1,})_(\\d{1,})_csafe_(.*)\\..*",
  remove = F) %>%
  group_by(PairID) %>%
  mutate(n = n())


path <- here::here("inst/extdata")
if (!dir.exists(path)) dir.create(path, recursive = T)

tmp <- filter(filedf, PairID %in% c("036", "052"))

set.seed(3402508)
tmp2 <- filter(filedf, n == 16) %>%
 nest(-PairID) %>%
 sample_n(size = 5) %>%
 unnest()

tmp <- bind_rows(tmp, tmp2)
tmp$indiv <- sprintf("person%d", as.numeric(factor(tmp$ScannerID)))

tmp$filenew <- str_replace(tmp$file, tmp$ScannerID, tmp$indiv)
file.copy(from = file.path("/myfiles/las/research/csafe/ShoeImagingPermanent/", tmp$file),
          to = file.path(path, tmp$filenew))

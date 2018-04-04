x <- "C:/Users/kraskape/Desktop/test"

castaway_transform <- function(x) {
  require(tidyverse)
  # create list of raw files for analysis based on path provided by x
  raw.files <- list.files(path = x, pattern = "*.csv", full.names = TRUE, recursive = FALSE)

  # Progress bar and messages
  counter <- length(raw.files)
  message(paste("Creating cast file in ", x, "/PROCESSED/", sep = "" ))
  pb <- txtProgressBar(min = 0, max = counter, style = 3)

  # Pull header row names, transpose, remove leading "% " from column names
  col_names <- read_csv(raw.files[1], n_max = 27, col_names = FALSE, col_types = cols()) %>%
    select(X1) %>%
    t() %>%
    gsub("% ", "", .) %>%
    as.vector()

  max <- length(raw.files)

  coord <- read_csv(raw.files[1], n_max = 27, col_names = FALSE, col_types = cols()) %>% # read in first 27 rows of data i.e. header data
    select(X2) %>% #select only header info, not header names
    t() %>% # transpose
    gsub("% ", "", .) %>% # find % in column names and remove
    as.data.frame() %>% # change from character matrix to data frame
    mutate(Id = V2) %>%
    filter(V5 != "Invalid") #REMOVE INVALID FILES

  for (i in 2:length(raw.files)) {
    coord_loop <- read_csv(raw.files[i], n_max = 27, col_names = FALSE, col_types = cols()) %>%
      select(X2) %>%
      t() %>%
      as.data.frame() %>%
      mutate(Id = V2) %>% # Add ID column for linking between data file
      filter(V5 != "Invalid")

    coord <- rbind(coord, coord_loop)
    setTxtProgressBar(pb, i)
  }

  colnames(coord) <- c(col_names, "Id") # Rename columns using the trimmed column names
  coord <- select(coord, Id, everything()) #reorder cols so ID is first

  # Save output to PROCESSED DATA/ACRDP_COORDINATES.csv
  if(dir.exists(paste(x,"/PROCESSED", sep = "")) == FALSE) {
    print("Processed directory does not exist, creating now...")
    dir.create(paste(x,"/PROCESSED", sep = ""))
  } else {
    print("Processed directory exists, moving on.")
  }

  write_csv(coord, paste(x, "/PROCESSED/castaway_coordinates.csv", sep =""))
  close(pb)

  # Progress bar and messages
  counter <- length(raw.files)
  message(paste("Creating data file in ", x, sep =""))
  pb2 <- txtProgressBar(min = 0, max = counter, style = 3)

  df <- read_csv(raw.files[1], skip = 28, col_types = cols()) %>%
    mutate(Id = coord$Id[1]) %>%
    select(Id, everything())
  setTxtProgressBar(pb2, 1)

  # Loop over the list of files in the folder from raw.files
  for (i in 2:length(raw.files)) {
    df_loop <- read_csv(raw.files[i], skip = 28, col_types = cols()) %>%
      mutate(Id = coord$Id[i]) %>%
      select(Id, everything())
    df <- rbind(df, df_loop)
    setTxtProgressBar(pb2, i)
  }
  close(pb2)

  write_csv(df, paste(x, "/PROCESSED/castaway_data.csv", sep =""))
}


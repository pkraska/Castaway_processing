x <- "C:/Users/kraskape/Documents/3-R/Projects/Castaway_processing"

castaway_transform <- function(x) {
  require(tidyverse)
  # create list of raw files for analysis based on path provided by x
  raw.files <- list.files(path = x, pattern = "*.csv", full.names = TRUE, recursive = FALSE)
  counter <- length(raw.files
                    )
  # Progress bar and messages
  message(paste("Creating cast file in ", x, "/PROCESSED/", sep = "" ))

  # Pull header row names, transpose, remove leading "% " from column names
  col_names <- read_csv(raw.files[1], n_max = 27, col_names = FALSE, col_types = cols()) %>%
    select(X1) %>%
    t() %>%
    gsub("% ", "", .) %>%
    as.vector()

  coord <- read_csv(raw.files[1], n_max = 27, col_names = FALSE, col_types = cols()) %>% # read in first 27 rows of data i.e. header data
    select(X2) %>% #select only header info, not header names
    t() %>% # transpose
    gsub("% ", "", .) %>% # find % in column names and remove
    as.data.frame() %>% # change from character matrix to data frame
    mutate(Id = V2) %>%
    filter(V5 != "Invalid") #REMOVE INVALID FILES
  
  if(counter > 1){
    for(i in 2:length(raw.files)) {
    coord_loop <- read_csv(raw.files[i], n_max = 27, col_names = FALSE, col_types = cols()) %>%
      select(X2) %>%
      t() %>%
      as.data.frame() %>%
      mutate(Id = V2) %>%
      filter(V5 != "Invalid") #REMOVE INVALID FILES

    coord <- rbind(coord, coord_loop)
    }
}
  
  odf_header <- data.frame()
  datetime <- paste(toupper(format(as.POSIXct(coord$V3), "%d-%b-%Y %H:%M:%S")),".00", sep ="")
    
  colnames(coord) <- c(col_names, "Id") # Rename columns using the trimmed column names
  coord <- select(coord, Id, everything()) #reorder cols so ID is first

  # Save output to PROCESSED DATA/ACRDP_COORDINATES.csv
  if(dir.exists(paste(x,"/PROCESSED", sep = "")) == FALSE) {
    message("    Processed directory does not exist, creating now...")
    dir.create(paste(x,"/PROCESSED", sep = ""))
  } else {
    message("    Processed directory exists, moving on.")
  }

  write_csv(coord, paste(x, "/PROCESSED/castaway_coordinates.csv", sep =""))

  # Progress bar and messages
  message(paste("Creating data file in ", x,"/PROCESSED/", sep =""))

  df <- read_csv(raw.files[1], skip = 28, col_types = cols()) %>%
    mutate(Id = coord$Id[1]) %>%
    select(Id, everything())

  # Loop over the list of files in the folder from raw.files
  if(counter > 1){
     for (i in 2:length(raw.files)) {
    df_loop <- read_csv(raw.files[i], skip = 28, col_types = cols()) %>%
      mutate(Id = coord$Id[i]) %>%
      select(Id, everything())
    df <- rbind(df, df_loop)
  }
  }

  write_csv(df, paste(x, "/PROCESSED/castaway_data.csv", sep =""))
}
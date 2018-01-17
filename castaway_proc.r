# CREATE FUNCTION castaway.head to create header information for all castaway files in folder PROCESSED DATA/ACRDP_COORDINATES.csv, x
# "C:/Users/kraskape/Documents/DATA/FredPage/ACRDP/RAW DATA/Castaway/ACRDP Drift"
# proc.castaway <- function(folder, trim = 0.25) {
  # create list of raw files for analysis based on path provided by x
  folder <- "C:/Users/kraskape/Documents/DATA/FredPage" #EXAMPLE FOLDER PATH
  
  raw.files <- list.files(path = folder, pattern = "*.csv", recursive = TRUE)
  
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
  
  counter <- length(raw.files)
  message("Checking to see if PROCESSED DATA folder exists, if not, will create folder /PROCESSED DATA in directory specified in function proc.castaway")
  message(paste("Creating header file in ",folder, "/PROCESSED DATA/ACRDP_COORDINATES.csv", sep = ""))
  pb <- txtProgressBar(min = 0, max = counter, style = 3)
  
  # Pull header row names, transpose, remove leading "% " from column names
  col_names <- read_csv(paste(folder,raw.files[1], sep = "/"), n_max = 27, col_names = FALSE, col_types = cols()) %>%
    select(X1) %>%
    t() %>%
    gsub("% ", "", .) %>%
    as.vector()
  
  max <- length(raw.files)
  
  coord <- read_csv(paste(folder,raw.files[1], sep = "/"), n_max = 27, col_names = FALSE, col_types = cols()) %>% # read in first 27 rows of data i.e. header data
    select(X2) %>% #select only header info, not header names
    t() %>% # transpose
    gsub("% ", "", .) %>% # find % in column names and remove
    as.data.frame() %>% # change from character matrix to data frame
    mutate(ID = 1) %>%
    # filter(V5 != "Invalid") %>% #REMOVE INVALID FILES
    mutate(path = paste(folder,"/", raw.files[1], sep = ""))

    for (i in 2:length(raw.files)) {
    coord_loop <- read_csv(paste(folder,raw.files[i], sep = "/"), n_max = 27, col_names = FALSE, col_types = cols()) %>%
      select(X2) %>%
      t() %>%
      as.data.frame() %>%
      mutate(ID = i) %>% # Add ID column for linking between data file
      # filter(V5 != "Invalid") %>% #REMOVE INVALID FILES
      mutate(path = paste(folder,"/", raw.files[i], sep = ""))

    coord <- rbind(coord, coord_loop)
    setTxtProgressBar(pb, i)
  }
  
  colnames(coord) <- c(col_names, "ID", "path") # Rename columns using the trimmed column names
  coord$ID <- as.factor(coord$ID)
  coord <- select(coord, ID, path, everything()) #reorder cols so ID is first
  
  # Save output to RROCESSED DATA/ ACRDP_COORDINATES.csv
  
  dir.create(paste(folder,"/PROCESSED DATA", sep =""), showWarnings = FALSE)
  write.csv(coord, paste(folder,"/PROCESSED DATA/CASTAWAY_COORDINATES.csv", sep =""), row.names = FALSE)
  close(pb)

#========================= CREATE Castaway Data  File ========================= 
  # Use first file data to create proper sized dataframe
  
  message("Creating data file in /PROCESSED DATA/ACDRP_CASTAWAY_DATA.csv" )
  pb2 <- txtProgressBar(min = 0, max = counter, style = 3)
  
  df <- read_csv(paste(folder,raw.files[1], sep = "/"), skip = 28, col_types = cols()) %>%
    mutate(ID = 1) %>%
    select(ID, everything())

  # Loop over the list of files in the folder from raw.files
  for (i in 2:length(raw.files)) { 
    df_loop <- read_csv(paste(folder,raw.files[i], sep = "/"), skip = 28, col_types = cols()) %>%
      mutate(ID = i) %>%
      select(ID, everything())
    
    df <- rbind(df, df_loop)
    
    setTxtProgressBar(pb2, i)
  }
  
  write.csv(df, paste(folder, "/PROCESSED DATA/CASTAWAY_DATA.csv", sep =""), row.names = FALSE)
  close(pb2)
  
#========================= CREATE Castaway Depth Profiles ========================= 
  df.join <- left_join(coord, df , 'ID') %>% #Left join drops the "Invalid" cast data identified in coord as those IDs are no longer included there
    filter('Sample type' == "Invalid")
  
  message("Creating castaway depth profiles for all CSV files in folder specificied in /PROCESSED DATA/PLOTS" )
  pb3 <- txtProgressBar(min = 0, max = length(unique(df.join$ID)), style = 3)
  
  # Create plots for every valid (not "Invalid") cast
  for (i in unique(df.join$ID)) {
    gg.df <- df.join %>%
      filter(ID == unique(df.join$ID)[i]) %>%
      filter('Data type' == "Invalid")
      select(-1:-28) %>%
      filter(`Pressure (Decibar)` > trim) %>% #filter out data from surface based on pressure being less than 0.25 dbars,can adjust to QC data
      gather(Variable, Measurement, -`Pressure (Decibar)`)
    
    gg.plot <- ggplot(data = gg.df, aes(x = Measurement, y = `Pressure (Decibar)`)) +
      geom_point() +
      facet_grid(.~Variable, scales = "free") +
      scale_y_reverse() +
      ylab("Pressure (Decibars)") +
      xlab("") +
      ggtitle(paste("Depth profiles for ", coord$'File name'[id = i],sep ="")) +
      theme_bw()
    dir.create(paste(folder,"/PROCESSED DATA/PLOTS", sep =""), showWarnings = FALSE)
    suppressMessages(ggsave(paste(folder,"/PROCESSED DATA/PLOTS/", unique(df.join$'File name')[i],".png", sep = "")))
    
    setTxtProgressBar(pb3, i)
  }
  close(pb3)
}
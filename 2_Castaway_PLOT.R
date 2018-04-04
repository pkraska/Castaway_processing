library(tidyverse)

df.join <- left_join(coord, df , 'ID') #Left join drops the "Invalid" cast data identified in coord as those IDs are no longer included there


# Create plots for every valid (not "Invalid") cast
for (i in 1:length(unique(df.join$ID))) {
gg.df <- df.join %>%
  filter(ID == unique(df.join$ID)[i]) %>%
  select(-1:-28) %>%
  filter(`Pressure (Decibar)` > 0.25) %>% #filter out data from surface based on pressure being less than 0.1dbars,can adjust to QC data
  gather(Variable, Measurement, -`Pressure (Decibar)`)

gg.plot <- ggplot(data = gg.df, aes(x = Measurement, y = `Pressure (Decibar)`)) +
  geom_point() +
  facet_grid(.~Variable, scales = "free") +
  scale_y_reverse() +
  ylab("Pressure (Decibars)") +
  xlab("") +
  ggtitle(paste("Depth profiles for ", coord$'File name'[id = i]), unique(df.join$ID)[i]) +
  theme_bw()

ggsave(paste("C:/Users/kraskape/Documents/DATA/FredPage/ACRDP/PROCESSED DATA/PLOTS/", df.join$'File name'[i],".png"))
}


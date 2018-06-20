# Castaway GSW Calculations
require(gsw)

data <- read_csv("C:/Users/kraskape/Documents/3-R/Projects/Castaway_processing/PROCESSED/castaway_data.csv")
header <- read_csv("C:/Users/kraskape/Documents/3-R/Projects/Castaway_processing/PROCESSED/castaway_coordinates.csv")


# castaway information from Castaway_CASTS.R
# ==========================================
cast_pressure <- data$`Pressure (Decibar)`
cast_latitude <- header$`Start latitude`
cast_conductivity <- data$`Conductivity (MicroSiemens per Centimeter)`
cast_temperature <- data$`Temperature (Celsius)`
cast_conductivity <- data$`Conductivity (MicroSiemens per Centimeter)`
cast_temperature <- data$`Temperature (Celsius)`

cast_depth <- gsw_z_from_p(cast_pressure, cast_latitude)
cast_SP <- gsw_SP_from_C(cast_conductivity, cast_temperature, cast_pressure)

cast <- data.frame(p = cast_pressure, lat = cast_latitude, d = cast_depth,
                   C = cast_conductivity, t = cast_temperature, SP = cast_SP)


plot(ts(cast$d, frequency = 5))
plot(ts(cast$t, frequency = 5), col = 'red')

plot(cast_depth, ylab = "depth (m)", type = 'l')
  points(-data$`Pressure (Decibar)`, col = 'red', type = 'l')
plot(cast_temperature)
plot(cast_conductivity)  

cast.trimmed <- cast[cast$d < -.25, ] 

plot(cast.trimmed$t, cast.trimmed$d)
# Practical Salinity from Conductivity
# ====================================
cast_SP <- gsw_SP_from_C(cast_conductivity, cast_temperature, cast_pressure)

plot(cast_SP)

# In-Situ Density from Absolute Salinity, Conservative Temperature, and sea Pressure
# ==============================================================================
cast_density <- gsw_rho(cast_SP, )
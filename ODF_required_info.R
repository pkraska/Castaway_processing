
datetime <- paste(toupper(format(as.POSIXct(coord$V3), "%d-%b-%Y %H:%M:%S")),".00", sep ="")
# ALL DATETIMES MUST BE IN DD-MMM-YYYY HH:MM:SS.SS FORMAT

# ODF_HEADER block required Information
# =======================================
  file_specification = getwd()

# CRUISE_HEADER block required Information
# ========================================
  country_inst_code = "1810"
  cruise_num = "SCDYYYYXXX, see data manager about cruise numbers"
  organization = "St. Andrews Biological Station, Fisheries and Oceans Canada"
  chief_scientist = ""
  cruise_start_date = "DD-MMM-YYYY HH:MM:SS.SS"
  cruise_end_date = "DD-MMM-YYYY HH:MM:SS.SS"
  cruise_platform = "Boaty McBoatface"
  cruise_name = "Project Name"
  cruise_description = "Information about specific cruise if available"
  

# EVENT_HEADER block required Information
# =======================================
  data_type = ""
  event_number = ""
  event_qualifier1 = ""
  event_quaifier2 = ""
  creation_date = ""
  start_date_time = ""
  end_date_time = ""
  initial_lat = ""
  initial_lon = ""
  end_lat = ""
  end_lon = ""
  min_depth  = ""
  max_depth = ""
  sampling_int = ""
  sounding = ""
  depth_off_bottom = "" 
  even_comments = ""
  model = ""
  event_comments = ""

  # INSTRUMENT_HEADER block required Information
  # =======================================
  inst_type = "Sea-Bird"
  inst_model = "SBE25"
  inst_sn = "2155"
  inst_description = "historically, .hex and .con files listed here"
  
  # POLYNOMIAL_CAL_HEADER block required Information
  # =======================================
  poly_parameter_name = "e.g. PSAL_2"
  poly_calibration_date = "DD-MMM-YYYY HH:MM:SS.SS"
  poly_application_date = "DD-MMM-YYYY HH:MM:SS.SS"
  poly_n_coefficients = "number of coefficients in next field"
  poly_coefficients = "calibration coefficients, separated by a space"
  
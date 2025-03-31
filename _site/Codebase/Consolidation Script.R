library(readr)
library(dplyr)
library(stringr)

folder_path <- "C:/Users/shery/Desktop/weather_data"  # Adjust for Windows

file_paths <- list.files(folder_path, pattern = "^data.*\\.csv$", full.names = TRUE)

data_list <- list()

for (file_path in file_paths) {
  filename <- basename(file_path)
  station_code <- str_extract(filename, "S\\d+")
  
  # Read the CSV file with column types specified or convert post-hoc
  data <- read_csv(file_path, col_types = cols(
    `Max Wind Speed (km/h)` = col_character()  # Force reading as character
  )) %>% 
    mutate(across(`Max Wind Speed (km/h)`, as.numeric, .names = "{.col}_num"))  # Convert to numeric safely
  
  # Handle NA conversion warnings or errors here if needed
  if (!is.null(station_code)) {
    if (!station_code %in% names(data_list)) {
      data_list[[station_code]] <- data
    } else {
      data_list[[station_code]] <- bind_rows(data_list[[station_code]], data)
    }
  }
}

# Save each station's data to a new CSV file
for (station_code in names(data_list)) {
  output_file_path <- file.path(folder_path, paste0("consolidated_", station_code, ".csv"))
  write_csv(data_list[[station_code]], output_file_path)
}

# Load necessary libraries
library(httr)
library(readr)

# Set the path to the folder on the Desktop
folder_path <- "C:/Users/shery/Desktop/weather_data"  # Adjust for Windows

# Check if the folder exists, if not, create it
if (!dir.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE, showWarnings = TRUE)
}

# Path to the CSV file with location IDs
file_path <- file.path(folder_path, "weatherstation_code_master.csv")

# Read the CSV file for location IDs
location_data <- read_csv(file_path)

# Correct column name for location IDs
location_ids <- location_data$Code

# Define the date range
start_year <- 2014
end_year <- 2024

# Function to download CSV for a specific year, month, and location
download_csv <- function(year, month, location_id, folder_path) {
  url <- sprintf("https://www.weather.gov.sg/files/dailydata/DAILYDATA_%s_%d%02d.csv", location_id, year, month)
  response <- GET(url)
  
  if (status_code(response) == 200) {
    file_name <- sprintf("%s/data_%s_%d%02d.csv", folder_path, location_id, year, month)
    writeLines(content(response, "text", encoding = "UTF-8"), file_name)
    cat("Downloaded data for ", location_id, " ", year, "-", month, "\n")
  } else {
    warning("Failed to download data for ", year, "-", month, " at location ", location_id)
    return(NULL)
  }
}

# Loop through each year, month, and location to download CSV files
for (location_id in location_ids) {
  for (year in start_year:end_year) {
    for (month in 1:12) {
      if (!(year == end_year && month > 12)) {  # Ensure not to loop into future months
        download_csv(year, month, location_id, folder_path)
      }
    }
  }
}

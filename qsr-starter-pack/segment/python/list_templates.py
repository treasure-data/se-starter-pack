import os
import pandas as pd
import segment.python.td as td


def list_files_in_folder(folder_path):
    file_list = []

    # Iterate through all files in the folder
    for root, _, files in os.walk(folder_path):
        for file in files:
            # Get the full path of the file
            file_path = os.path.join(root, file)

            # Split the path into folder and file
            folder, file_name = os.path.split(file_path)

            # Remove the common root folder from the path
            # folder = os.path.relpath(folder, folder_path)

            # Append the folder and file to the list
            file_list.append({"Folder": folder_path, "File": file_name})

    # Create a DataFrame from the list of files
    df_files = pd.DataFrame(file_list)

    return df_files


def main(folder_path, db, table):
    result_df = list_files_in_folder(folder_path)
    print(result_df, db, table)
    td.uploadDataToTD(result_df, db, table)

    # Display the resulting DataFrame
    print(result_df)

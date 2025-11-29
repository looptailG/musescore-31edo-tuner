import os
import glob
import shutil
import re


PLUGIN_FOLDER_NAME = "31edo_tuner"
SOURCE_FOLDER = "../source"
THUMBNAILS_FOLDER_NAME = "thumbnails"
LOGS_FOLDER = f"{PLUGIN_FOLDER_NAME}/logs"
README_PATH = "../README.md"
LICENSE_PATH = "../LICENSE"
FILES_TO_COPY = [LICENSE_PATH]


def main():
    try:
        shutil.copytree(SOURCE_FOLDER, PLUGIN_FOLDER_NAME, dirs_exist_ok=True)
        for file_path in FILES_TO_COPY:
            file_name = file_path[file_path.rindex("/") + 1:]
            shutil.copyfile(file_path, f"{PLUGIN_FOLDER_NAME}/{file_name}")
        
        if not os.path.exists(LOGS_FOLDER):
            os.makedirs(LOGS_FOLDER)
        
        if not os.path.exists(f"{PLUGIN_FOLDER_NAME}/{THUMBNAILS_FOLDER_NAME}"):
            os.makedirs(f"{PLUGIN_FOLDER_NAME}/{THUMBNAILS_FOLDER_NAME}")
        for file_path in glob.glob(f"../{THUMBNAILS_FOLDER_NAME}/*.png"):
            file_name = file_path[file_path.rindex("/") + 1:]
            shutil.copyfile(file_path, f"{PLUGIN_FOLDER_NAME}/{file_name}")

        version_number = get_version_number()
        output_folder_name = f"{PLUGIN_FOLDER_NAME}_{version_number}"
        temporary_folder = "tmp"
        shutil.copytree(PLUGIN_FOLDER_NAME, f"{temporary_folder}/{PLUGIN_FOLDER_NAME}", dirs_exist_ok=True)
        shutil.make_archive(output_folder_name, "zip", temporary_folder)
        shutil.rmtree(temporary_folder)

    except Exception as e:
        print(e)
        input()


def get_version_number() -> str:
    version_number_pattern = re.compile(r"version:\s*\"(.+)\";")
    for root, _, files in os.walk(SOURCE_FOLDER):
        for file_name in files:
            if simplify_file_name(PLUGIN_FOLDER_NAME) not in simplify_file_name(file_name):
                continue

            file_path = os.path.join(root, file_name)
            with open(file_path, "r") as file:
                for line in file:
                    match = version_number_pattern.match(line.strip())
                    if match:
                        return match.group(1)

    raise Exception("Could not get the version number.")


def simplify_file_name(file_name: str) -> str:
    return file_name.replace("_", "").lower()


if __name__ == "__main__":
    main()

import os
import glob
import shutil
import re


PLUGIN_FOLDER = "31edo_tuner"
PROJECT_FOLDER = ".."
SOURCE_FOLDER = "source"
THUMBNAILS_FOLDER = "thumbnails"
LOGS_FOLDER = "logs"
README_FILE = f"{PROJECT_FOLDER}/README.md"
LICENSE_FILE = f"{PROJECT_FOLDER}/LICENSE"
FILES_TO_COPY = [README_FILE, LICENSE_FILE]


def main():
    try:
        if os.path.exists(PLUGIN_FOLDER):
            shutil.rmtree(PLUGIN_FOLDER)

        shutil.copytree(
                f"{PROJECT_FOLDER}/{SOURCE_FOLDER}", PLUGIN_FOLDER,
                dirs_exist_ok=True, ignore=ignore_test_files
        )
        for file_path in FILES_TO_COPY:
            file_name = file_path[file_path.rindex("/") + 1:]
            shutil.copyfile(file_path, f"{PLUGIN_FOLDER}/{file_name}")

        if not os.path.exists(f"{PLUGIN_FOLDER}/{LOGS_FOLDER}"):
            os.makedirs(f"{PLUGIN_FOLDER}/{LOGS_FOLDER}")

        if not os.path.exists(f"{PLUGIN_FOLDER}/{THUMBNAILS_FOLDER}"):
            os.makedirs(f"{PLUGIN_FOLDER}/{THUMBNAILS_FOLDER}")
        for file_path in glob.glob(f"{PROJECT_FOLDER}/{THUMBNAILS_FOLDER}/*.png"):
            file_name = file_path[file_path.rindex("/") + 1:]
            shutil.copyfile(file_path, f"{PLUGIN_FOLDER}/{file_name}")

        version_number = get_version_number()
        output_folder_name = f"{PLUGIN_FOLDER}_{version_number}"
        temporary_folder = "tmp"
        shutil.copytree(PLUGIN_FOLDER, f"{temporary_folder}/{PLUGIN_FOLDER}", dirs_exist_ok=True)
        shutil.make_archive(output_folder_name, "zip", temporary_folder)
        shutil.rmtree(temporary_folder)

    except Exception as e:
        print(e)
        input()


def get_version_number() -> str:
    version_number_pattern = re.compile(r"version:\s*\"(.+)\";")
    for root, _, files in os.walk(f"{PROJECT_FOLDER}/{SOURCE_FOLDER}"):
        for file_name in files:
            if simplify_file_name(PLUGIN_FOLDER) not in simplify_file_name(file_name):
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


def ignore_test_files(directory, contents):
    return [f for f in contents if f.startswith("TEST")]


if __name__ == "__main__":
    main()

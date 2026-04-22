import sys
import json
import shutil
import time
from pathlib import Path

CUSTOMS_PATH = Path.home() / "Documents" / "Assetto Corsa Competizione" / "Customs"


def progress_bar(current, total, bar_length=20):
    current += 1
    fraction = current / total
    arrow = int(fraction * bar_length - 1) * '=' + '>'
    padding = int(bar_length - len(arrow)) * ' '
    ending = '\n' if current == total else '\r'
    print(f"Deleting {current} / {total} files | Progress: [{arrow}{padding}] {int(fraction*100)}%", end=ending)
    sys.stdout.flush()


def get_custom_skin_names():
    cars_path = CUSTOMS_PATH / "cars"
    skin_names = []
    skipped = []
    for json_file in cars_path.glob("*.json"):
        raw = json_file.read_bytes()
        if raw[:2] == b'\xff\xfe':
            encoding = "utf-16"
        elif raw[:2] == b'{\x00':
            encoding = "utf-16-le"
        else:
            encoding = "utf-8"
        try:
            data = json.loads(raw.decode(encoding))
        except (UnicodeDecodeError, json.JSONDecodeError) as e:
            skipped.append((json_file.name, str(e)))
            continue
        if data.get("customSkinName"):
            skin_names.append(data["customSkinName"])
    return skin_names, skipped


def delete_dds_files(suffix): 
    liveries_path = CUSTOMS_PATH / "liveries"
    files = list(liveries_path.rglob(f"*{suffix}.dds"))
    if not files:
        print(f"No {suffix}.dds files found.")
        return
    for i, f in enumerate(files):
        time.sleep(0.005)
        f.unlink()
        progress_bar(i, len(files))
    print(f"Deleted {len(files)} {suffix}.dds files")


def main():
    print("What do you want the livery cleaner to do:\n1. Remove all liveries without Cars file (default)\n2. Remove _0.dds files\n3. Remove _1.dds files\n4. Remove all DDS files")

    while True:
        option = int(input("Enter Your Option: "))
        if 1 <= option <= 4:
            break
        else:
            print("\nEnter a valid option (1, 2, 3 or 4)")
        
    match option:
        case 2:
            print("\nRemoving all _0.dds files from your liveries directory. You can regenerate them by loading the livery in the menu")
            delete_dds_files("_0")

        case 3:
            print("\nRemoving all _1.dds files from your liveries directory. You can regenerate them by loading the livery on track")
            delete_dds_files("_1")

        case 4:
            print("\nRemoving all dds files from your liveries directory. You can regenerate them by loading the livery in the menu and on track")
            print("\nDeleting sponsors_0.dds and decals_0.dds")
            delete_dds_files("_0")

            print("\nDeleting sponsors_1.dds and decals_1.dds")
            delete_dds_files("_1")      
        case _:
            print("\nRemoving all livery files you don't have a car file for. You will only see the liveries you can select in the menu")
            skin_names, skipped = get_custom_skin_names()
            skin_names = set(skin_names)
            print(f"Parsed {len(skin_names)} unique skin names")
            if skipped:
                print(f"\nFailed to parse {len(skipped)} file(s):")
                for name, err in skipped:
                    print(f"  {name}: {err}")
            liveries_path = CUSTOMS_PATH / "liveries"
            dirs_to_delete = [d for d in liveries_path.iterdir() if d.is_dir() and d.name not in skin_names]
            if not dirs_to_delete:
                print("No unused livery directories found.")
            else:
                for i, d in enumerate(dirs_to_delete):
                    time.sleep(0.005)
                    shutil.rmtree(d)
                    progress_bar(i, len(dirs_to_delete))
                print(f"Deleted {len(dirs_to_delete)} unused livery director{'y' if len(dirs_to_delete) == 1 else 'ies'}")

    return 0


if __name__ == "__main__":
    sys.exit(main())

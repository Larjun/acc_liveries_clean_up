# ACC Livery Folder Clean Up Script
Removes ACC livery files for which a cars file does not exist. This is a Python script — no app needs to be installed beyond Python itself.

## Running on Windows

### 1. Download the script
1. On this page, click the green **Code** button near the top right
2. Select **Download ZIP**
3. Once downloaded, right-click the ZIP file and select **Extract All**
4. Choose a location you can easily find (e.g. your Desktop) and click **Extract**

### 2. Install Python
1. Go to [python.org/downloads](https://www.python.org/downloads/) and download the latest Python installer
2. Run the installer — **make sure to check "Add python.exe to PATH"** before clicking Install Now
3. Once installed, open **Command Prompt** (`Win + R`, type `cmd`, press Enter) and verify it worked:
   ```
   python --version
   ```

### 3. Run the script
1. Open the extracted folder and copy its file path from the address bar at the top of File Explorer
2. Open **Command Prompt** (`Win + R`, type `cmd`, press Enter)
3. Type `cd ` (with a space), paste the path, and press Enter:
   ```
   cd "C:\Users\YourName\Desktop\acc_liveries_clean_up"
   ```
4. Run the script:
   ```
   python cleaner.py
   ```
   If that doesn't work, try:
   ```
   python3 cleaner.py
   ```
5. Enter the number for the option you want and press Enter

## Options

| Option | What it does |
|--------|-------------|
| **1** (default) | Deletes livery folders you have no car file for — the ones you can't select in the menu anyway. Safe to run and the quickest way to free up space. |
| **2** | Deletes all `_0.dds` files (preview thumbnails). ACC regenerates these automatically the next time you open the livery in the menu. |
| **3** | Deletes all `_1.dds` files (in-game skin textures). ACC regenerates these the next time you drive with that livery on track. |
| **4** | Deletes all DDS files (both `_0` and `_1`). Use this for the most space savings — ACC will regenerate everything as you use each livery. |

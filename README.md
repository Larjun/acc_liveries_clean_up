# ACC Livery Folder Clean Up Script
Removes ACC livery files for which cars file do not exist. This is a python script and as such no app needs to be installed, just run python script after installing python.

## Running on Windows

### 1. Install Python
1. Go to [python.org/downloads](https://www.python.org/downloads/) and download the latest Python installer
2. Run the installer — **make sure to check "Add python.exe to PATH"** before clicking Install Now
3. Once installed, open **Command Prompt** (`Win + R`, type `cmd`, press Enter) and verify it worked:
   ```
   python --version
   ```

### 2. Run the script
1. In Command Prompt, navigate to the folder containing `cleaner.py`:
   ```
   cd "C:\path\to\acc_liveries_clean_up"
   ```
2. Run the script:
   ```
   python cleaner.py
   ```
   If that doesn't work, try:
   ```
   python3 cleaner.py
   ```
3. Enter the number for the option you want and press Enter

# Source Dir
SRCDIR = "ATK2_PATH_CYGWIN"

# Configfile name
CFGNAME = ['out']

# Target board
TARGET = "AKTSP_BOARD_NAME_ccrh"

# Target mcu
TARGET_MCU = 'AKTSP_MODEL_NO'

# Application files
app_app_files = ['out.c']

# Addition Dir list (relative path from srcdir)
USER_INCLUDE = ['aktsp/library/common', 'aktsp/library/implement/atk2', 'aktsp/library/arch/v850', 'aktsp/library/arch/v850/ccrh']

# Copy sample1
COPY_SAMPLE1 = False

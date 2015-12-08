# --------------------------------------------------------------------------------
# --- Defining OS and Archi
# --------------------------------------------------------------------------------
include ../_mkf/MakefileOS.mk

# ---- Detection of Compilers
include _mkf/MakefileFortranDetectIfort.mk
include _mkf/MakefileFortranDetectGfortran.mk
# --------------------------------------------------------------------------------
# ---  
# --------------------------------------------------------------------------------
RELEASE=1
FCOMPILER=1
OBJ_DIR_BASE=_build
LIB_DIR_BASE=..$(SLASH)_lib
INC_DIR_BASE=_inc

MAKE_DLL=1
MAKE_STATIC=1

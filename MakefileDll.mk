# --------------------------------------------------------------------------------
# --- Setup Fortran Compiler
# --------------------------------------------------------------------------------
include ../_mkf/MakefileFortran.mk

# Note: This is a default makefile to compile a library
#
# --------------------------------------------------------------------------------
# --- Defining variables based on OS and fortran
# --------------------------------------------------------------------------------
SUPPORT=$(strip $(OS_NAME))-$(strip $(ARCHI))-$(strip $(FC))
ifeq ($(RELEASE),0)
    SUPPORT:=$(SUPPORT)-debug
endif
LIB_DIR=$(LIB_DIR_BASE)-$(SUPPORT)
INC_DIR=$(LIB_DIR)$(SLASH)$(INC_DIR_BASE)
OBJ_DIR=$(OBJ_DIR_BASE)-$(SUPPORT)
LIB_NAME= $(LIB_NAME_BASE)
ifeq ($(OS_NAME),linux)
    LIB_NAME=lib$(LIB_NAME_BASE)
endif

ifeq ($(MAKE_STATIC),1)
    RULES+= $(LIB_DIR)$(SLASH)$(LIB_NAME).$(lib)
endif
ifeq ($(MAKE_DLL),1)
    RULES+= $(LIB_DIR)$(SLASH)$(LIB_NAME).$(dll)
endif
# --------------------------------------------------------------------------------
# --- INCLUDES 
# --------------------------------------------------------------------------------
INCS=-I$(INC_DIR)
# --------------------------------------------------------------------------------
# --- DEFINITIONS
# --------------------------------------------------------------------------------
DEFS=$(OS_DEF) -D__MAKEFILE__
# --------------------------------------------------------------------------------
# --- Compiler Flags 
# --------------------------------------------------------------------------------
FFLAGS    = $(FFNOLOGO) $(FFMODINC)$(OBJ_DIR)
FFLAGS   += $(FFDLL)
ifeq ($(RELEASE),0)
    FFLAGS   += $(FFDEBUGINFO) $(FFDEBUG) $(FFPE) $(FFWARN) $(FFWARNEXTRA) $(FFWARNERROR) $(FFOPT0)
    FFLAGS   += $(FFTRACE)
    BUILD=debug
else
    FFLAGS   += $(FFOPTO5)
    BUILD=release
endif
FFLAGS   += $(FFLAGS_EXTRA)
#
# --------------------------------------------------------------------------------
# ---  ARCHIVER flags
# --------------------------------------------------------------------------------
ifeq ($(AR),Lib)
    ARFLAGS=$(FFNOLOGO)
else
	# v: verbose
	# r: insert with replacement
	# c: create
	# q: quickly append without checking for replacements
    #ARFLAGS=-cq 
    
endif
ARFLAGS+= $(ARFLAGS_EXTRA)

# --------------------------------------------------------------------------------
# --- Linker flags 
# --------------------------------------------------------------------------------
ifeq ($(OS_NAME),windows)
    ifeq ($(LD),ld)
        # We erase LD
        LD=$(FC) -shared -mrtd $(LIB_NAME).def 
        LDFLAGS=-Wl,--enable-runtime-pseudo-reloc,-no-undefined
    else
	    # WINDOWS - IFORT
        LDFLAGS=$(LD_DLL) /def:$(LIB_NAME).def  
        ifeq ($(ARCHI),ia32)
            LDFLAGS+=/DLL kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib
        endif
    endif
endif
LDFLAGS+= $(LDFLAGS_EXTRA)


# --------------------------------------------------------------------------------
# --- Defining Objects based on SRC
# --------------------------------------------------------------------------------
# Setting up objects
OBJ:= $(patsubst %.f90,%.$(o),$(SRC)) 
OBJ:= $(patsubst %.F90,%.$(o),$(OBJ))
OBJ:= $(patsubst %.for,%.$(o),$(OBJ))
OBJ:= $(patsubst %,$(OBJ_DIR)/%,$(OBJ))


vpath %.f90 
vpath %.F90
vpath %.for

# --------------------------------------------------------------------------------
# --- Main rules  
# --------------------------------------------------------------------------------
.PHONY: lib all clean flags

all: $(RULES)

clean:
ifeq ($(OS_NAME),windows)
	@if exist $(OBJ_DIR) $(RMDIR) $(OBJ_DIR) $(ERR_TO_NULL)
else
	@$(RMDIR) $(OBJ_DIR) $(ERR_TO_NULL)
endif
	@echo "- $(LIB_NAME_BASE) lib cleaned"

purge: clean
	@$(RM) $(LIB_DIR)$(SLASH)$(LIB_NAME)* $(ERR_TO_NULL)
	@echo "- $(LIB_NAME_BASE) lib purged"


# --------------------------------------------------------------------------------
# ---  Static library
# --------------------------------------------------------------------------------
$(LIB_DIR)$(SLASH)$(LIB_NAME).$(lib): $(LIB_DIR) $(INC_DIR) $(OBJ_DIR) $(OBJ)
	@echo "----------------------------------------------------------------------"
	@echo "- Compiling static library:  " $(LIB_DIR)$(SLASH)$(LIB_NAME).$(lib)
	@echo "----------------------------------------------------------------------"
	$(AR) $(ARFLAGS) $(AR_OUT)$(LIB_DIR)$(SLASH)$(LIB_NAME).$(lib) $(OBJ)
	@$(TOUCH) $(OBJ_DIR)$(SLASH)dummy.mod
	@$(CP) $(OBJ_DIR)$(SLASH)*.mod $(INC_DIR)
	@$(RM) $(OBJ_DIR)$(SLASH)dummy.mod
	@$(RM) $(INC_DIR)$(SLASH)dummy.mod

# --------------------------------------------------------------------------------
# ---  DLL library
# --------------------------------------------------------------------------------
$(LIB_DIR)$(SLASH)$(LIB_NAME).$(dll): $(LIB_DIR) $(INC_DIR) $(OBJ_DIR) $(OBJ)
	@echo "----------------------------------------------------------------------"
	@echo "- Compiling dynamic library: " $(LIB_DIR)$(SLASH)$(LIB_NAME).$(dll)
	@echo "----------------------------------------------------------------------"
ifeq ($(OS_NAME),windows)
	$(LD) $(LDFLAGS) $(LD_OUT)"$(LIB_DIR)$(SLASH)$(LIB_NAME).$(dll)" $(OBJ_DIR)$(SLASH)*.$(o)
else
	@$(FC) $(DEFS) $(INCS) $(LDFLAGS) -shared -Wl,-soname,$(LIB_NAME).$(dll).1  $(OBJ_DIR)$(SLASH)*.$(o) $(LIBS) $(LD_OUT)$(LIB_DIR)$(SLASH)$(LIB_NAME).$(dll) 
endif


# --------------------------------------------------------------------------------
# --- Low-level Compilation rules 
# --------------------------------------------------------------------------------
include ../_mkf/MakefileDefaultCompile.mk


# --------------------------------------------------------------------------------
# --- DEPENDENCIES 
# --------------------------------------------------------------------------------
# Creating build directory
$(OBJ_DIR):
	@make --no-print-directory flags
	@$(MKDIR) $(OBJ_DIR)

$(LIB_DIR):
	@$(MKDIR) $(LIB_DIR)

$(INC_DIR):
	@$(MKDIR) $(INC_DIR)

# --------------------------------------------------------------------------------
# --- SIMPLE RULES 
# --------------------------------------------------------------------------------
include ../_mkf/MakefileSimpleRules.mk

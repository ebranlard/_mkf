include $(OMNIVOR_MKF_DIR).config.mk

########################################################################
### MAKEFILE FLAGS (MAY BE OVERRIDEN BY CALLEE/INCLUDEE)
####################################################################### 
ifeq ($(FCOMPILER),) # FCOMPILER: 0: gfortran  1: intel fortran  2: Sun Fortran f90
    FCOMPILER =1
endif
ifeq ($(RELEASE),) # RELEASE: 1: Release  0: debug
    RELEASE =1
endif
ifeq ($(PRECISION),) # PRECISION: 1: SINGLE-FLOAT, 2: DOUBLE
    PRECISION=2
endif
ifeq ($(OPENMP),)# OPENMP: 0 or 1
    OPENMP=1
endif
ifeq ($(MPI),) # MPI: 0 or 1
    MPI=0
endif
ifeq ($(CUDA),)
   CUDA=0
endif
ifeq ($(C),) # C: 0 or 1
    C=1
endif
ifeq ($(VPM),) # VPM: 0 or 1
    VPM=0
endif
ifeq ($(CCOMPILER),) # C: 0 or 1
	# CCOMPILER: 0: gcc, 1: intel c/c++
    CCOMPILER =$(FCOMPILER)
endif
ifeq ($(LIB_ACCELERATOR),)
	# LIB_ACCELERATOR: 0: MKL sequential, 1: MKL multi_thread, 2: standard libraries, 3: custom linking
    LIB_ACCELERATOR=1
    ifeq ($(VPM),1) 
        LIB_ACCELERATOR=1
    endif
endif
ifeq ($(HAWC),)
	# HAWC: 0: No hawc, 1: Hawc2aero, 2: hawc2
    HAWC =0
endif

# for backward compatibility
NOHAWC =1
# ACCELERATOR: 0: OPENMP, 1: CUDA, 2: OPENMP-AND-C, 3: TREE-CODE, 4: POISSON-SOLVER

SHELL := /bin/bash
######################################################################## }}}
### OS
####################################################################### {{{
# Defines: OS, ARCHI, HOSTNAME, and Commands like CP, RM
include $(OMNIVOR_MKF_DIR)MakefileOS.mk

######################################################################## }}}
### Main paths 
####################################################################### {{{
f=f90
c=c
cu=cu
OBJ_DIR_RAW   = _build
LIB_DIR_RAW   = _lib
BIN_DIR_RAW   = _bin
DOC_DIR       = _doc
LIBMOUF   = mouffette
LIBCHIP   = chipmunk
LIBRACC   = raccoon
LIBLINK   = link
LIBHAWC   = hawc2
INC_DIR   = _includes
DEP_DIR   = _build
UP_DIR    = ../

ifeq ($(RELEASE),0)
    BUILD=debug
else
    BUILD=release
endif
######################################################################## }}}
### Using OS Archi for directory hierarchy
####################################################################### {{{
OBJ_DIR2:= $(OBJ_DIR_RAW)$(SLASH)$(OSNAME)-$(ARCHI)$(SLASH)$(BUILD)
OBJ_DIR := $(OBJ_DIR_RAW)/$(OSNAME)-$(ARCHI)/$(BUILD)
BIN_DIR := $(BIN_DIR_RAW)$(SLASH)$(OSNAME)-$(ARCHI)
LIB_DIR := $(LIB_DIR_RAW)$(SLASH)$(OSNAME)-$(ARCHI)
DEP_FIL := $(DEP_DIR)$(SLASH)depend-$(OSNAME)-$(ARCHI)



######################################################################## }}}
### Fortran flags
####################################################################### {{{
include $(OMNIVOR_MKF_DIR)MakefileFortran.mk
ifeq ($(CUSTOM_FFLAGS),)
	# Automatic configuration of FFLAGS
    FFLAGS    = $(FFNOLOGO) $(FFFREE) $(FFMODINC)$(OBJ_DIR)
    FFLAGS   += $(FFDLL)
    FFLAGS_BASE:=$(FFLAGS)
    # FFLAGS   += $(FFFPP)
    # FFLAGS   += -I./$(INC_DIR)
    # FFLAGS   += $(FFF95)
    # FFLAGS   += $(FFBYTERECL)  # !!!!!!!!!!!!!!!!! Important for this program
    ifeq ($(RELEASE),0)
        FFLAGS   += $(FFDEBUGINFO)
        FFLAGS   += $(FFDEBUG)
        FFLAGS   += $(FFPE)
    #     FFLAGS   += $(FFDEBUGARG)   # warn for array copies
        FFLAGS   += $(FFWARN)
        FFLAGS   += $(FFWARNEXTRA)
        FFLAGS   += $(FFWARNERROR)
        FFLAGS   += $(FFOPT0)
    else
        FFLAGS   += $(FFOPTO5)
    endif
    FFLAGS   += $(FFTRACE)
    
    ifeq ($(OSNAME),windows) 
        FFLAGS+= -threads -dbglibs /Qmkl:sequential # VERY IMPORTANT, otherwise message of LAPACK not found at linking
    endif
else
	# Using user defined FFLAGS
    FFLAGS:=$(CUSTOM_FFLAGS)
endif
FFLAGS:=$(FFLAGS) $(EXTRA_FFLAGS)

######################################################################## }}}
### C flags
####################################################################### {{{
include $(OMNIVOR_MKF_DIR)MakefileC.mk
ifeq ($(CUSTOM_CFLAGS),)
	# Automatic configuration of CFLAGS
    CFLAGS    = $(CFDLL)
    CFLAGS   += -I$(OBJ_DIR)
    CFLAGS   += $(CFC99)
    ifeq ($(RELEASE),0)
        CFLAGS   += $(CFDEBUGINFO)
        CFLAGS   += $(CFDEBUG)
        CFLAGS   += $(CFWARN)
        CFLAGS   += $(CFWARNEXTRA)
        CFLAGS   += $(CFWARNERROR)
    else
        CFLAGS   += $(CFOPTO5)
    endif
    # CFLAGS   += $(CFTRACE)
else
	# Using user defined CFLAGS
    CFLAGS:=$(CUSTOM_CFLAGS)
endif
CFLAGS+=$(EXTRA_CFLAGS)

######################################################################## }}}
### CUDA flags
####################################################################### {{{
include $(OMNIVOR_MKF_DIR)MakefileCUDA.mk
NVCFLAGS   += $(NVCFOPT) $(NVCFDEBUGINFO)

######################################################################## }}}
### SUPPORTS
####################################################################### {{{
SUPPORT=
SUPPORTFLAGS=
SUPPORT_DIR=
NOSUPPORT=
ifeq ($(OPENMP),1)
    SUPPORT:=$(SUPPORT)-openmp
    CFLAGS   += $(CFOPENMP)
    LIBS_OMP += $(CFOPENMP)
    LIBS_OMP += $(FFOPENMP)
    SUPPORTFLAGS += $(FFOPENMP)
    SUPPORT_DIR +=omnivor/badger/omp
    NOSUPPORT:=$(NOSUPPORT)"-------"
else
    SUPPORT_DIR +=omnivor/badger/omp0
endif
ifeq ($(MPI),1)
ifeq ($(OPENMP),0)
	$(warning "MPI without OpenMP, support might fail")
endif
    SUPPORT:=$(SUPPORT)-mpi
    SUPPORTFLAGS += -lmpi
    LIBS_MPI += -lmpi
	# Overriding compiler
    FC  =   $(MPIFC)
    SUPPORT_DIR +=omnivor/badger/mpi
    SUPPORT_DIR +=fortlib/portability/mpi1
    NOSUPPORT:=$(NOSUPPORT)"----"
else
    SUPPORT_DIR +=omnivor/badger/mpi0
    SUPPORT_DIR +=fortlib/portability/mpi0
    MPIRUN=
    RUN=
endif
ifeq ($(C),1)
    SUPPORT:=$(SUPPORT)-c
    INLINED_UI_DIR=omnivor/chipmunk/C
    SUPPORT_DIR +=omnivor/chipmunk/C
    NOSUPPORT:=$(NOSUPPORT)"--"
else
    INLINED_UI_DIR=omnivor/chipmunk/Fortran
    SUPPORT_DIR +=omnivor/chipmunk/Fortran
endif
ifeq ($(VPM),1)
ifeq ($(MPI),0)
    VPM=0
    $(warning "VPM without MPI, support might fail")
    SUPPORT_DIR +=omnivor/badger/vpm0
else
    SUPPORT:=$(SUPPORT)-vpm
    SUPPORT_DIR +=omnivor/badger/vpm
    NOSUPPORT:=$(NOSUPPORT)"----"
endif
else
    SUPPORT_DIR +=omnivor/badger/vpm0
endif
ifeq ($(CUDA),1)
    SUPPORT:=$(SUPPORT)-cuda
    ACC_DIR    =omnivor/mouffette/cuda
    LIBS_CUDA += -L/usr/local/cuda/lib64 -I/usr/local/cuda/include -lcudart -lcuda -lstdc++ $(CFOPENMP)
    SUPPORT_DIR +=omnivor/badger/cuda
    NOSUPPORT:=$(NOSUPPORT)"-----"
else
    SUPPORT_DIR +=omnivor/badger/cuda0
endif
ifeq ($(LIB_ACCELERATOR),3)
    SUPPORT_DIR +=fortlib/portability/mkl0
else
    ifeq ($(LIB_ACCELERATOR),2)
        SUPPORT_DIR +=fortlib/portability/mkl0
    else
        SUPPORT:=$(SUPPORT)-mkl
        NOSUPPORT:=$(NOSUPPORT)"----"
        SUPPORT_DIR +=fortlib/portability/mkl1
    endif
endif

# --------------------------------------------------------------------------------
# --- LIBS 
# --------------------------------------------------------------------------------
ifeq ($(CUSTOM_LIBS),)
	# Automatic configuration of LIBS
    LIBS=$(LIBS_OMP) $(LIBS_MKL) $(LIBS_LAPACK) $(LIBS_MPI)
else
	# Using user defined LIBS
    LIBS:=$(CUSTOM_LIBS)
endif
LIBS+=$(EXTRA_LIBS)

# --------------------------------------------------------------------------------
# --- Includes 
# --------------------------------------------------------------------------------
ifeq ($(CUSTOM_INCS),)
	# Automatic configuration of INCS
    INCS   += -I$(OBJ_DIR)
else
	# Using user defined INCS
    INCS:=$(CUSTOM_INCS)
endif
INCS+=$(EXTRA_INCS)

# --------------------------------------------------------------------------------
# --- DEFINITIONS for Preprocessor
# --------------------------------------------------------------------------------
ifeq ($(CUSTOM_DEFS),)
	# Automatic configuration of DEFS
    # Forcing OS
    DEFS+= $(OSDEF)
    # hawc2
    ifeq ($(HAWC),2)
        DEFS +=  -DHAWC2 -DSYMSYS -DBANDEDKEFF 
    endif
else
	# Using user defined DEFS
    DEFS:=$(CUSTOM_DEFS)
endif
DEFS+=$(EXTRA_DEFS) 

# --------------------------------------------------------------------------------
# --- Linker FLAGS 
# --------------------------------------------------------------------------------
ifeq ($(CUSTOM_LDFLAGS),)
	# Automatic configuration of LDFLAGS
    LDFLAGS+=$(LDFLAGS_MKL) $(LDFLAGS_LAPACK)
else
	# Using user defined LDFLAGS
    LDFLAGS:=$(CUSTOM_LDFLAGS)
endif
LDFLAGS+=$(EXTRA_LDFLAGS) 

# TODO
LDFLAGS_DLL:=$(EXTRA_LDFLAGS) $(LDFLAGS_DLL) 

# --------------------------------------------------------------------------------
# ---  
# --------------------------------------------------------------------------------
# A bit of a specificity for this makefile
FFLAGS_ALL=$(DEFS) $(INCS) $(FFLAGS)






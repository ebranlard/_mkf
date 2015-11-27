c=c
# 0: Gnu compiler GCC
# 1: intel C Compiler icc
# 2: visual studio compiler cl.exe

# INTEL C COMPILER
ifeq ($(CCOMPILER),1)
    CC         = icc
    COUT       = -o
    CFFREE     =
    CFOPT      = -O3
    CFOPTO5    = -O3
    CFACC      = #-offload-build #-no-offload
    CFOPENMP   = -openmp
    CFWARN     = -Wall
    CFDEBUGINFO= -g
    CFDEBUG    = 
    CFMODINC   =
    CFAUTOPAR  = -parallel -par-report1
    CFFPP      = -fpp
    CFC99      = -std=c99
    CFDLL      = -fPIC
    CFTRACE    = -traceback
ifeq ($(OSNAME),windows)
    CFOPENMP   = -Qopenmp
    CFDLL      = /libs:dll 
endif
endif
# Gcc COMPILER
ifeq ($(CCOMPILER),0)
    CC         = gcc
    COUT       = -o
    CFFREE     =
    CFOPT      = -O3
    CFOPTO5    = -O5
    CFACC      = #-offload-build #-no-offload
    CFOPENMP   = -fopenmp
    CFWARN     = -Wall
    CFDEBUGINFO= -g
    CFDEBUG    = 
    CFMODINC   =
    CFAUTOPAR  = -parallel -par-report1
    CFFPP      = -fpp
    CFC99      = -std=c99
    CFDLL      = -fPIC
    CFTRACE    = -traceback
endif

# Visual Compiler
ifeq ($(CCOMPILER),2)
    CC         = cl /nologo
    COUT       = /Fe
endif


# --------------------------------------------------------------------------------
# --- USER Overrides 
# --------------------------------------------------------------------------------
ifneq ($(CUSTOM_CC),)
    CC=$(CUSTOM_CC)
endif

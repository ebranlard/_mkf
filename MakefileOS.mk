# This make file should maybe be updated according to: http://mad-scientist.net/make/multi-arch.html
#--------------------------------------------------------------------------------
# ---  Architecture, system name, objects
# --------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
    OSNAME=windows
    ARCHI=win32
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
        ARCHI=amd64
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
        ARCHI=ia32
    endif
 	# Object file extension
	o=obj

else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
         OSNAME=linux
	else ifeq ($(UNAME_S),Darwin)
        OSNAME=mac
    endif
    UNAME_P := $(shell uname -p)
    UNAME_M := $(shell uname -m)
    ifeq ($(UNAME_M),x86_64)
        ARCHI=amd64
	# STUFF BELOW NEED TO BE re-tested..
	else ifneq ($(filter %86,$(UNAME_P)),)
        ARCHI=ia32
	else ifneq ($(filter arm%,$(UNAME_P)),)
        ARCHI=arm
	else ifneq ($(filter unknown%,$(UNAME_P)),)
        ARCHI=ia32
    endif
 
 	# Object file extension
	o=o

endif

#--------------------------------------------------------------------------------
# ---  System Commands
# --------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
    # System
    RM=del /q
    LN=copy /y
    CP=copy /y
    MKDIR=mkdir 
    SLASH=/
    SLASH := $(subst /,\,$(SLASH))
    TOUCH=echo.>
    MKDEPF=./_tools/makedepf90.exe
    SHELL=cmd.exe
    LINK=link.exe
    CAT=type
    ECHOSAFE=echo(
else
    # System
    RM=rm -rf
    LN=ln -sf
    CP=cp
    MKDIR=mkdir -p
    SLASH=/
    TOUCH=touch
    MKDEPF=./_tools/makedepf90
    SHELL=/bin/bash
    LINK=LD
    CAT=cat
    ECHOSAFE=echo 
endif



HOSTNAME=$(shell hostname)

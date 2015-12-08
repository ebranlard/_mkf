# --------------------------------------------------------------------------------
# --- Simple rules
# --------------------------------------------------------------------------------
# Convenient rule to print any variable
echo-%:
	@echo '$*=$($*)'


flags:
	@echo ""
	@echo "OS-Archi:           " $(OS_NAME)-$(OS_ARCHI)
	@echo ""
	@echo "SUPPORT-Archi-buid: " $(SUPPORT) $(ARCHI) $(BUILD)
	@echo ""
	@echo "Compilers:          " $(FC) $(CC)
	@echo ""
	@echo "C FLAGS:            " $(CFLAGS)
	@echo ""
	@echo "Fortran FLAGS:      " $(FFLAGS)
	@echo ""
	@echo "Linker  & FLAGS:    " $(LD) $(LDFLAGS)
	@echo ""
	@echo "Archiver& FLAGS:    " $(AR) $(ARFLAGS)
	@echo ""
	@echo "INCLUDES:           " $(INCS)
	@echo ""
	@echo "DEFS:               " $(DEFS)
	@echo ""
	@echo "LIBS:               " $(LIBS)
	@echo ""

#  REVISION INFORMATION  ######################################################
#
#  _Author: rao $
#  _Date: 2002/03/21 16:49:47 $
#  _Revision: 1.1 $
#  _Source: /cvsroot/gnuspeech/gnuspeech/trillium/ObjectiveC/Monet/tube_module/Makefile,v $
#  _State: Exp $
#
#
#  _Log: Makefile,v $
#  Revision 1.1  2002/03/21 16:49:47  rao
#  Initial import.
#
# Revision 1.5  1995/04/04  01:57:42  len
# Added "median pitch" volume scaling.
#
# Revision 1.4  1995/03/07  18:14:20  len
# Changed Makefile so it now uses libtool, instead of a combination
# of ld and lipo, to create the FAT synthesizer_module.a.
#
# Revision 1.3  1995/02/27  17:29:07  len
# Added support for Intel MultiSound DSP.  Module now compiles FAT.
#
# Revision 1.1.1.1  1994/09/06  21:45:49  len
# Initial archive into CVS.
#
#
###############################################################################
#  Makefile to create test_synth.
#
#  Do "make" or "make all" to create the complete test suite.
#  Do "make dsp" to create just the dsp-related files.
#  Do "make module" to create just the synthesizer module files.
#  Do "make clean" to clean up the directory
#  Do "make help" to list the available make targets.
#
###############################################################################


#  names of c source files
TEST_NAME = test_synth
MODULE_NAME = synthesizer_module
CONVERSION_NAME = conversion
OVERSAMPLING_NAME = oversampling_filter
SR_CONVERSION_NAME = sr_conversion
FFT_NAME = fft
SNDDRIVER_NAME = ttsSnddriver
SCALING_NAME = scaling

#  names of dsp assembly source files
DSP_NAME_BLACK = synthesizer_black
DSP_NAME_WHITE = synthesizer_white
DSP_NAME_WHITE_SSI = synthesizer_white_ssi
LOADER = loader
BOOTER = bootstrap



#  name of dsp core files
DSPCORE_BLACK = dspcore_black.h
DSPCORE_WHITE = dspcore_white.h
DSPCORE_WHITE_SSI = dspcore_white_ssi.h

#  name of dsp core file which contains the bootstrap dsp instructions
BOOTERCORE = bootstrap.h

#  command which converts the bootstrap.lod file to bootstrap.h
BTPREP = bootstrapPrep

#  name of dsp core file which contains the loader dsp instructions
LOADERCORE = loader.h

#  command which converts the loader.lod file to loader.h
LDPREP = loaderPrep


#  put object files in these subdirectories
OBJ_DIR = obj
DSP_OBJ_DIR = dsp_obj


#  object files are in object subdirectories
TEST_OBJ = $(OBJ_DIR)/$(TEST_NAME).o
MODULE_OBJ = $(OBJ_DIR)/$(MODULE_NAME).o
CONVERSION_OBJ = $(OBJ_DIR)/$(CONVERSION_NAME).o
OVERSAMPLING_OBJ = $(OBJ_DIR)/$(OVERSAMPLING_NAME).o
SR_CONVERSION_OBJ = $(OBJ_DIR)/$(SR_CONVERSION_NAME).o
FFT_OBJ = $(OBJ_DIR)/$(FFT_NAME).o
SNDDRIVER_OBJ = $(OBJ_DIR)/$(SNDDRIVER_NAME).o
SCALING_OBJ = $(OBJ_DIR)/$(SCALING_NAME).o


DSP_OBJ_BLACK = $(DSP_OBJ_DIR)/$(DSP_NAME_BLACK).lod
DSP_OBJ_WHITE = $(DSP_OBJ_DIR)/$(DSP_NAME_WHITE).lod
DSP_OBJ_WHITE_SSI = $(DSP_OBJ_DIR)/$(DSP_NAME_WHITE_SSI).lod
BOOTER_OBJ = $(DSP_OBJ_DIR)/$(BOOTER).lod
LOADER_OBJ = $(DSP_OBJ_DIR)/$(LOADER).lod


MODULE_LIB = $(OBJ_DIR)/$(MODULE_NAME).a


#  command which converts the .lod file to dspcore.h
DSPLOD2CORE = /usr/local/bin/dspLod2Core


#  path where dsp equate files are stored
INCLUDE_PATH = /LocalDeveloper/Headers/DSPEquates


#  flags and libraries
#  Add -DDEBUG and -g to DFLAGS if debugging desired, and comment out
#  the "strip" below.
DFLAGS = 
CFLAGS = -O -Wall $(DFLAGS)
LIBS = -ldsp -lNeXT_s -lDriver
ARCHS = -arch m68k -arch i386



all:: $(TEST_NAME)

$(TEST_NAME): $(TEST_OBJ) $(MODULE_LIB)
	cc -o $@ $(TEST_OBJ) $(MODULE_LIB) $(ARCHS) $(LIBS) $(CFLAGS)
	strip $@

$(TEST_OBJ): $(OBJ_DIR) $(TEST_NAME).c $(MODULE_NAME).h
	cc -c $(TEST_NAME).c -o $@ $(ARCHS) $(CFLAGS)



$(MODULE_LIB): $(OBJ_DIR) $(MODULE_OBJ) $(CONVERSION_OBJ) $(OVERSAMPLING_OBJ) \
		$(SR_CONVERSION_OBJ) $(FFT_OBJ) $(SNDDRIVER_OBJ) \
		$(SCALING_OBJ)
	libtool -o $@ $(MODULE_OBJ) $(CONVERSION_OBJ) $(OVERSAMPLING_OBJ) \
		$(SR_CONVERSION_OBJ) $(FFT_OBJ) $(SNDDRIVER_OBJ) \
		$(SCALING_OBJ)



$(MODULE_OBJ): $(MODULE_NAME).c $(MODULE_NAME).h $(DSPCORE_BLACK) \
		$(DSPCORE_WHITE) $(DSPCORE_WHITE_SSI)
	cc -c $(MODULE_NAME).c -o $@ $(ARCHS) $(CFLAGS)

$(CONVERSION_OBJ): $(CONVERSION_NAME).c $(CONVERSION_NAME).h $(MODULE_NAME).h \
		$(SR_CONVERSION_NAME).h
	cc -c $(CONVERSION_NAME).c -o $@ $(ARCHS) $(CFLAGS)

$(OVERSAMPLING_OBJ): $(OVERSAMPLING_NAME).c $(OVERSAMPLING_NAME).h
	cc -c $(OVERSAMPLING_NAME).c -o $@ $(ARCHS) $(CFLAGS)

$(SR_CONVERSION_OBJ): $(SR_CONVERSION_NAME).c $(SR_CONVERSION_NAME).h
	cc -c $(SR_CONVERSION_NAME).c -o $@ $(ARCHS) $(CFLAGS)

$(FFT_OBJ): $(FFT_NAME).c $(FFT_NAME).h
	cc -c $(FFT_NAME).c -o $@ $(ARCHS) $(CFLAGS)

$(SNDDRIVER_OBJ): $(SNDDRIVER_NAME).c $(SNDDRIVER_NAME).h $(BOOTERCORE) $(LOADERCORE)
	cc -c $(SNDDRIVER_NAME).c -o $@ $(ARCHS) $(CFLAGS)

$(SCALING_OBJ): $(SCALING_NAME).c $(SCALING_NAME).h $(CONVERSION_NAME).h
	cc -c $(SCALING_NAME).c -o $@ $(ARCHS) $(CFLAGS)



$(DSPCORE_BLACK): $(DSP_OBJ_BLACK)
	$(DSPLOD2CORE) $(DSP_OBJ_BLACK) $(DSPCORE_BLACK)

$(DSP_OBJ_BLACK): $(DSP_OBJ_DIR) $(DSP_NAME_BLACK).asm synthesizer.asm
	asm56000 -a -b$@ -I$(INCLUDE_PATH) -l$(DSP_NAME_BLACK).lst \
		$(DSP_NAME_BLACK).asm

$(DSPCORE_WHITE): $(DSP_OBJ_WHITE)
	$(DSPLOD2CORE) $(DSP_OBJ_WHITE) $(DSPCORE_WHITE)

$(DSP_OBJ_WHITE): $(DSP_OBJ_DIR) $(DSP_NAME_WHITE).asm synthesizer.asm
	asm56000 -a -b$@ -I$(INCLUDE_PATH) -l$(DSP_NAME_WHITE).lst \
		$(DSP_NAME_WHITE).asm

$(DSPCORE_WHITE_SSI): $(DSP_OBJ_WHITE_SSI)
	$(DSPLOD2CORE) $(DSP_OBJ_WHITE_SSI) $(DSPCORE_WHITE_SSI)

$(DSP_OBJ_WHITE_SSI): $(DSP_OBJ_DIR) $(DSP_NAME_WHITE_SSI).asm synthesizer.asm
	asm56000 -a -b$@ -I$(INCLUDE_PATH) -l$(DSP_NAME_WHITE_SSI).lst \
		$(DSP_NAME_WHITE_SSI).asm


$(DSP_OBJ_DIR):
	mkdirs $@

$(OBJ_DIR):
	mkdirs $@


$(BOOTERCORE): $(BOOTER_OBJ) $(BTPREP)
	$(BTPREP) $(BOOTER_OBJ) $(BOOTERCORE)

$(BOOTER_OBJ): $(BOOTER).asm
	asm56000 -a -b$@ -I$(INCLUDE_PATH) -l$(DSP_OBJ_DIR)/$(BOOTER).lst\
		$(BOOTER).asm

$(BTPREP): $(BTPREP).c
	cc -o $@ $(BTPREP).c $(ARCHS) $(CFLAGS)
	strip $@


$(LOADERCORE): $(LOADER_OBJ) $(LDPREP)
	$(LDPREP) $(LOADER_OBJ) $(LOADERCORE)

$(LOADER_OBJ): $(LOADER).asm
	asm56000 -a -b$@ -I$(INCLUDE_PATH) -l$(DSP_OBJ_DIR)/$(BOOTER).lst\
		$(LOADER).asm

$(LDPREP): $(LDPREP).c
	cc -o $@ $(LDPREP).c $(ARCHS) $(CFLAGS)
	strip $@



#  target to create just the DSP-related files
dsp:: $(DSP_OBJ_BLACK) $(DSP_OBJ_WHITE) $(DSP_OBJ_WHITE_SSI)


#  target to create just the module
module:: $(MODULE_LIB)


#  target to clean up all files in directory
clean::
	/bin/rm -Rf $(OBJ_DIR) $(DSP_OBJ_DIR) $(DSPCORE_BLACK)\
		$(DSPCORE_WHITE) $(DSPCORE_WHITE_SSI) $(DSP_NAME_BLACK).lst\
		$(DSP_NAME_WHITE).lst $(DSP_NAME_WHITE_SSI).lst\
		$(LOADERCORE) $(LDPREP)\
		$(BOOTERCORE) $(BTPREP)



#  target to list all target options
help::
	@ echo "'make all' (or just 'make') - makes the complete test suite"
	@ echo "'make dsp' - makes just the dsp-related files"
	@ echo "'make module' - makes just the synthesizer module files"
	@ echo "'make clean' - cleans unnecessary files from the directory"
	@ echo "'make help' - prints this message to screen\n"

#
# GNUmakefile 
# Written by Gregory John Casamento <greg_casamento@yahoo.com>
#
# NOTE: Do NOT change this file -- ProjectCenter maintains it!
#
# Put all of your customisations in GNUmakefile.preamble and
# GNUmakefile.postamble
#

include $(GNUSTEP_MAKEFILES)/common.make
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)


#
# Subprojects
#



#
# Library
#

PACKAGE_NAME=MonetExtensions
LIBRARY_VAR=MonetExtensions
LIBRARY_NAME=libMonetExtensions
libMonetExtensions_HEADER_FILES_DIR=.
libMonetExtensions_HEADER_FILES_INSTALL_DIR=/MonetExtensions
ADDITIONAL_INCLUDE_DIRS = -I..
srcdir = .

#
# Additional libraries
#

libMonetExtensions_LIBRARIES_DEPEND_UPON += -lgnustep-gui -l$(FOUNDATION_LIBRARY_NAME)

#
# Header files
#

libMonetExtensions_HEADER_FILES= \
NSArray-Extensions.h \
NSBezierPath-Extensions.h \
NSCharacterSet-Extensions.h \
NSColor-STExtensions.h \
NSNumberFormatter-Extensions.h \
NSObject-Extensions.h \
NSOutlineView-Extensions.h \
NSPopUpButton-Extensions.h \
NSScanner-Extensions.h \
NSString-Extensions.h \
NSUserDefaults-Extensions.h

#
# Class files
#

libMonetExtensions_OBJC_FILES= \
NSArray-Extensions.m \
NSBezierPath-Extensions.m \
NSCharacterSet-Extensions.m \
NSColor-STExtensions.m \
NSNumberFormatter-Extensions.m \
NSObject-Extensions.m \
NSOutlineView-Extensions.m \
NSPopUpButton-Extensions.m \
NSScanner-Extensions.m \
NSString-Extensions.m \
NSUserDefaults-Extensions.m

#
# C files
#

libMonetExtensions_C_FILES= 

HEADERS_INSTALL = $(libMonetExtensions_HEADER_FILES)

-include GNUmakefile.preamble
-include GNUmakefile.local
include $(GNUSTEP_MAKEFILES)/library.make
-include GNUmakefile.postamble

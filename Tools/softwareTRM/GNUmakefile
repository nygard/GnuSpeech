#
#  Copyright (C) 2001, 2002
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#   
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#   
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

SUBPROJECTS = $(BUILD_GSND)
TOOL_NAME = tube

# The source files to be compiled
tube_OBJC_FILES = TRMSynthesizer.m \
MMSynthesisParameters.m

tube_C_FILES = \
fir.c \
input.c \
main.c \
output.c \
ring_buffer.c \
tube.c \
util.c \
wavetable.c

# kind of a kludge.
ADDITIONAL_INCLUDE_DIRS += -I$(GNUSTEP_LOCAL_ROOT)/Library/Headers/MonetExtensions/

ADDITIONAL_GUI_LIBS += -lMonetExtensions

tube_TOOL_LIBS += -lgnustep-gui

-include GNUmakefile.preamble

-include GNUmakefile.local

include $(GNUSTEP_MAKEFILES)/tool.make
include $(GNUSTEP_MAKEFILES)/aggregate.make

-include GNUmakefile.postamble
#  REVISION INFORMATION  ######################################################
#
#  _Author: rao $
#  _Date: 2002/03/21 16:49:54 $
#  _Revision: 1.1 $
#  _Source: /cvsroot/gnuspeech/gnuspeech/trillium/src/softwareTRM/Makefile,v $
#  _State: Exp $
#
#
#  _Log: Makefile,v $
#  Revision 1.1  2002/03/21 16:49:54  rao
#  Initial import.
#
# Revision 1.3  1995/03/21  04:52:33  len
# Now compiles FAT.  Also adjusted mono and stereo output volume to match
# approximately the output volume of the DSP.
#
# Revision 1.2  1994/08/05  03:12:46  len
# Resectioned tube so that it more closely conforms the the DRM proportions.
# Also changed frication injection so now allowed from S3 to S10.
#
# Revision 1.1.1.1  1994/07/07  03:48:52  len
# Initial archived version.
#
#
##############################################################################


# program name
PROGRAM = tube


# compiler flags
# use -g -DDEBUG if debugging desired, comment out strip
CFLAGS = -g -Wall -falign-loops=16 -ffast-math
OPTIMIZATION_CFLAGS = -O4 -mdynamic-no-pic
ARCHS =


t1: t1.c
	cc $(CFLAGS) t1.c

#all:: tube tube2

#$(PROGRAM): $(PROGRAM).c
#	cc $(PROGRAM).c -o $@ $(ARCHS) $(CFLAGS) $(OPTIMIZATION_CFLAGS)
#	strip $@

tube: tube.c
	cc $(ARCHS) $(CFLAGS) $(OPTIMIZATION_CFLAGS) tube.c -o tube

tube2: tube2.c
	cc $(ARCHS) $(CFLAGS) -faltivec $(OPTIMIZATION_CFLAGS) tube2.c -o tube2

clean:: tube tube2
	/bin/rm -rf tube tube2

optcomp:: tube-O0 tube-O1 tube-O2 tube-O3 tube-O4 tube-Os

tube-O0: tube.c
	cc tube.c -o tube-O0 $(ARCHS) $(CFLAGS) -O0

tube-O1: tube.c
	cc tube.c -o tube-O1 $(ARCHS) $(CFLAGS) -O1

tube-O2: tube.c
	cc tube.c -o tube-O2 $(ARCHS) $(CFLAGS) -O2

tube-O3: tube.c
	cc tube.c -o tube-O3 $(ARCHS) $(CFLAGS) -O3

tube-O4: tube.c
	cc tube.c -o tube-O4 $(ARCHS) $(CFLAGS) -O4

tube-Os: tube.c
	cc tube.c -o tube-Os $(ARCHS) $(CFLAGS) -Os

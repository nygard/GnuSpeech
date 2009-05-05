/*
 *  streams.h
 *  GnuSpeechParser
 *
 *  Created by Dalmazio on 28/04/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#if 0
#import <stdio.h>
#import <sys/mman.h>

#define NX_READWRITE	O_CREAT|O_RDWR
#define NX_READONLY		O_RDONLY

#define NX_FROMSTART	SEEK_SET
#define NX_FROMCURRENT	SEEK_CUR

#define NX_FREEBUFFER	0

#define NX_SHARED_MEM_OBJ_NAME	"/tmp/gnuspeech_tmpfile"

typedef FILE NXStream;

extern NXStream * NXOpenFile(int fd, int mode);

extern NXStream * NXOpenMemory(const char * address, int size, int mode);
extern void NXCloseMemory(NXStream * stream, int option);
extern void NXGetMemoryBuffer(NXStream * stream, char ** streambuf, int * len, int * maxLen);

extern void NXPutc(NXStream * stream, char c);
extern int NXGetc(NXStream * stream);
extern void NXUngetc(NXStream * stream);

extern void NXVPrintf(NXStream * stream, const char * format, va_list args);
extern void NXPrintf(NXStream * stream, const char * format, ...);

extern void NXPrintFILEContents(NXStream * stream);

extern void NXSeek(NXStream * stream, long offset, int whence);
extern long NXTell(NXStream * stream);

extern void NXVLogError(const char * format, va_list args);
extern void NXLogError(const char * format, ...);
#endif
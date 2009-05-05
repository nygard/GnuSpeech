/*
 *  streams.c
 *  GnuSpeechParser
 *
 *  Created by Dalmazio on 28/04/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#if 0
#import "streams.h"
#import <unistd.h>

//#define MAX_LEN	16384
//
//struct region {        /* Defines "structure" of shared memory */
//    int len;
//    char buf[8192];
//};
//
//struct region *rptr;

NXStream * NXOpenFile(int fd, int mode)
{
	FILE * file;
	
	if (mode == NX_READWRITE)  // limited support
		file = fdopen(fd, "w+");
	else if (mode == NX_READONLY)
		file = fdopen(fd, "r");		
	else
		file = NULL;
	
	if (file == NULL)
		NSLog(@"fdopen() failed.");

	return file;
}

NXStream * NXOpenMemory(const char *address, int size, int mode)
{
	
	//fstat(SharedMemID, &fstats); // check to see if the memory has been allocated and initialised
	// In this case, the size is already set and the permissions are set to 0x777. Therefore no truncation is required - I just map the memory:
	//smptr = mmap( 0, size, PROT_READ, MAP_SHARED, SharedMemID, 0 );
	
	int fd;
	
	if (mode == NX_READWRITE)  // limited support
		//fd = shm_open(NX_SHARED_MEM_OBJ_NAME, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR);  // read/write for owner
		fd = open("/tmp/gnuspeech123", O_CREAT | O_RDWR | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP);
	else if (mode == NX_READONLY)
		//fd = shm_open(NX_SHARED_MEM_OBJ_NAME, O_RDONLY, S_IRUSR);  // read for owner
		fd = open("/dev/zero", O_RDONLY);
	else
		fd = -1;
	
	if (fd == -1) {
		//NSLog(@"shm_open() failed with error %d.", errno);
		NSLog(@"open() failed with error %d.", errno);		
		return NULL;
	}
	
//	if (ftruncate(fd, sizeof(8192)) == -1) {
//		NSLog(@"ftruncate() failed with error %d.", errno);
//		return NULL;		
//	}
	

	//int result = mmap(0, 8192, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

	
	return NXOpenFile(fd, mode);	
}

void NXCloseMemory(NXStream * stream, int option)
{
	fclose(stream);
	
//	if (shm_unlink(NX_SHARED_MEM_OBJ_NAME) == -1)
//		NSLog(@"shm_unlink() failed with error %d.", errno);
	
}

void NXGetMemoryBuffer(NXStream * stream, char ** streambuf, int * len, int * maxLen)
{
	//NXPutc(stream, '\000');
	//NXUngetc(stream);
	//memcpy(*streambuf, stream->_bf._base, stream->_bf._size);
	*streambuf = (char *)(stream->_bf._base + stream->_offset);
	*len = ftell(stream);
	*maxLen = stream->_bf._size;
}

void NXPutc(NXStream * stream, char c)
{
	fputc(c, stream);
	//fseek(stream, 0, SEEK_END);
}

int NXGetc(NXStream * stream)
{
	int c = fgetc(stream);
	//fseek(stream, 0, SEEK_CUR);
	return c;
}

void NXUngetc(NXStream * stream)
{
//	if (ftell(stream) > 0)
//		(stream->_p)--;
	//ungetc(last_char, stream);
	if (ftell(stream) > 0)
		fseek(stream, -1, SEEK_CUR);
}

void NXVPrintf(NXStream * stream, const char * format, va_list args)
{
	fprintf(stream, format, args);
}

void NXPrintf(NXStream * stream, const char * format, ...)
{
	va_list args;
	va_start(args, format);
	NXVPrintf(stream, format, args);
	va_end(args);
}

void NXSeek(NXStream * stream, long offset, int whence)
{
	if (fseek(stream, offset, whence) == -1)
		NSLog(@"NXSeek(): Cannot seek to offset.");
}

long NXTell(NXStream * stream)
{
	long pos = ftell(stream);
	if (pos == -1)
		NSLog(@"NXTell(): Cannot get current position.");		
	return pos;
}

void NXVLogError(const char * format, va_list args)
{
	NSLogv([NSString stringWithCString:format encoding:NSASCIIStringEncoding], args);	
	// fprintf(stream, format, args);
}

void NXLogError(const char * format, ...)
{
	va_list args;
	va_start(args, format);
	NXVLogError(format, args);
	va_end(args);
}

void NXPrintFILEContents(NXStream * stream)
{
	NSLog(@" ");
	NSLog(@"Contents of struct __sFILE:");
	NSLog(@"unsigned char *_p      = %d", stream->_p);
	NSLog(@"int           _r       = %d", stream->_r);
	NSLog(@"int           _w       = %d", stream->_w);
	NSLog(@"short         _flags   = %d", stream->_flags);
	NSLog(@"short         _file    = %d", stream->_file);
	NSLog(@"struct __sbuf _bf      = %d:%s", stream->_bf, stream->_bf._base);
	NSLog(@"int           _lbfsize = %d", stream->_lbfsize);
	
	NSLog(@"struct __sbuf _ub      = %d:%s", stream->_ub, stream->_ub._base);
	NSLog(@"int           _ur      = %d", stream->_ur);
	NSLog(@"int           _blksize = %d", stream->_blksize);
	NSLog(@"fpos_t        _offset  = %d", stream->_offset);
}
#endif
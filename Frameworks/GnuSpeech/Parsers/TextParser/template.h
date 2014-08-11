//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

#import <stdio.h>

/*  DEFINITIONS  */
#define SYMBOL_LENGTH_MAX       12
#define SAMPLE_SIZE_DEF         2

/*  DATA STRUCTURES  */
struct _phoneStruct {
	char symbol[SYMBOL_LENGTH_MAX+1];
	struct _phoneStruct *next;
};
typedef struct _phoneStruct phoneStruct;
typedef phoneStruct *phoneStructPtr;

struct _parameterStruct {
	char symbol[SYMBOL_LENGTH_MAX+1];
	float minimum;
	float maximum;
	float Default;
	struct _parameterStruct *next;
};
typedef struct _parameterStruct parameterStruct;
typedef parameterStruct *parameterStructPtr;

void initTemplate(void);
int sampleValue(void);
char *parameterSymbol(int number);
float parameterSymMinimum(char *parameter);
float parameterSymMaximum(char *parameter);
void readFromFileTemplate(FILE *fp1);
int legalPhone(char *phone);
int legalParameter(char *parameter);
#if DEBUG
void printTemplate(void);
#endif

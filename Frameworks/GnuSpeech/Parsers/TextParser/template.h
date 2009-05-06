/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: 
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *******************************************************************************
 *
 *  template.h
 *  GnuSpeech
 *
 *  Version: 0.8
 *
 ******************************************************************************/

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

extern void initTemplate(void);
extern int sampleValue(void);
extern char *parameterSymbol(int number);
extern float parameterSymMinimum(char *parameter);
extern float parameterSymMaximum(char *parameter);
extern void readFromFileTemplate(FILE *fp1);
extern int legalPhone(char *phone);
extern int legalParameter(char *parameter);
#if DEBUG
extern void printTemplate(void);
#endif

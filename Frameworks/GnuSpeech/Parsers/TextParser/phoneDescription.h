/*******************************************************************************
 *
 *  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock
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
 *  phoneDescription.h
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/

#import "template.h"
#import <stdio.h>


#define T_DURATION_FIXED         0
#define T_DURATION_PROP          1


/*  DATA STRUCTURES  */
struct _target {
	int is_default;
	float value;
	struct _target *next;
};
typedef struct _target target;
typedef target *targetPtr;

struct _category {
	char symbol[SYMBOL_LENGTH_MAX+1];
	struct _category *next;
};
typedef struct _category category;
typedef category *categoryPtr;

struct _phoneDescription {
	char symbol[SYMBOL_LENGTH_MAX+1];
	int duration;
	struct {
		int type;
		int fixed;
		float prop;
	} transition_duration;
	struct _phoneDescription *next;
	targetPtr targetHead;
	categoryPtr categoryHead;
	int number_of_categories;
};
typedef struct _phoneDescription phoneDescription;
typedef phoneDescription *phoneDescriptionPtr;


extern void initPhoneDescription(void);
extern int matchPhone(char *phone,char *category);
extern float getTarget(char *phone,char *parameter);
extern int getPhoneLength(char *phone);
extern int getTransitionType(char *phone);
extern int getTransitionDurationFixed(char *phone);
extern float getTransitionDurationProp(char *phone);
extern void readFromFilePhoneDescription(FILE *fp1);
#if DEBUG
extern void printPhoneDescription(void);
#endif

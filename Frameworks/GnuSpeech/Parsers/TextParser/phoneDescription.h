//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

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


void initPhoneDescription(void);
int matchPhone(char *phone,char *category);
float getTarget(char *phone,char *parameter);
int getPhoneLength(char *phone);
int getTransitionType(char *phone);
int getTransitionDurationFixed(char *phone);
float getTransitionDurationProp(char *phone);
void readFromFilePhoneDescription(FILE *fp1);
#if DEBUG
void printPhoneDescription(void);
#endif

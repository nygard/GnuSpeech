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
 *  phoneDescription.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/

#import "phoneDescription.h"
#import "template.h"
#import <stdlib.h>
#import <strings.h>

/*  GLOBAL VARIABLES, LOCAL TO THIS FILE  */
static int number_of_phones;
static int number_of_targets;
static phoneDescriptionPtr phoneDescriptionHead;



void initPhoneDescription(void)
{
    /*  INITIALIZE HEAD OF LIST, OTHER VARIABLES  */
    phoneDescriptionHead = NULL;
    number_of_phones = number_of_targets = 0;
}



int matchPhone(char *phone,char *category)
{
    phoneDescriptionPtr current_phone_ptr;
    categoryPtr current_category_ptr;
    int i;
	
    /*  GET PROPER POINTER TO PHONE DESCRIPTION  */
    current_phone_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		if (!strcmp(current_phone_ptr->symbol,phone))
			break;
		current_phone_ptr = current_phone_ptr->next;
    }
	
    /*  IF PHONE IS OF CATEGORY, THEN RETURN 1, ELSE RETURN 0  */
    current_category_ptr = current_phone_ptr->categoryHead;
    for (i = 0; i < current_phone_ptr->number_of_categories; i++) {
		if (!strcmp(current_category_ptr->symbol,category))
			return(1);
		current_category_ptr = current_category_ptr->next;
    }
    return(0);
}



float getTarget(char *phone,char *parameter)
{
    int i, j;
    phoneDescriptionPtr current_phoneDescription_ptr;
    targetPtr current_target_ptr;
	
    /*  SEARCH UNTIL PHONE MATCHES  */
    current_phoneDescription_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		if (!strcmp(current_phoneDescription_ptr->symbol,phone)) {
			/*  SEARCH UNTIL PARAMETER MATCHES  */
			current_target_ptr = current_phoneDescription_ptr->targetHead;
			for (j = 0; j < number_of_targets; j++) {
				if (!strcmp(parameterSymbol(j+1),parameter)) {
					return(current_target_ptr->value);
				}
				current_target_ptr = current_target_ptr->next;
			}
		}
		/*  UPDATE POINTER TO NEXT PHONE DESCRIPTION STRUCTURE  */
		current_phoneDescription_ptr = current_phoneDescription_ptr->next;
    }
	
    /*  IF WE GET HERE, THEN RETURN ERROR  */
    return(0.0);
}



int getPhoneLength(char *phone)
{
    int i;
    phoneDescriptionPtr current_phoneDescription_ptr;
	
    /*  SEARCH UNTIL PHONE MATCHES  */
    current_phoneDescription_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		if (!strcmp(current_phoneDescription_ptr->symbol,phone)) {
			return(current_phoneDescription_ptr->duration);
		}
		/*  UPDATE POINTER TO NEXT PHONE DESCRIPTION STRUCTURE  */
		current_phoneDescription_ptr = current_phoneDescription_ptr->next;
    }
	
    /*  IF WE GET HERE, THEN RETURN ERROR  */
    return(0);
}



int getTransitionType(char *phone)
{
    int i;
    phoneDescriptionPtr current_phoneDescription_ptr;
	
    /*  SEARCH UNTIL PHONE MATCHES  */
    current_phoneDescription_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		if (!strcmp(current_phoneDescription_ptr->symbol,phone)) {
			return(current_phoneDescription_ptr->transition_duration.type);
		}
		/*  UPDATE POINTER TO NEXT PHONE DESCRIPTION STRUCTURE  */
		current_phoneDescription_ptr = current_phoneDescription_ptr->next;
    }
	
    /*  IF WE GET HERE, THEN RETURN ERROR  */
    return(-1);
}



int getTransitionDurationFixed(char *phone)
{
    int i;
    phoneDescriptionPtr current_phoneDescription_ptr;
	
    /*  SEARCH UNTIL PHONE MATCHES  */
    current_phoneDescription_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		if (!strcmp(current_phoneDescription_ptr->symbol,phone)) {
			return(current_phoneDescription_ptr->transition_duration.fixed);
		}
		/*  UPDATE POINTER TO NEXT PHONE DESCRIPTION STRUCTURE  */
		current_phoneDescription_ptr = current_phoneDescription_ptr->next;
    }
	
    /*  IF WE GET HERE, THEN RETURN ERROR  */
    return(-1);
}



float getTransitionDurationProp(char *phone)
{
    int i;
    phoneDescriptionPtr current_phoneDescription_ptr;
	
    /*  SEARCH UNTIL PHONE MATCHES  */
    current_phoneDescription_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		if (!strcmp(current_phoneDescription_ptr->symbol,phone)) {
			return(current_phoneDescription_ptr->transition_duration.prop);
		}
		/*  UPDATE POINTER TO NEXT PHONE DESCRIPTION STRUCTURE  */
		current_phoneDescription_ptr = current_phoneDescription_ptr->next;
    }
	
    /*  IF WE GET HERE, THEN RETURN ERROR  */
    return(-1.0);
}



void readFromFilePhoneDescription(FILE *fp1)
{
    int i, j;
    phoneDescriptionPtr current_phoneDescription_ptr, temp_phoneDescription_ptr;
    phoneDescriptionPtr new_phoneDescription();
    targetPtr current_target_ptr = NULL, temp_target_ptr, new_target();
    categoryPtr current_category_ptr = NULL, temp_category_ptr, new_category();
	
	
    /*  FIRST FREE ALL CURRENT MEMORY, IF NEEDED  */
    current_phoneDescription_ptr = phoneDescriptionHead;
    for (i = 0; i < number_of_phones; i++) {
		/*  FREE ALL TARGETS  */
		current_target_ptr = current_phoneDescription_ptr->targetHead;
		for (j = 0; j < number_of_targets; j++) {
			temp_target_ptr = current_target_ptr->next;
			free(current_target_ptr);
			current_target_ptr = temp_target_ptr;
		}
		/*  FREE ALL CATEGORIES  */
		current_category_ptr = current_phoneDescription_ptr->categoryHead;
		for (j = 0; j < (current_phoneDescription_ptr->number_of_categories); j++) {
			temp_category_ptr = current_category_ptr->next;
			free(current_category_ptr);
			current_category_ptr = temp_category_ptr;
		}
		/*  FREE THE PHONE DESCRIPTION STRUCTURE ITSELF  */
		temp_phoneDescription_ptr = current_phoneDescription_ptr->next;
		free(current_phoneDescription_ptr);
		current_phoneDescription_ptr = temp_phoneDescription_ptr;
    }
	
	
    /*  READ # OF PHONES AND TARGETS FROM FILE  */
    fread((char *)&number_of_phones,sizeof(number_of_phones),1,fp1);
    fread((char *)&number_of_targets,sizeof(number_of_targets),1,fp1);
	
    /*  READ PHONE DESCRIPTION FROM FILE  */
    phoneDescriptionHead = NULL;
    for (i = 0; i < number_of_phones; i++) {
		/*  ALLOCATE NEW STRUCTURE  */
		if (i == 0) {
			phoneDescriptionHead = current_phoneDescription_ptr = new_phoneDescription();
		}
		else {
			current_phoneDescription_ptr->next = new_phoneDescription();
			current_phoneDescription_ptr = current_phoneDescription_ptr->next;	    
		}
		
		/*  READ SYMBOL AND DURATIONS FROM FILE  */
		fread((char *)&(current_phoneDescription_ptr->symbol),SYMBOL_LENGTH_MAX+1,1,fp1);
		fread((char *)&(current_phoneDescription_ptr->duration),sizeof(int),1,fp1);
		fread((char *)&(current_phoneDescription_ptr->transition_duration.type),
			  sizeof(int),1,fp1);
		fread((char *)&(current_phoneDescription_ptr->transition_duration.fixed),
			  sizeof(int),1,fp1);
		fread((char *)&(current_phoneDescription_ptr->transition_duration.prop),
			  sizeof(float),1,fp1);
		
		/*  READ TARGETS IN FROM FILE  */
		current_phoneDescription_ptr->targetHead = NULL;
		for (j = 0; j < number_of_targets; j++) {
			/*  ALLOCATE NEW STRUCTURE  */
			if (j == 0) {
				current_phoneDescription_ptr->targetHead = current_target_ptr = 
				new_target();
			}
			else {
				current_target_ptr->next = new_target();
				current_target_ptr = current_target_ptr->next;	    
			}
			/*  READ IN DATA FROM FILE  */
			fread((char *)&(current_target_ptr->is_default),sizeof(int),1,fp1);
			fread((char *)&(current_target_ptr->value),sizeof(float),1,fp1);
			/*  SET POINTER TO NEXT ITEM TO NULL  */
			current_target_ptr->next = NULL;
		}
		
		/*  READ IN CATEGORIES FROM FILE  */
		current_phoneDescription_ptr->categoryHead = NULL;
		fread((char *)&(current_phoneDescription_ptr->number_of_categories),sizeof(int),1,fp1);
		for (j = 0; j < (current_phoneDescription_ptr->number_of_categories); j++) {
			/*  ALLOCATE NEW STRUCTURE  */
			if (j == 0) {
				current_phoneDescription_ptr->categoryHead = current_category_ptr = 
				new_category();
			}
			else {
				current_category_ptr->next = new_category();
				current_category_ptr = current_category_ptr->next;	    
			}
			/*  READ IN DATA FROM FILE  */
			fread((char *)&(current_category_ptr->symbol),SYMBOL_LENGTH_MAX+1,1,fp1);
			/*  SET POINTER TO NEXT ITEM TO NULL  */
			current_category_ptr->next = NULL;
		}
		
		/*  SET POINTER TO NEXT ITEM TO NULL  */
		current_phoneDescription_ptr->next = NULL;
    }
}



#if DEBUG
void printPhoneDescription(void)
{
	int i, j;
	phoneDescriptionPtr current_phoneDescription_ptr = NULL;
	targetPtr current_target_ptr = NULL;
	categoryPtr current_category_ptr = NULL;
	
	printf("\nPhoneDescription Information\n");
	printf("    number_of_phones = %-d\n",number_of_phones);
	printf("    number_of_targets = %-d\n",number_of_targets);
	
	/*  PRINT OUT EACH PHONE  */
	current_phoneDescription_ptr = phoneDescriptionHead;
	for (i = 0; i < number_of_phones; i++) {
		printf("\n%s  %-d  %-d  %-d  %.2f\n",current_phoneDescription_ptr->symbol,
			   current_phoneDescription_ptr->duration,
			   current_phoneDescription_ptr->transition_duration.type,
			   current_phoneDescription_ptr->transition_duration.fixed,
			   current_phoneDescription_ptr->transition_duration.prop);
		/*  PRINT OUT TARGETS  */
		current_target_ptr = current_phoneDescription_ptr->targetHead;
		for (j = 0; j < number_of_targets; j++) {
			printf("    %-d  %.2f\n",current_target_ptr->is_default,
				   current_target_ptr->value);
			current_target_ptr = current_target_ptr->next;
		}
		/*  PRINT OUT CATEGORIES  */
		current_category_ptr = current_phoneDescription_ptr->categoryHead;
		for (j = 0; j < current_phoneDescription_ptr->number_of_categories; j++) {
			printf("  %s\n",current_category_ptr->symbol);
			current_category_ptr = current_category_ptr->next;
		}
		/*  UPDATE POINTER TO PARTICULAR PHONE  */
		current_phoneDescription_ptr = current_phoneDescription_ptr->next;
	}
}
#endif



targetPtr new_target()
{
	return ( (targetPtr) malloc(sizeof(target)) );
}

categoryPtr new_category()
{
	return ( (categoryPtr) malloc(sizeof(category)) );
}

phoneDescriptionPtr new_phoneDescription()
{
	return ( (phoneDescriptionPtr) malloc(sizeof(phoneDescription)) );
}

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
 *  template.c
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/

#import "template.h"
#import <strings.h>
#import <stdlib.h>

/*  GLOBAL VARIABLES, LOCAL TO THIS FILE  */
static int number_of_phones;
static phoneStructPtr phoneHead;

static int number_of_parameters;
static parameterStructPtr parameterHead;

static int sampleSize;



void initTemplate(void)
{
    /*  INITIALIZE POINTERS TO PHONE LIST  */
    number_of_phones = 0;
    phoneHead = NULL;

    /*  INITIALIZE POINTERS TO PARAMETER LIST  */
    number_of_parameters = 0;
    parameterHead = NULL;

    /*  SET DEFAULT SAMPLE SIZE  */
    sampleSize = SAMPLE_SIZE_DEF;
}



int sampleValue(void)
{
    return(sampleSize);
}



char *parameterSymbol(int number)
{
    parameterStructPtr current_ptr;
    int i;

    current_ptr = parameterHead;
    for (i = 1; i < ((number_of_parameters < number) ? number_of_parameters : number); i++)
        current_ptr = current_ptr->next;

    return (current_ptr->symbol);
}



float parameterSymMinimum(char *parameter)
{
    parameterStructPtr current_ptr;
    int i;

    current_ptr = parameterHead;
    for (i = 0; i < number_of_parameters; i++) {
	if (!strcmp(current_ptr->symbol,parameter))
	    return (current_ptr->minimum);
	current_ptr = current_ptr->next;
    }

    return (0.0);
}



float parameterSymMaximum(char *parameter)
{
    parameterStructPtr current_ptr;
    int i;

    current_ptr = parameterHead;
    for (i = 0; i < number_of_parameters; i++) {
	if (!strcmp(current_ptr->symbol,parameter))
	    return (current_ptr->maximum);
	current_ptr = current_ptr->next;
    }

    return (0.0);
}



void readFromFileTemplate(FILE *fp1)
{
    int i;

    phoneStructPtr current_phone_ptr, temp_phone_ptr, new_phoneStruct();
    parameterStructPtr current_parameter_ptr, temp_parameter_ptr, new_parameterStruct();

    /*  FIRST FREE ALL CURRENT MEMORY, IF NEEDED  */
    /*  PHONE MEMORY  */
    current_phone_ptr = phoneHead;
    for (i = 0; i < number_of_phones; i++) {
	temp_phone_ptr = current_phone_ptr->next;
	free(current_phone_ptr);
	current_phone_ptr = temp_phone_ptr;
    }
    /*  PARAMETER MEMORY  */
    current_parameter_ptr = parameterHead;
    for (i = 0; i < number_of_parameters; i++) {
	temp_parameter_ptr = current_parameter_ptr->next;
	free(current_parameter_ptr);
	current_parameter_ptr = temp_parameter_ptr;
    }

    /*  READ SAMPLE SIZE FROM FILE  */
    fread((char *)&sampleSize,sizeof(sampleSize),1,fp1);

    /*  READ PHONE SYMBOLS FROM FILE  */
    fread((char *)&number_of_phones,sizeof(number_of_phones),1,fp1);
    phoneHead = NULL;
    for (i = 0; i < number_of_phones; i++) {
	if (i == 0) {
	    phoneHead = current_phone_ptr = new_phoneStruct();
	}
	else {
	    current_phone_ptr->next = new_phoneStruct();
	    current_phone_ptr = current_phone_ptr->next;	    
	}
	fread((char *)&(current_phone_ptr->symbol),SYMBOL_LENGTH_MAX+1,1,fp1);
	current_phone_ptr->next = NULL;
    }

    /*  READ PARAMETERS FROM FILE  */
    fread((char *)&number_of_parameters,sizeof(number_of_parameters),1,fp1);
    parameterHead = NULL;
    for (i = 0; i < number_of_parameters; i++) {
	if (i == 0) {
	    parameterHead = current_parameter_ptr = new_parameterStruct();
	}
	else {
	    current_parameter_ptr->next = new_parameterStruct();
	    current_parameter_ptr = current_parameter_ptr->next;	    
	}
	fread((char *)&(current_parameter_ptr->symbol),SYMBOL_LENGTH_MAX+1,1,fp1);
	fread((char *)&(current_parameter_ptr->minimum),sizeof(float),1,fp1);
	fread((char *)&(current_parameter_ptr->maximum),sizeof(float),1,fp1);
	fread((char *)&(current_parameter_ptr->Default),sizeof(float),1,fp1);
	current_parameter_ptr->next = NULL;
    }
}



int legalPhone(char *phone)
{
  int i;
  phoneStructPtr current_phone_ptr;
  
  /*  RETURN 1, IF PHONE MATCHES TO ANY PHONE IN LIST  */
  current_phone_ptr = phoneHead;
  for (i = 0; i < number_of_phones; i++) {
    if (!strcmp(current_phone_ptr->symbol,phone))
	return(1);
    current_phone_ptr = current_phone_ptr->next;
  }

  /*  IF HERE, THEN NO MATCH;  RETURN 0  */
  return(0);
}



int legalParameter(char *parameter)
{
  int i;
  parameterStructPtr current_parameter_ptr;
  
  /*  RETURN 1, IF PARAMETER MATCHES TO ANY PARAMETER IN LIST  */
  current_parameter_ptr = parameterHead;
  for (i = 0; i < number_of_parameters; i++) {
    if (!strcmp(current_parameter_ptr->symbol,parameter))
	return(1);
    current_parameter_ptr = current_parameter_ptr->next;
  }

  /*  IF HERE, THEN NO MATCH;  RETURN 0  */
  return(0);
}



#if DEBUG
void printTemplate(void)
{
  int i;
  phoneStructPtr current_phone_ptr;
  parameterStructPtr current_parameter_ptr;

  printf("\nTemplate information:\n");

  printf(" SampleValue = %-d\n",sampleSize);

  printf(" number_of_phones = %-d\n",number_of_phones);
  current_phone_ptr = phoneHead;
  for (i = 0; i < number_of_phones; i++) {
    printf("  phone[%-d] = %s\n",i+1,current_phone_ptr->symbol);
    current_phone_ptr = current_phone_ptr->next;
  }

  printf(" number_of_parameters = %-d\n",number_of_parameters);
  current_parameter_ptr = parameterHead;
  for (i = 0; i < number_of_parameters; i++) {
    printf("  parameter[%-d] = %12s  %12f  %12f  %12f\n",
	   i+1,current_parameter_ptr->symbol,
	   current_parameter_ptr->minimum,current_parameter_ptr->maximum,
	   current_parameter_ptr->Default);
    current_parameter_ptr = current_parameter_ptr->next;
  }

}
#endif



phoneStructPtr new_phoneStruct(void)
{
return ( (phoneStructPtr) malloc(sizeof(phoneStruct)) );
}



parameterStructPtr new_parameterStruct(void)
{
return ( (parameterStructPtr) malloc(sizeof(parameterStruct)) );
}

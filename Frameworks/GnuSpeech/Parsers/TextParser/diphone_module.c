/*******************************************************************************
 *
 *  Copyright (c) 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
 *  
 *  Contributors: Dalmazio Brisinda
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
 *  diphone_module.c
 *  GnuSpeech
 *
 *  Version: 0.9
 *
 ******************************************************************************/


/*  INCLUDE FILES  ***********************************************************/
#import "diphone_module.h"
#import "template.h"
#import "categories.h"
#import "phoneDescription.h"
#import "rule.h"
#import <stdio.h>
#import <stdlib.h>
#import <strings.h>
#import <mach/vm_types.h>


/*  CONSTANTS  ***************************************************************/
#define MAGIC_NUMBER         0x2e646567
#define DIPHONE_BLOCK_SIZE   2044  
/*  CHOSEN SINCE DEGAS WILL CREATE DIPHONE SIZE OF 2024 BYTES MAX.  
 2044 RECOMMENDED BY MAN PAGE FOR EFFICIENCY, & AVOID VM FRAGMENTATION  */


/*  TYPE DEFINITIONS  ********************************************************/
struct _cacheItem {
    char phone1[SYMBOL_LENGTH_MAX+1];
    char phone2[SYMBOL_LENGTH_MAX+1];
    vm_address_t diphone_block;
    struct _cacheItem *next;
    struct _cacheItem *previous;
};
typedef struct _cacheItem cacheItem;
typedef cacheItem *cacheItemPtr;


/*  STATIC GLOBAL VARIABLES (LOCAL TO THIS FILE)  ****************************/
static filterParamPtr parameterList = NULL;
static cacheItemPtr cacheHead = NULL;
static cacheItemPtr cacheTail = NULL;
static int number_of_cache_items = 0;


/*  STATIC GLOBAL FUNCTIONS (LOCAL TO THIS FILE)  ****************************/
static int init_degas_data(char *degas_file_path);
static int init_parameter_list(char **parameters);
static int init_cache(char *cache_preload_file_path);
static filterParamPtr new_filterParam();
static cacheItemPtr new_cacheItem(void);
static void free_cacheItem(cacheItemPtr item_ptr);
#if DEBUG
static void printCache(void);
#endif



/******************************************************************************
 *
 *	function:	init_diphone_module
 *
 *	purpose:	Initializes diphone module with information contained
 *                       in the .degas file, the specified parameter list, and
 *                       in the diphone.preload file.  Once this function has
 *                       been called, any of the other functions in the file
 *                       can be called, in any order.  This function can also
 *                       be used to re-initialize the diphone module---it
 *                       cleans up the old data structures, and initializes
 *                       them with the new data.
 *
 *	internal
 *	functions:	init_degas_data, init_parameter_list, init_cache
 *                       printCache, initTemplate, initPhoneDescription,
 *                       initRule, printTemplate, printPhoneDescription,
 *                       printRule
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int init_diphone_module(char *degas_file_path,
						char **parameters,
						char *cache_preload_file_path)
{
	/*  INITIALIZE THE DEGAS DATABASE MODULES  */
	initTemplate();
	initPhoneDescription();
	initRule();
	
	/*  INITIALIZE DATABASE WITH DATA FROM DEGAS FILE  */
	if (init_degas_data(degas_file_path) != 0)
		return(-1);
	
	/*  INITIALIZE THE PARAMETER LIST  */
	if (init_parameter_list(parameters) != 0)
		return(-1);
	
	/*  INITIALIZE THE CACHE  */
	if (init_cache(cache_preload_file_path) != 0)
		return(-1);
	
#if DEBUG
	/*  PRINT OUT DEGAS INFO  */
	printTemplate();
	printPhoneDescription();
	printRule();
	printCache();
#endif
	
	/*  IF HERE, THEN NO ERROR, RETURN 0  */
	return(0);
}



/******************************************************************************
 *
 *	function:	init_degas_data
 *
 *	purpose:	Initializes diphone module with information contained
 *                       in the specified .degas file.  Cleans out old data
 *                       structures if necessary, and reads in new data.
 *
 *	internal
 *	functions:	readFromFileTemplate, readFromFileCategories,
 *                       readFromPhoneDescription, readFromFileRule,
 *
 *	library
 *	functions:	fopen, fclose, fread
 *
 ******************************************************************************/

int init_degas_data(char *degas_file_path)
{
	FILE *fp1;
	int magic;
	
	/*  TRY TO OPEN SPECIFIED FILE, RETURN ERROR CODE IF NEEDED  */
	if ((fp1 = fopen(degas_file_path,"r")) == NULL)
		return(-1);
	
	/*  CHECK FOR PROPER MAGIC NUMBER, RETURN ERROR CODE IF NOT RIGHT  */
	fread(&magic,sizeof(magic),1,fp1);  
	if (magic != MAGIC_NUMBER)
		return(-1);
	
	/*  READ IN THE SPECIFIED DEGAS FILE  */
	readFromFileTemplate(fp1);
	readFromFileCategories(fp1);
	readFromFilePhoneDescription(fp1);
	readFromFileRule(fp1);
	
	/*  CLOSE THE DEGAS FILE  */
	fclose(fp1);
	
	/*  IF HERE, RETURN WITH NO ERROR  */
	return(0);
}



/******************************************************************************
 *
 *	function:	init_parameter_list
 *
 *	purpose:	Initializes the parameter list from list supplied from
 *                       routine which called init_diphone_module.  Also checks
 *                       validity of parameter names.
 *
 *	internal
 *	functions:	legalParameter, new_filterParam
 *
 *	library
 *	functions:	free, strcpy
 *
 ******************************************************************************/

int init_parameter_list(char **parameters)
{
	filterParamPtr current_parameter = NULL, temp_parameter = NULL;
	int i;
	
	/*  IF NOTHING IN LIST, RETURN ERROR  */
	if (parameters[0] == NULL)
		return(-1);
	
	/*  RETURN ERROR CODE IF SPECIFIED PARAMETERS NOT ALL LEGAL  */
	i = 0;
	while (parameters[i] != NULL) {
		if (!legalParameter(parameters[i++]))
			return(-1);
	}
	
	/*  DELETE OLD PARAMETER LIST, IF NECESSARY  */
	if (parameterList != NULL) {
		current_parameter = parameterList;
		while (current_parameter != NULL) {
			temp_parameter = current_parameter;
			current_parameter = current_parameter->next;
			free(temp_parameter);
		}
		parameterList = NULL;
	}
	
	/*  CREATE THE PARAMETER LIST  */
	i = 0;
	while (parameters[i] != NULL) {
		if (i == 0) {
			current_parameter = parameterList = new_filterParam();
		}
		else {
			current_parameter->next = new_filterParam();
			current_parameter = current_parameter->next;
		}
		current_parameter->next = NULL;
		strcpy(current_parameter->symbol,parameters[i++]);
	}
	
	/*  IF HERE, RETURN WITH NO ERROR  */
	return(0);
}



/******************************************************************************
 *
 *	function:	init_cache
 *
 *	purpose:	Initializes the cache, and preloads it with the
 *                       diphones specified in the preload file.  If the
 *                       argument is NULL, then no preloading takes place.
 *
 *	internal
 *	functions:	new_cacheItem, free_cacheItem, validPhone, 
 *                       writeDiphone, governingRule
 *
 *	library
 *	functions:	fclose, fopen, fgets, index, strncat
 *
 ******************************************************************************/

int init_cache(char *cache_preload_file_path)
{
	int i;
	FILE *fp1;
	char buffer[(SYMBOL_LENGTH_MAX+1)*2];
	char phone1[SYMBOL_LENGTH_MAX+1], phone2[SYMBOL_LENGTH_MAX+1];
	cacheItemPtr current_cache_ptr = NULL;
	
	/*  FREE PREVIOUS CACHE, IF NECESSARY;  INITIALIZE CACHE VARIABLES  */
	if (number_of_cache_items > 0) {
		void free_cacheItem(cacheItemPtr item_ptr);
		cacheItemPtr current_cache_ptr = cacheHead;
		cacheItemPtr temp_cache_ptr;
		for (i = 0; i < number_of_cache_items; i++) {
			temp_cache_ptr = current_cache_ptr;
			current_cache_ptr = current_cache_ptr->next;
			free_cacheItem(temp_cache_ptr);
		}
	}
	cacheHead = cacheTail = NULL;
	number_of_cache_items = 0;
	
	/*  IF NO CACHE PRELOAD FILE, THEN RETURN WITHOUT PRELOADING  */
	if (cache_preload_file_path == NULL)
		return(0);
	
	/*  TRY TO OPEN CACHE PRELOAD FILE, RETURN ERROR CODE IF NEEDED  */
	if ((fp1 = fopen(cache_preload_file_path,"r")) == NULL)
		return(-1);
	
	/*  READ IN DIPHONES, ONE LINE AT A TIME, PRELOAD CACHE  */
	while ((fgets(buffer,((SYMBOL_LENGTH_MAX+1)*2),fp1) != NULL) && 
		   (number_of_cache_items < CACHE_SIZE)) {
		int space_pos = index(buffer,' ') - buffer;
		int newline_pos = index(buffer,'\n') - buffer;
		/*  DECODE PHONE1  */
		phone1[0] = '\0';
		strncat(phone1,buffer,space_pos);
		/*  DECODE PHONE2  */
		phone2[0] = '\0';
		strncat(phone2,&buffer[space_pos+1],(newline_pos-space_pos-1));
		/*  CHECK VALIDITY OF DIPHONE  */
		if ( (!validPhone(phone1)) || (!validPhone(phone2)) ) {
			fclose(fp1);
			return(-1);
		}
		/*  ADD DIPHONE TO TAIL OF LIST  */
		if (number_of_cache_items == 0) {
			current_cache_ptr = cacheHead = cacheTail = new_cacheItem();
			current_cache_ptr->previous = NULL;
		}
		else {
			current_cache_ptr->next = new_cacheItem();
			current_cache_ptr->next->previous = current_cache_ptr;
			current_cache_ptr = current_cache_ptr->next;
			cacheTail = current_cache_ptr;
		}
		strcpy(current_cache_ptr->phone1,phone1);
		strcpy(current_cache_ptr->phone2,phone2);
		current_cache_ptr->next = NULL;
		number_of_cache_items++;
		/*  CALCULATE THE DIPHONE  */
		writeDiphone(phone1,phone2,governingRule(phone1,phone2),
					 parameterList,NULL,current_cache_ptr->diphone_block);
	}
	
	/*  CLOSE THE DIPHONE PRELOAD FILE  */
	fclose(fp1);
	
	/*  IF HERE, RETURN WITH NO ERROR  */
	return(0);
}



/******************************************************************************
 *
 *	function:	paged_diphone
 *
 *	purpose:	Returns the requested diphone on a block of memory.
 *                       First the cache is searched.  If found in the cache,
 *                       the diphone is brought to the head of the cache, and
 *                       the diphone block is returned.  If the diphone is not
 *                       found in the cache, then the diphone is calculated,
 *                       and brought to the head of the cache.  If the cache
 *                       is already full, then the last item in the cache is
 *                       freed.
 *
 *	internal
 *	functions:	new_cacheItem, free_cacheItem, writeDiphone,
 *                       governingRule
 *
 *	library
 *	functions:	strcmp, strcpy
 *
 ******************************************************************************/

vm_address_t paged_diphone(char *phone1, char *phone2)
{
	cacheItemPtr current_cache_ptr;
	int i;
	
	/*  SEARCH CACHE FOR DIPHONE  */
	current_cache_ptr = cacheHead;
	for (i = 0; i < number_of_cache_items; i++) {
		/*  IF BOTH SYMBOLS MATCH, THEN WE HAVE FOUND THE DIPHONE  */
		if ((!strcmp(current_cache_ptr->phone1,phone1)) && 
			(!strcmp(current_cache_ptr->phone2,phone2)) ) {
			/*  IF AT HEAD OF LIST, SIMPLY RETURN PAGE POINTER  */
			if (i == 0)
				return(current_cache_ptr->diphone_block);
			else {
				/*  TAKE OUT OF LIST  */
				current_cache_ptr->previous->next = current_cache_ptr->next;
				if (current_cache_ptr->next != NULL)
					current_cache_ptr->next->previous = current_cache_ptr->previous;
				else {
					cacheTail = current_cache_ptr->previous;
				}
				/*  PUT IN AT HEAD OF LIST  */
				current_cache_ptr->next = cacheHead;
				cacheHead = current_cache_ptr;
				current_cache_ptr->previous = NULL;
				current_cache_ptr->next->previous = current_cache_ptr;
				/*  RETURN POINTER TO DIPHONE PAGE  */
				return(current_cache_ptr->diphone_block);
			}
		}
		/*  UPDATE CURRENT POINTER TO NEXT ITEM  */
		current_cache_ptr = current_cache_ptr->next;
	}
	
	/*  IF HERE, THEN ITEM WAS NOT FOUND IN THE CACHE  */
	/*  SIMPLY ADD NEW DIPHONE TO TOP OF CACHE, IF CACHE NOT FULL  */
	/*  ELSE, REMOVE ITEM FROM BOTTOM, THEN ADD NEW DIPHONE TO TOP OF CACHE  */
	if (number_of_cache_items < CACHE_SIZE) {
		/*  INCREMENT CACHE COUNTER  */
		number_of_cache_items++;
	}
	else {
		/*  REMOVE LAST ITEM FROM LIST  */
		current_cache_ptr = cacheTail;
		current_cache_ptr->previous->next = NULL;
		cacheTail = current_cache_ptr->previous;
		free_cacheItem(current_cache_ptr);
	}
	
	/*  ALLOCATE A NEW CACHE ITEM  */
	current_cache_ptr = new_cacheItem();
	
	/*  ADD IT TO THE TOP OF THE CACHE  */
	current_cache_ptr->next = cacheHead;
	cacheHead = current_cache_ptr;
	current_cache_ptr->previous = NULL;
	if (current_cache_ptr->next == NULL)
		cacheTail = current_cache_ptr;
	else
		current_cache_ptr->next->previous = current_cache_ptr;
	
	/*  SET THE DIPHONE NAME  */
	strcpy(current_cache_ptr->phone1,phone1);
	strcpy(current_cache_ptr->phone2,phone2);
	
	/*  CALCULATE DIPHONE, PUT ON DIPHONE PAGE  */
	writeDiphone(phone1,phone2,governingRule(phone1,phone2),
				 parameterList,NULL,current_cache_ptr->diphone_block);
	
	/*  RETURN POINTER TO DIPHONE PAGE  */
	return(current_cache_ptr->diphone_block);
}



/******************************************************************************
 *
 *	function:	diphone_duration
 *
 *	purpose:	Returns the duration, in samples, of the specified
 *                       diphone.
 *
 *	internal
 *	functions:	paged_diphone
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int diphone_duration(char *phone1, char *phone2)
{
	/*  DIPHONE HEADER STRUCTURE  */
	struct _diphone_header {
		int number_of_intervals;
		int total_duration;
	};
	typedef struct _diphone_header diphoneHeaderStruct;
	typedef diphoneHeaderStruct *diphoneHeaderPtr;
	
	/*  LOCAL VARIABLES  */
	diphoneHeaderPtr diphone_header;
	
	/*  DECODE THE DURATION  */
	diphone_header = (diphoneHeaderPtr)paged_diphone(phone1,phone2);
	
	/*  RETURN THE DURATION (IN SAMPLES) OF THE DIPHONE  */
	return(diphone_header->total_duration);
}



/******************************************************************************
 *
 *	function:	phoneInCategory
 *
 *	purpose:	Returns a 1 if the specified phone is in the
 *                       specified category, 0 otherwise.
 *
 *	internal
 *	functions:	matchPhone
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int phoneInCategory(char *phone, char *category)
{
	/*  SEE IF PHONE IS IN CATEGORY  */
	return(matchPhone(phone,category));
}



/******************************************************************************
 *
 *	function:	targetValue
 *
 *	purpose:	Returns the target value for the specified parameter,
 *                       for the specified phone.  If either the parameter or
 *                       phone don't exist, then 0.0 is returned.
 *
 *	internal
 *	functions:	getTarget
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

float targetValue(char *phone, char *parameter)
{
	return(getTarget(phone,parameter));
}



/******************************************************************************
 *
 *	function:	validPhone
 *
 *	purpose:	Returns a 1 if the phone is valid (exists in the
 *                       currently initialized database), 0 otherwise.
 *
 *	internal
 *	functions:	legalPhone
 *
 *	library
 *	functions:	none
 *
 ******************************************************************************/

int validPhone(char *phone)
{
	return(legalPhone(phone));
}



/******************************************************************************
 *
 *	functions:	new_filterParam, new_cacheItem, free_cacheItem
 *                       printCache
 *
 *	purpose:	Utility routines.
 *
 *	internal
 *	functions:	none
 *
 *	library
 *	functions:	malloc, free, printf
 *
 ******************************************************************************/

filterParamPtr new_filterParam()
{
	return ( (filterParamPtr) malloc(sizeof(filterParam)) );
}



cacheItemPtr new_cacheItem(void)
{
	cacheItemPtr temp_ptr;
	
	/*  ALLOCATE ITEM STRUCTURE  */
	temp_ptr = ( (cacheItemPtr) malloc(sizeof(cacheItem)) );
	/*  ALLOCATE A DIPHONE BLOCK  */
	temp_ptr->diphone_block = ( (vm_address_t) malloc(DIPHONE_BLOCK_SIZE) );
	/*  RETURN POINTER TO CACHE ITEM  */
	return(temp_ptr);
}



void free_cacheItem(cacheItemPtr item_ptr)
{
	/*  DEALLOCATE THE DIPHONE BLOCK  */
	free((void *)(item_ptr->diphone_block));
	/*  FREE THE STRUCTURE ITSELF  */
	free(item_ptr);
}



#if DEBUG
void printCache(void)
{
	cacheItemPtr current_cache_ptr;
	int i;
	
	printf("\nnumber_of_cache_items = %-d\n",number_of_cache_items);
	printf(" Forward List:\n");
	current_cache_ptr = cacheHead;
	for (i = 0; i < number_of_cache_items; i++) {
		printf("  item[%-d] = %s/%s  0x%X\n",i+1,current_cache_ptr->phone1,
			   current_cache_ptr->phone1,current_cache_ptr->diphone_block);
		current_cache_ptr = current_cache_ptr->next;
	}
	printf(" Backward List:\n");
	current_cache_ptr = cacheTail;
	for (i = 0; i < number_of_cache_items; i++) {
		printf("  item[%-d] = %s/%s  0x%X\n",i+1,current_cache_ptr->phone1,
			   current_cache_ptr->phone1,current_cache_ptr->diphone_block);
		current_cache_ptr = current_cache_ptr->previous;
	}
}
#endif

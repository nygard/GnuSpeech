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
 *  diphone_module.h
 *  GnuSpeech
 *
 *  Version: 0.8
 *
 ******************************************************************************/


/*  HEADER FILES TO IMPORT  */
#import <mach/vm_types.h>     /*  NEEDED FOR DECLARATION BELOW  */

/*  DEFINES  */
#define CACHE_SIZE      400    /* CAN BE CHANGED HERE  */

/*  FUNCTION PROTOTYPES  */
extern int init_diphone_module(char *degas_file_path,
							   char **parameters,
							   char *cache_preload_file_path);
extern vm_address_t paged_diphone(char *phone1, char *phone2);
extern int diphone_duration(char *phone1, char *phone2);
extern int phoneInCategory(char *phone, char *category);
extern float targetValue(char *phone, char *parameter);
extern int validPhone(char *phone);

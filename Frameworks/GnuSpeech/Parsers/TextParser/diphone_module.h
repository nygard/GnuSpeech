//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  HEADER FILES TO IMPORT  */
#import <mach/vm_types.h>     /*  NEEDED FOR DECLARATION BELOW  */

/*  DEFINES  */
#define CACHE_SIZE      400    /* CAN BE CHANGED HERE  */

/*  FUNCTION PROTOTYPES  */
int init_diphone_module(char *degas_file_path,
                        char **parameters,
                        char *cache_preload_file_path);
vm_address_t paged_diphone(char *phone1, char *phone2);
int diphone_duration(char *phone1, char *phone2);
int phoneInCategory(char *phone, char *category);
float targetValue(char *phone, char *parameter);
int validPhone(char *phone);

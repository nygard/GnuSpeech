//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/*  FUNCTION PROTOTYPES  */
int init_diphone_module(char *degas_file_path,
                        char **parameters,
                        char *cache_preload_file_path);
int validPhone(char *phone);

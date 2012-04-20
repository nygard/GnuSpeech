//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules. 
//  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

extern void setDriftGenerator(float deviation, float sampleRate, float lowpassCutoff);
extern float drift(void);

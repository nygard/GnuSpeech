//  This file is part of Gnuspeech, an extensible, text-to-speech package, based on real-time, articulatory, speech-synthesis-by-rules.
//  Copyright 1991-2012 David R. Hill, Leonard Manzara, Craig Schock

/// Generate a pronunciation for a word using letter to sound rules.  The type of word
/// is indicated after the pronunciation, separated by a percent.
///
/// The possible types are: a, ab, ac, b, bc, c, ca, cb, d, j
///
/// The meaning of these types is not documented.
///
/// @return Pronunciation of word, or NULL if any error (rare).
char *letter_to_sound(char *word);

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
 *  tail.h
 *  GnuSpeech
 *
 *  Version: 0.8
 *
 ******************************************************************************/


/*  DATA TYPES  **************************************************************/
typedef struct {
    char               *tail;
    char               *type;
} tail_entry;


/*  GLOBAL VARIABLES (LOCAL TO THIS FILE)  ***********************************/
static tail_entry tail_list[] = {
{"ly", "d"},
{"er", "ca"},
{"ish", "c"},
{"ing", "cb"},
{"se", "b"},
{"ic", "c"},
{"ify", "b"},
{"ment", "a"},
{"al", "c"},
{"ed", "bc"},
{"es", "ab"},
{"ant", "ca"},
{"ent", "ca"},
{"ist", "a"},
{"ism", "a"},
{"gy", "a"},
{"ness", "a"},
{"ous", "c"},
{"less", "c"},
{"ful", "c"},
{"ion", "a"},
{"able", "c"},
{"en", "c"},
{"ry", "ac"},
{"ey", "c"},
{"or", "a"},
{"y", "c"},
{"us", "a"},
{"s", "ab"},
{0, 0}
};

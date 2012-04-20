/*******************************************************************************
 *
 *  Copyright (c) 1991-2012 David R. Hill, Leonard Manzara, Craig Schock
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
 *  abbreviations.h
 *  GnuSpeech
 *
 *  Version: 0.9.1
 *
 ******************************************************************************/


/*  THIS FILE CONTAINS ABBREVIATIONS RECOGNIZED BY THE PARSER.  ALL ABBREVIATIONS
 MUST BE 2, 3, OR 4 CHARACTERS LONG.  MAKE SURE EACH LIST ENDS WITH NULL ENTRIES.  */

/*  THESE ABBREVIATIONS ARE EXPANDED UNCONDITIONALLY  */
static char *abbreviation[][2] =  { 
	{"Mr",  "mister"},
	{"Mrs", "missus"},
	{"Ms",  "miz"},
	{"Dr",  "doctor"},
	{"Jr",  "junior"},
	{"Prof","professor"},
	{"Rev", "reverend"},
	{"Esq", "esquire"},
	{"Ph",  "PH"},

	{"etc", "etcetera"},
	{"misc","miscellaneous"},
	{"pl",  "plural"},
	{"Vol", "volume"},
	{"pp",  "pages"},
	{"vs",  "versus"},
	{"Nos", "numbers"},
	{"Op",  "opus"},
	{"ca",  "circa"},
	{"viz", "viz"},

	{"Co",  "company"},
	{"Inc", "incorporated"},
	{"Ltd", "limited"},
	{"Govt","government"},
	{"Agcy","agency"},

	{"St",  "street"},
	{"Ave", "avenue"},
	{"dr",  "drive"},
	{"Blvd","boulevard"},
	{"Dept","department"},
	{"Bldg","building"},
	{"Apt", "apartment"},
	{"Pkwy","parkway"},
	{"Hwy", "highway"},

	{"doz", "dozen"},
	{"pkg", "package"},
	{"shpt","shipment"},
	{"mdse","merchandise"},

	{"wt",  "weight"},
	{"lb",  "pound"},
	{"lbs", "pounds"},
	{"oz",  "ounce"},
	{"ozs", "ounces"},
	{"kg",  "kilograms"},
	{"gm",  "grams"},

	{"ht",  "height"},
	{"mi",  "miles"},
	{"yd",  "yard"},
	{"yds", "yards"},
	{"ft",  "feet"},
	{"km",  "kilometers"},
	{"cm",  "centimeters"},
	{"mm",  "millimeters"},

	{"vol", "volume"},
	{"tbs", "tablespoons"},
	{"tbsp","tablespoons"},
	{"tsp", "teaspoons"},
	{"qt",  "quart"},
	{"qts", "quarts"},
	{"pt",  "pint"},
	{"pts", "pints"},

	{"hr",  "hour"},
	{"hrs", "hours"},
	{"mo",  "month"},
	{"mos", "months"},
	{"yr",  "year"},
	{"yrs", "years"},

	{"Jan", "january"},
	{"Feb", "february"},
	{"Mar", "march"},
	{"Apr", "april"},
	{"Jun", "june"},
	{"Jul", "july"},
	{"Aug", "august"},
	{"Sept","september"},
	{"Sep", "september"},
	{"Oct", "october"},
	{"Nov", "november"},
	{"Dec", "december"},

	{"Mon", "monday"},
	{"Tue", "tuesday"},
	{"Tues","tuesday"},
	{"Wed", "wednesday"},
	{"Thu", "thursday"},
	{"Thur","thursday"},
	{"Fri", "friday"},
	{"Sat", "saturday"},
	{"Sun", "sunday"},
	{"Sund","sunday"},

	{"Mt",  "mount"},
	{NULL,  NULL} 
};


/*  THESE ABBREVIATIONS ARE EXPANDED ONLY IF FOLLOWED BY A NUMBER  */
static char *abbr_with_number[][2] =  { 
	{"Fig",  "figure"},
	{"Figs", "figures"},
	{"No",   "number"},
	{NULL,  NULL} 
};

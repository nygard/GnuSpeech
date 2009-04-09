////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Eric Zoerner, Dalmazio Brisinda
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
////////////////////////////////////////////////////////////////////////////////
//
//  ResponderNotifyingWindow.m
//  PrEditor
//
//  Created by Eric Zoerner on 03/06/2006.
//
//  Version: 0.1
//
////////////////////////////////////////////////////////////////////////////////

#import "ResponderNotifyingWindow.h"


@implementation ResponderNotifyingWindow

- (BOOL)makeFirstResponder:(NSResponder *)aResponder
{
  BOOL response = [super makeFirstResponder:aResponder];
  if (response) {
	// Commented out on October 13, 2008 -- dalmazio.
    //[[self delegate] window:self madeFirstResponder:aResponder];    
  }
  return response;
}

@end

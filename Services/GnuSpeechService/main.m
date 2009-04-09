////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Dalmazio Brisinda
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
//  main.m
//  GnuSpeechService
//
//  Created by Dalmazio on 03/01/09.
//
//  Version: 0.5
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "GnuSpeechService.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	GnuSpeechService * gnuSpeechService = [[GnuSpeechService alloc] init];
	NSRegisterServicesProvider(gnuSpeechService, @"GnuSpeechService");
	[[NSRunLoop currentRunLoop] run];
	[gnuSpeechService release];
	
    [pool drain];
    return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard, Dalmazio Brisinda
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
//  PreMo
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9
//
////////////////////////////////////////////////////////////////////////////////

#ifdef GNUSTEP
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

int main(int argc, const char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}

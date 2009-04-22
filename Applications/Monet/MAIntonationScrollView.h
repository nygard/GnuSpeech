////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 1991-2009 David R. Hill, Leonard Manzara, Craig Schock
//  
//  Contributors: Steve Nygard
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
//  MAIntonationScrollView.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.5
//
////////////////////////////////////////////////////////////////////////////////

#import <AppKit/NSScrollView.h>
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet

/*===========================================================================

	Author: Craig-Richard Taube-Schock
	Date: Nov. 1, 1993

===========================================================================*/

@class MAIntonationScaleView;

@interface MAIntonationScrollView : NSScrollView
{
    IBOutlet MAIntonationScaleView *scaleView;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (void)awakeFromNib;
- (void)addScaleView;

- (void)tile;

- (NSView *)scaleView;

- (NSSize)printableSize;

@end

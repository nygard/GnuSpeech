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
//  MAIntonationScaleView.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.4
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface MAIntonationScaleView : NSView
{
    NSTextFieldCell *labelTextFieldCell;

    NSTextStorage *textStorage;
    NSLayoutManager *layoutManager;
    NSTextContainer *textContainer;
    NSFont *labelFont;
    NSFont *axisLabelFont;

    int sectionCount;
    int sectionHeight;
    int zeroSection;
    int yOrigin;
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)dealloc;

- (int)sectionCount;
- (void)setSectionCount:(int)newSectionCount;

- (int)sectionHeight;
- (void)setSectionHeight:(int)newSectionHeight;

- (int)zeroSection;
- (void)setZeroSection:(int)newZeroSection;

- (int)yOrigin;
- (void)setYOrigin:(int)newYOrigin;

- (void)drawRect:(NSRect)rect;

@end

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
//  MRuleTester.h
//  Monet
//
//  Created by Steve Nygard in 2004.
//
//  Version: 0.9.6
//
////////////////////////////////////////////////////////////////////////////////

#import "MWindowController.h"
#import <AppKit/NSNibDeclarations.h> // For IBAction, IBOutlet
#import <AppKit/NSForm.h>
#import <AppKit/NSTextField.h>

@class MModel;

@interface MRuleTester : MWindowController
{
    IBOutlet NSForm *posture1Form;
    IBOutlet NSForm *posture2Form;
    IBOutlet NSForm *posture3Form;
    IBOutlet NSForm *posture4Form;

    IBOutlet NSTextField *ruleOutputTextField;
    IBOutlet NSTextField *consumedTokensTextField;
    IBOutlet NSForm *durationOutputForm;

    MModel *model;
}

- (id)initWithModel:(MModel *)aModel;
- (void)dealloc;

- (MModel *)model;
- (void)setModel:(MModel *)newModel;

- (NSUndoManager *)undoManager;

- (void)windowDidLoad;
- (void)clearOutput;

// Actions
- (IBAction)parseRule:(id)sender;
- (IBAction)shiftPosturesLeft:(id)sender;

@end

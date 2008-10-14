//
//  ResponderNotifyingWindow.m
//  PrEditor
//
//  Created by Eric Zoerner on 03/06/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

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

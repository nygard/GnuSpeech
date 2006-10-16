//
//  ResponderNotifyingWindow.h
//  PrEditor
//
//  Created by Eric Zoerner on 03/06/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

/* A window that notifies its delegate when the firstResponder changes
*/
#import <Cocoa/Cocoa.h>


@interface ResponderNotifyingWindow : NSWindow {

}

- (BOOL)makeFirstResponder:(NSResponder *)aResponder;

@end

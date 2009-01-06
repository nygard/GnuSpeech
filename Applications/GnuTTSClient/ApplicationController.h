//
//  ApplicationController.h
//  TTSClient
//
//  Created by Dalmazio on 02/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ApplicationController : NSObject {
	IBOutlet NSTextView * textView;
	id ttsServerProxy;
}

- (id) init;
- (void) speak:(id)sender;
- (void) dealloc;

@end

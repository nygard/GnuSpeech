//
//  MTextToPhone.h
//  Monet
//
//  Created by Dalmazio on 05/01/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSPronunciationDictionary;

@interface MTextToPhone : NSObject {
    GSPronunciationDictionary * pronunciationDictionary;
}

- (id) init;
- (void) dealloc;

- (void) _createDBMFileIfNecessary;

- (NSString *) phoneForText:(NSString *)text;

- (void) loadMainDictionary;

@end

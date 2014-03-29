//
//  NSMutableString+AddText.h
//  MyLocations
//
//  Created by Derek Bassett on 3/29/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (AddText)

- (void)addText:(NSString *)text withSeparator:(NSString *)separator;

@end

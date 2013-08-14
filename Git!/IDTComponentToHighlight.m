//
//  IDTComponentToHighlight.m
//  Git!
//
//  Created by E&Z Pierson on 8/5/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTComponentToHighlight.h"

@implementation IDTComponentToHighlight
-(instancetype)initWithRange:(NSRange)range attributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) return nil;
    self.range = range;
    self.attributes = attributes;
    
    
    return self;
}

@end

//
//  IDTComponentToHighlight.h
//  Git!
//
//  Created by E&Z Pierson on 8/5/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDTComponentToHighlight : NSObject
@property (nonatomic) NSRange range;
@property (nonatomic,strong) NSDictionary *attributes;

-(instancetype)initWithRange:(NSRange)range attributes:(NSDictionary *)attributes;
@end

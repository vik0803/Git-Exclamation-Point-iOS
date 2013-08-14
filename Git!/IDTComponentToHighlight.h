//
//  IDTComponentToHighlight.h
//  Git!
//
//  Created by E&Z Pierson on 8/5/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
//This Object may gain more worth if I can add meaning to the highlight.
@interface IDTComponentToHighlight : NSObject
@property (nonatomic) NSRange range;
@property (nonatomic,strong) NSDictionary *attributes;

-(instancetype)initWithRange:(NSRange)range attributes:(NSDictionary *)attributes;
@end

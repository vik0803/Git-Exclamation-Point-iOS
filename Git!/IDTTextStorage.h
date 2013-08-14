//
//  IDTTextStorage.h
//  RTF7
//
//  Created by E&Z Pierson on 6/17/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const IDTDefaultTokenName;

@interface IDTTextStorage : NSTextStorage

//@documentation Highlight words.
@property (nonatomic,strong) NSDictionary *tokens;
//@documentation Highlight Characters

//@documentation Tokens are made up of a dictionary inside of a dictionary. E.G: @{@"Word":@{NSForegroundColorAttribute : [UIColor redColor]};
-(instancetype)init;
@end

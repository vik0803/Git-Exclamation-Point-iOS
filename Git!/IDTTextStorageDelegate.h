//
//  IDTTextStorage.h
//  RTF7
//
//  Created by E&Z Pierson on 6/17/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const IDTDefaultTokenName;

@interface IDTTextStorageDelegate : NSObject <NSTextStorageDelegate>

-(instancetype)init;

//- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta;
@end

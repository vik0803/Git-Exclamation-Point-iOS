//
//  IDTDocument.h
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface IDTDocument : UIDocument

- (instancetype)initWithFileURL:(NSURL *)url;

#pragma mark Properties
@property (strong,nonatomic) NSString * userText;

// Only works with .rtf files.
@property (nonatomic,strong) NSAttributedString *attributedText;

@property (nonatomic,strong,readonly) NSString *name;

@end


//
//  IDTDocument.m
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTDocument.h"

@interface IDTDocument ()
//Redefine name to be writable.
@property (nonatomic,strong,readwrite) NSString *name;

@end

@implementation IDTDocument
#pragma mark Initalizer

- (id)initWithFileURL:(NSURL *)url {
    
    self = [super initWithFileURL:url];
    self.name = [url lastPathComponent];
    return self;
}

#pragma mark UIDocument overrides

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
    if ([contents length] > 0)
        self.userText = [[NSString alloc]initWithBytes:[contents bytes] length:[contents length] encoding:NSUTF8StringEncoding];
    else {
        self.userText = @"Empty";
    }
    if ([self.fileType isEqualToString:@"public.rtf"]) {
        self.attributedText = [[NSAttributedString alloc]initWithData:contents options:nil documentAttributes:nil error:nil];
    }
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    if ([self.userText length] == 0) {
        self.userText = @"Empty";
    }
    if ([self.fileType isEqualToString:@"public.rtf"]) {
        NSError *error = nil;
        return [self.attributedText dataFromRange:NSMakeRange(0, self.attributedText.string.length) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:&error];
        if (error) {
            NSLog(@"error is %@",error);
        }
    } else {
        return [NSData dataWithBytes:[self.userText UTF8String]length:[self.userText length]];
    }
}

@end

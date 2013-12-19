
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

- (instancetype)initWithFileURL:(NSURL *)url {
    
    self = [super initWithFileURL:url];
    self.name = [url lastPathComponent];
    return self;
}

#pragma mark UIDocument overrides

// Called whenever the application reads data from the file system
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
    if ([contents respondsToSelector:@selector(length)]) {
        if ([contents length] > 0)
            self.userText = [[NSString alloc]initWithBytes:[contents bytes] length:[contents length] encoding:NSUTF8StringEncoding];
        else {
            self.userText = @"";
        }
    } else {
        return NO;
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
            if (*outError != nil) *outError = error;
            return nil;
        }
    } else {
        const char *UTF8String = [self.userText UTF8String];
        NSData *data = [NSData dataWithBytes:UTF8String length:strlen(UTF8String)];
        return data;
    }
}

@end


//
//  IDTDocument.m
//  AttributedTextED
//
//  Created by E&Z Pierson on 11/28/12.
//  Copyright (c) 2012 E&Z Pierson. All rights reserved.
//

#import "IDTDocument.h"
//#import "SSKeychain.h"
//#import "SSKeychainQuery.h"
@interface IDTDocument ()
@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, strong) NSMutableArray *nameArray;
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
        self.userText = @"Empty"; // When the note is created we assign some default content
    }
//    if ([self.fileType isEqualToString:@"public.rtf"]) {
//        self.attributedText = [[NSAttributedString alloc]initWithData:contents options:nil documentAttributes:nil error:nil];
//    }
    return YES;
}

// Called whenever the application (auto)saves the content of a note
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    if ([self.userText length] == 0) {
        self.userText = @"Empty";
    }
//    if ([self.fileType isEqualToString:@"public.rtf"]) {
//        NSError *error = nil;
//        return [self.attributedText dataFromRange:NSMakeRange(0, self.attributedText.string.length) documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:&error];
//        if (error) {
//            NSLog(@"error is %@",error);
//        }
//    } else {
        return [NSData dataWithBytes:[self.userText UTF8String]length:[self.userText length]];
//    }
}
//FIXME: OOP Integrity: This should be it's own object.
#pragma mark Basic String match.

- (NSMutableArray *)stringMatchInString:(NSString *)inString WithRegularExpr:(NSString *)regex {
    NSError *error = nil;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive|NSRegularExpressionSearch error:&error];
    self.rangesOfHighlight = [[NSMutableArray alloc]initWithCapacity:50];
    //This fixes an annoying .DS_Store simulator bug.
    if (inString) {
    [regularExpression enumerateMatchesInString:inString options:0 range:[inString rangeOfString:inString] usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange textMatchRange = [result rangeAtIndex:0];
        [self.rangesOfHighlight addObject:[NSValue valueWithRange:textMatchRange]];
    }];
    }
    
    if (error) {
        NSLog(@"Regex Error: %@",error);
    }
   
    return self.rangesOfHighlight;
}

//-(void)disableEditing {
//    NSLog(@"I NEED TO TAKE CARE OF THIS!!");
//    //NSAssert(2+2 == 5, @"This is gonna fail no matter what mwahhhaah!!!!");
// }
//
//-(void)enableEditing {
//    NSLog(@"I NEED TO TAKE CARE OF THIS!!");
//   // NSAssert(2+2 == 5, @"This is gonna fail no matter what mwahhhaah!!!!");
//}


@end

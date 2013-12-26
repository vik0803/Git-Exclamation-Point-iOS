// 
//   IDTTextStorage.m
//   RTF7
// 
//   Created by E&Z Pierson on 6/17/13.
//   Copyright (c) 2013 E&Z Pierson. All rights reserved.
// 

#import "IDTTextStorageDelegate.h"
#import "IDTComponentToHighlight.h"
NSString *const IDTDefaultTokenName = @"IDTDefaultTokenName";

@interface IDTTextStorageDelegate ()
@property (nonatomic,strong) NSMutableAttributedString *backingStore;
@property (nonatomic,strong) NSDictionary *objectiveCLangDict;
@property (nonatomic) BOOL dynamicTextNeedsUpdate;
@property (nonatomic,strong) NSDictionary *tokens;
@end

@implementation IDTTextStorageDelegate

- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {

    if (![self.backingStore isEqualToAttributedString:(NSMutableAttributedString *)textStorage]) {
        self.backingStore = (NSMutableAttributedString *)textStorage;
        [self performReplacementsForCharacterChangeInRange:editedRange];
        self.backingStore = nil;
    }


    
}


-(instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ObjectiveCLang" ofType:@"plist"];
        self.objectiveCLangDict = [NSDictionary dictionaryWithContentsOfFile:path];
        self.tokens = self.objectiveCLangDict[@"keywords"];
        
        

    }
    return self;
}


-(void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyTokenAttributesToRange:extendedRange];
    

}

-(void)applyTokenAttributesToRange:(NSRange)searchRange {
     NSDictionary *defaultAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
    [self.backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         NSString *color = self.tokens[substring];
         NSDictionary *attributesForToken = [self attributesForColor:color];
        if (!attributesForToken) {
             attributesForToken = defaultAttributes;
         }
         if(attributesForToken)
             [self.backingStore addAttributes:attributesForToken range:substringRange];
    
     }];
    [self highlightComments:searchRange];
     NSString *backingStoreString = self.backingStore.string;
     dispatch_queue_t moreColoring = dispatch_queue_create("Continue job of coloring,",DISPATCH_QUEUE_CONCURRENT);
     dispatch_async(moreColoring, ^{
        NSArray *componentsToHighlight = [self highlightFunctionSyntax:backingStoreString];
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         dispatch_async(mainQueue, ^{
             for (IDTComponentToHighlight *componentToHighlight in componentsToHighlight) {
                 [self.backingStore addAttributes:componentToHighlight.attributes range:componentToHighlight.range];
             }
         });
     });
}
-(void)highlightComments:(NSRange)searchRange {
    [self.backingStore.string enumerateSubstringsInRange:searchRange options:NSStringEnumerationByLines usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        NSRange beginningOfComment = [substring rangeOfString:@"//"];
        if (beginningOfComment.location != NSNotFound) {
            NSRange entireCommentRange = NSMakeRange(beginningOfComment.location, substring.length - beginningOfComment.location);
            NSString *entireComment = [substring substringWithRange:entireCommentRange];
            NSRange completeRange = [self.backingStore.string rangeOfString:entireComment options:0 range:substringRange];
            [self.backingStore addAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} range:completeRange];
        }
    }];
    

}
-(NSArray *)highlightFunctionSyntax:(NSString *)backingStore {
    NSMutableArray *keyWords = [NSMutableArray array];
    NSString *regexString = self.objectiveCLangDict[@"functionDefinition"];
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:regexString options:NSRegularExpressionAnchorsMatchLines error:nil];
    [regex enumerateMatchesInString:backingStore options:0 range:NSMakeRange(0, [self.backingStore.string length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        IDTComponentToHighlight *componentToHighlight = [[IDTComponentToHighlight alloc]initWithRange:result.range attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:.1 green:.5 blue:.2 alpha:1]}];
        [keyWords addObject:componentToHighlight];
    }];
    
    return keyWords;
}

-(NSDictionary *)attributesForColor:(NSString *)color {
    NSDictionary *attributesForToken = nil;
    if ([color isEqualToString:@"blueColor"]) {
        attributesForToken = @{NSForegroundColorAttributeName : [UIColor blueColor]};
    } else if ([color isEqualToString:@"redColor"]) {
        attributesForToken = @{NSForegroundColorAttributeName : [UIColor redColor]};
        
    } else if ([color isEqualToString:@"orangeColor"]) {
        attributesForToken = @{NSForegroundColorAttributeName : [UIColor orangeColor]};
        
    } else if ([color isEqualToString:@"purpleColor"]) {
        attributesForToken = @{NSForegroundColorAttributeName : [UIColor purpleColor]};
    }
    
    return attributesForToken;
}








@end

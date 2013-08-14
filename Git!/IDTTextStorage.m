// 
//   IDTTextStorage.m
//   RTF7
// 
//   Created by E&Z Pierson on 6/17/13.
//   Copyright (c) 2013 E&Z Pierson. All rights reserved.
// 

#import "IDTTextStorage.h"
#import "IDTComponentToHighlight.h"
NSString *const IDTDefaultTokenName = @"IDTDefaultTokenName";

@interface IDTTextStorage ()

@property (nonatomic,strong) NSMutableAttributedString *backingStore;
@property (nonatomic,strong) NSDictionary *objectiveCLangDict;
@property (nonatomic) BOOL dynamicTextNeedsUpdate;
@end

@implementation IDTTextStorage
-(instancetype)init {
    self = [super init];
    if (self) {
        self.backingStore = [[NSMutableAttributedString alloc]init];
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ObjectiveCLang" ofType:@"plist"];
        self.objectiveCLangDict = [NSDictionary dictionaryWithContentsOfFile:path];
        self.tokens = self.objectiveCLangDict[@"keywords"];
        
        

    }
    return self;
}

-(NSString *)string {
    return [self.backingStore string];
}

-(NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [self.backingStore attributesAtIndex:location effectiveRange:range];
}

-(void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    [self beginEditing];
    [self.backingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters|NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    self.dynamicTextNeedsUpdate = YES;
    [self endEditing];
}

-(void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    [self beginEditing];
    [self.backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

-(void)processEditing {

    if (self.dynamicTextNeedsUpdate) {
        self.dynamicTextNeedsUpdate = NO;
        [self performReplacementsForCharacterChangeInRange:[self editedRange]];
    }
    [super processEditing];

}

-(void)performReplacementsForCharacterChangeInRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_backingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    //if (arc4random() % 5 == 1) {
    [self applyTokenAttributesToRange:extendedRange];
    //}


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
             [self addAttributes:attributesForToken range:substringRange];
    
     }];
    [self highlightComments:searchRange];
     NSString *backingStoreString = self.backingStore.string;
     dispatch_queue_t moreColoring = dispatch_queue_create("Continue job of coloring,",NULL);
     dispatch_async(moreColoring, ^{
        NSArray *componentsToHighlight = [self highlightFunctionSyntax:backingStoreString];
         dispatch_queue_t mainQueue = dispatch_get_main_queue();
         dispatch_async(mainQueue, ^{
             for (IDTComponentToHighlight *componentToHighlight in componentsToHighlight) {
                 [self addAttributes:componentToHighlight.attributes range:componentToHighlight.range];
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
            [self addAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} range:completeRange];
        }
    }];
    

}
-(NSArray *)highlightFunctionSyntax:(NSString *)backingStore {
    NSMutableArray *keyWords = [[NSMutableArray alloc]initWithCapacity:20];
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

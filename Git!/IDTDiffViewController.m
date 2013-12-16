//
//  IDTDiffViewController.m
//  Git!
//
//  Created by E&Z Pierson on 7/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.

#import "IDTDiffViewController.h"
#import "IDTDocument.h"
#import "IDTTextStorageDelegate.h"
#import "push.h"
#import "remote.h"

@interface IDTDiffViewController ()
/// The individual file delta.
@property (nonatomic, strong) GTDiffDelta *diffDelta;

@end

@implementation IDTDiffViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self determineDelta];
    [self.diffDelta enumerateHunksUsingBlock:^(GTDiffHunk *hunk, BOOL *stop) {
        NSMutableArray *lines = [NSMutableArray array];
       [hunk enumerateLinesInHunk:nil usingBlock:^(GTDiffLine *line, BOOL *stop) {
           [lines addObject:line];
       }];
        NSArray *array = [self diff:lines];
        self.newTextView.attributedText = array[0];
        self.oldTextView.attributedText = array[1];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)determineDelta {
    NSError *error = nil;
    GTDiff *diff = [GTDiff diffIndexToWorkingDirectoryInRepository:self.repo options:nil error:&error];
    if (error) {
        NSLog(@"Error is %@",error);
    }
    [diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
        if ([delta.oldFile.path isEqualToString:self.statusDelta.oldFile.path] || [delta.newFile.path isEqualToString:self.statusDelta.newFile.path]) {
            self.diffDelta = delta;
            *stop = YES;
        }
    }];
}

- (NSArray *)diff:(NSMutableArray *)lines {
    NSMutableAttributedString *new = [[NSMutableAttributedString alloc]init];
    NSMutableAttributedString *old = [[NSMutableAttributedString alloc]init];

    for (GTDiffLine *line in lines) {
        switch (line.origin) {
            case GTDiffLineOriginContext: {
                NSString *lineContent = line.content;
                if ([line.content isEqualToString:@""]) {
                    lineContent = @"\n";
                }
                [old.mutableString appendString:lineContent];
                [new.mutableString appendString:lineContent];
                break;
            }
            case GTDiffLineOriginNoEOFNewlineContext:
                [old.mutableString appendString:line.content];
                [new.mutableString appendString:line.content];
                break;
            case GTDiffLineOriginAddEOFNewLine:
                [new.mutableString appendString:line.content];
                break;
            case GTDiffLineOriginDeleteEOFNewLine:
                [old.mutableString appendString:line.content];
                break;
            case GTDiffLineOriginAddition:
                [new.mutableString appendString:line.content];
                [new addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:[new.string rangeOfString:line.content]];
                break;
            case GTDiffLineOriginDeletion:
                [old.mutableString appendString:line.content];
                [old addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[old.string rangeOfString:line.content]];
                break;
            default:
                break;
        }
    }
    
    return @[new,old];
}

@end

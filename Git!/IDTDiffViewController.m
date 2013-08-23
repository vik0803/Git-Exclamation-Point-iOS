//
//  IDTDiffViewController.m
//  Git!
//
//  Created by E&Z Pierson on 7/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.

#import "IDTDiffViewController.h"
#import "IDTDocument.h"
#import "IDTTextStorageDelegate.h"
@interface IDTDiffViewController ()
//The individual file delta.
@property (nonatomic,strong) GTDiffDelta *delta;
@end

@implementation IDTDiffViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    IDTTextStorageDelegate *textStorageDelagate = [[IDTTextStorageDelegate alloc]init];
    self.changedTextView.textStorage.delegate = textStorageDelagate;
    self.unchangedTextVew.textStorage.delegate = textStorageDelagate;
    [self determineDelta];
    IDTDocument *oldDocument = [[IDTDocument alloc]initWithFileURL:self.gitFile.document.fileURL];
    IDTDocument *newDocument = self.gitFile.document;
    [oldDocument openWithCompletionHandler:^(BOOL success) {
        self.unchangedTextVew.text = oldDocument.userText;
        
        [newDocument openWithCompletionHandler:^(BOOL success) {
            self.changedTextView.text = newDocument.userText;
            
            [self.delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
                
                [hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *diffLine, BOOL *stop) {
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.changedTextView.text];
                    
                    [self.changedTextView.text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                        NSRange range = [self.changedTextView.text rangeOfString:diffLine.content];
                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor magentaColor] range:range];
//                       NSRange fullRange = NSMakeRange(0, self.changedTextView.text.length);
//                        if (!fullRange.length > range.location + diffLine.newLineNumber) {
//                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location, range.location + diffLine.newLineNumber)];
//                        }
//                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(range.location + diffLine.newLineNumber, 1)];
//                        if ([diffLine.content isEqualToString:line]) {
//                            NSRange range = [self.changedTextView.text rangeOfString:line];
//                            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];
//                            if (diffLine.oldLineNumber == -1) {
//                                self.unchangedTextVew.text = [self.unchangedTextVew.attributedText.string stringByReplacingOccurrencesOfString:line withString:@" "];
//                            }
                        
//                        }
                    }];
                    self.changedTextView.attributedText = attributedString;
                }];
            }];
        }];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)commitChanges:(id)sender {
    GTSignature *signature = [[GTSignature alloc]initWithName:nil email:nil time:[NSDate date]];
    GTTree *tree = [[GTTree alloc]init];
    NSError *error = nil;
    NSString *SHA = [GTCommit shaByCreatingCommitInRepository:self.gitFile.repo updateRefNamed:@"HEAD" author:signature committer:signature message:@"A commit that changed these files was made" tree:tree parents:nil error:&error];
    NSLog(@"SHA is %@",SHA);
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
-(void)determineDelta {
    NSError *error = nil;
    GTDiff *diff = [GTDiff diffIndexToWorkingDirectoryInRepository:self.gitFile.repo options:nil error:&error];
    if (error) {
        NSLog(@"Error is %@",error);
    }
    [diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
        NSString *oldFilePath = [self.gitFile.repo.fileURL.path stringByAppendingPathComponent:delta.oldFile.path];
        if ([oldFilePath isEqualToString:self.gitFile.document.fileURL.path]) {
            self.delta = delta;
            *stop = YES;
        }
    }];

}
@end

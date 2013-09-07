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
@property (nonatomic,strong) IDTTextStorageDelegate *textStorageDelagate;
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
    self.textStorageDelagate = [[IDTTextStorageDelegate alloc]init];
   // self.changedTextView.textStorage.delegate = self.textStorageDelagate;
    //self.unchangedTextVew.textStorage.delegate = self.textStorageDelagate;
    
    [self determineDelta];
    IDTDocument *oldDocument = [[IDTDocument alloc]initWithFileURL:self.gitFile.document.fileURL];
    IDTDocument *newDocument = self.gitFile.document;
    [oldDocument openWithCompletionHandler:^(BOOL success) {
        self.unchangedTextVew.text = oldDocument.userText;
        
        [newDocument openWithCompletionHandler:^(BOOL success) {
            self.changedTextView.text = newDocument.userText;
            
            [self.delta enumerateHunksWithBlock:^(GTDiffHunk *hunk, BOOL *stop) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.changedTextView.text];

                [hunk enumerateLinesInHunkUsingBlock:^(GTDiffLine *diffLine, BOOL *stop) {
                    NSString *highlightString = [self getLineFromLineNumber:diffLine.newLineNumber];
                    if (highlightString) {
                        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[self.changedTextView.text rangeOfString:highlightString]];
                    }
                }];
                self.changedTextView.attributedText = attributedString;
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
    if(error) NSLog(@"error is %@",error);
    NSLog(@"SHA is %@",SHA);
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(NSString *)getLineFromLineNumber:(NSInteger)targetLineNumber {
    __block NSInteger currentLineNumber = 0;
    __block NSString *returnString;
    [self.changedTextView.text enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (currentLineNumber == targetLineNumber) {
            returnString = line;
            *stop = YES;
        }
        currentLineNumber++;
    }];
    
   return returnString;
}


@end

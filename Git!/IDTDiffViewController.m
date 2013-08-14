//
//  IDTDiffViewController.m
//  Git!
//
//  Created by E&Z Pierson on 7/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.

#import "IDTDiffViewController.h"
#import "IDTDocument.h"
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
    [self determineDelta];
    IDTDocument *oldDocument = [[IDTDocument alloc]initWithFileURL:self.gitObject.document.fileURL];
    IDTDocument *newDocument = self.gitObject.document;
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
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
-(void)determineDelta {
    NSError *error = nil;
    GTDiff *diff = [GTDiff diffIndexToWorkingDirectoryInRepository:self.gitObject.repo options:nil error:&error];
    if (error) {
        NSLog(@"Error is %@",error);
    }
    [diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
        NSString *oldFilePath = [self.gitObject.repo.fileURL.path stringByAppendingPathComponent:delta.oldFile.path];
        if ([oldFilePath isEqualToString:self.gitObject.document.fileURL.path]) {
            self.delta = delta;
            *stop = YES;
        }
    }];

}
@end

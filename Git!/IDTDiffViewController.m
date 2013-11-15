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

@property (nonatomic, strong) IDTDocument *currentDocument;

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
   
    self.tabBarController.title = @"HELLO";
    self.currentDocument = [[IDTDocument alloc]initWithFileURL:[self.repo.fileURL URLByAppendingPathComponent:self.statusDelta.newFile.path]];
    [self determineDelta];
    NSError *error = nil;
    GTObjectDatabase *objectDatabase = [[GTObjectDatabase alloc]initWithRepository:self.repo error:&error];
    if (error) {
        NSLog(@"error is %@",error);
    }
    NSString *oldFileText = nil;
    GTOdbObject *odbObject = [objectDatabase objectWithOID:self.statusDelta.oldFile.OID error:&error];
    if (odbObject.data) {
        oldFileText = [NSString stringWithUTF8String:[odbObject.data bytes]];
    } else {
        oldFileText = @"You are viewing this text because:\n 1. This 'file' is a submodule. (Submodule support is not implementaed, currently)\n 2. The file was deleted";
    }

    self.oldTextView.text = oldFileText;

    [self.currentDocument openWithCompletionHandler:^(BOOL success) {
        if (success) {
            self.newTextView.text = self.currentDocument.userText;
            [self.diffDelta enumerateHunksUsingBlock:^(GTDiffHunk *hunk, BOOL *stop) {
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.newTextView.text];
                [hunk enumerateLinesInHunk:nil usingBlock:^(GTDiffLine *line, BOOL *stop) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:[self.newTextView.text rangeOfString:line.content]];
                }];
            }];
        } else {
            self.newTextView.text = @"You are viewing this text because:\n 1. This 'file' is a submodule. (Submodule support is not implemented, currently.)\n 2. The file was deleted";
        }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)determineDelta {
    NSError *error = nil;
    GTDiff *diff = [GTDiff diffIndexToWorkingDirectoryInRepository:self.repo options:nil error:&error];
    if (error) {
        NSLog(@"Error is %@",error);
    }
    [diff enumerateDeltasUsingBlock:^(GTDiffDelta *delta, BOOL *stop) {
        NSString *oldFilePath = [self.repo.fileURL.path stringByAppendingPathComponent:delta.oldFile.path];
        if ([oldFilePath isEqualToString:self.currentDocument.fileURL.path]) {
            self.diffDelta = delta;
            *stop = YES;
        }
    }];
    

}

@end

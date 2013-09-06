//
//  IDTFileEditViewController.m
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTFileEditViewController.h"
#import "IDTDiffViewController.h"
#import "IDTTextStorageDelegate.h"
@interface IDTFileEditViewController () <UITextViewDelegate>
@property (nonatomic,strong) IDTTextStorageDelegate *textStorageDelagate;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@end

@implementation IDTFileEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textStorageDelagate = [[IDTTextStorageDelegate alloc]init];
    self.textView.textStorage.delegate = self.textStorageDelagate;
    self.textView.delegate = self;
    [self openDocument];
    
    if (self.gitFile.gitStatus != 0) {
        NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];
        [toolbarButtons addObject:self.commitFile];
        [self.toolbar setItems:toolbarButtons animated:YES];
    } else {
        NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];
        [toolbarButtons removeObject:self.commitFile];
        [self.toolbar setItems:toolbarButtons animated:YES];
    }
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)textViewDidChange:(UITextView *)textView {
    self.gitFile.document.userText = textView.text;
    [self.gitFile.document updateChangeCount:UIDocumentChangeDone];
}
-(void)viewWillDisappear:(BOOL)animated {
    [self closeDocument];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IDTDiffViewController *diffVC = [segue destinationViewController];
    diffVC.gitFile = self.gitFile;
}
-(void)closeDocument {
    if (self.gitFile) {
        if (self.gitFile.document.documentState == UIDocumentStateNormal) {
            [self.gitFile.document closeWithCompletionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"NOOOOOOOO The document failed to close naughty you!");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Failure" message:@"The document failed to save correctly please cross your fingers and restart this app." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
    }
}

-(void)openDocument {
    if (self.gitFile.document.documentState == UIDocumentStateClosed) {
        [self.gitFile.document openWithCompletionHandler:^(BOOL success) {
            self.textView.text = self.gitFile.document.userText;
        }];
    }
}



@end

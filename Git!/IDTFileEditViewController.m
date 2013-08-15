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
    [self.gitObject.document openWithCompletionHandler:^(BOOL success) {
        self.textView.text = self.gitObject.document.userText;


    }];
    
    if (self.gitObject.gitStatus == 0) {
        NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];
        [toolbarButtons removeObject:self.commitFile];
        [self.toolbar setItems:toolbarButtons animated:YES];
    } else if (![self.toolbar.items containsObject:self.commitFile]) {
        NSMutableArray *toolbarButtons = [self.toolbar.items mutableCopy];
        [toolbarButtons addObject:self.commitFile];
        [self.toolbar setItems:toolbarButtons animated:YES];
    }
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)textViewDidChange:(UITextView *)textView {
    self.gitObject.document.userText = textView.text;
    [self.gitObject.document updateChangeCount:UIDocumentChangeDone];
}
-(void)viewWillDisappear:(BOOL)animated {
    if (self.gitObject.document.documentState == UIDocumentStateNormal) {
        [self closeDocument];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    IDTDiffViewController *diffVC = [segue destinationViewController];
    diffVC.gitObject = self.gitObject;
}
-(void)closeDocument {
    [self.gitObject.document closeWithCompletionHandler:^(BOOL success) {
        if (!success) {
          NSLog(@"NOOOOOOOO The document failed to close naughty you!");
        }
    }];

}
@end

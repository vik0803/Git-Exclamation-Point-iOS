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
#import "IDTChooseCollectionViewController.h"
#import "IDTBranchTableViewController.h"
#import "IDTBranchManager.h"
@interface IDTFileEditViewController () <UITextViewDelegate,UIPopoverControllerDelegate>

@property (nonatomic,strong) IDTTextStorageDelegate *textStorageDelagate;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *branchBarButtonItem;

@property (nonatomic, strong) UIPopoverController *branchPopoverController;

@end

@implementation IDTFileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textStorageDelagate = [[IDTTextStorageDelegate alloc]init];
    self.textView.textStorage.delegate = self.textStorageDelagate;
    self.textView.delegate = self;
    
    [self openDocument];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated {
    GTBranch *branch = [self.gitFile.repo currentBranchWithError:nil];
    self.branchBarButtonItem.title = branch.shortName;
}
-(void)viewWillDisappear:(BOOL)animated {
    [self closeDocument];
}

#pragma mark Text Handling

-(void)textViewDidChange:(UITextView *)textView {
    self.gitFile.document.userText = textView.text;
    [self.gitFile.document updateChangeCount:UIDocumentChangeDone];
}

-(void)openDocument {
    if (self.gitFile.document.documentState == UIDocumentStateClosed) {
        self.textView.editable = NO;
        [self.gitFile.document openWithCompletionHandler:^(BOOL success) {
            self.textView.text = self.gitFile.document.userText;
            self.textView.editable = YES;
        }];
    }
}

-(void)closeDocument {
    if (self.gitFile) {
        if (self.gitFile.document.documentState == UIDocumentStateNormal) {
            [self.gitFile.document closeWithCompletionHandler:^(BOOL success) {
                if (!success) {
                    NSLog(@"Error: The document failed to close. This should not happen please contact the developer.");
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"The document failed to save correctly. Please cross your fingers, and restart this app." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
    }
}

#pragma mark Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.textView endEditing:YES];
    if ([segue.identifier isEqualToString:@"segueToCommitWorkflow"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        IDTChooseCollectionViewController *chooseCollectionViewController = (IDTChooseCollectionViewController *)navigationController.topViewController;
        chooseCollectionViewController.repo = self.gitFile.repo;
    } else if ([segue.identifier isEqualToString:@"segueToPopover"]) {
        UIPopoverController *popoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
        IDTBranchTableViewController *branchTableViewController = [segue destinationViewController];
        //FIXME: Use autolayout.
        CGSize size = {400,400};
        popoverController.popoverContentSize = size;
        popoverController.delegate = self;
        IDTBranchManager *branchManager = [[IDTBranchManager alloc]initWithPopoverController:popoverController repo:self.gitFile.repo];
        branchTableViewController.branchManager = branchManager;
        branchTableViewController.tableView.dataSource = branchManager;
    }
}

#pragma mark PopoverController Delegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    IDTBranchTableViewController *branchTableViewController = (IDTBranchTableViewController *)popoverController.contentViewController;
    if (branchTableViewController.branch) {
        self.branchBarButtonItem.title = branchTableViewController.branch.shortName;
    }
}


@end

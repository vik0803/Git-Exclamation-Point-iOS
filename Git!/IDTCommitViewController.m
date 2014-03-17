//
//  IDTCommitViewController.m
//  Git!
//
//  Created by E&Z Pierson on 10/13/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTCommitViewController.h"
#import "IDTStatusViewController.h"
#import "IDTDocument.h"
#import "git2/pathspec.h"
#import "NSError+AlertView.h"
#import "IDTTreeCreator.h"

@interface IDTCommitViewController () <UIAlertViewDelegate>
@end

@implementation IDTCommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pushOnCommit.on = NO;
    self.nameTextField.text = @"Ezekiel Pierson";
    self.emailTextField.text = @"manit8525@gmail.com";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)commit:(UIBarButtonItem *)sender {
    NSError *error = nil;
    IDTTreeCreator *treeCreator = [[IDTTreeCreator alloc]initWithRepository:self.repo];
    GTTree *tree = [treeCreator commitFiles:self.filesToCommit error:&error];

    GTBranch *branch = [self.repo currentBranchWithError:&error];
    if (error) [error showErrorInAlertView];
    GTCommit *parentCommit = [self.repo lookUpObjectByRevParse:@"HEAD" error:&error];
    GTSignature *signature = [[GTSignature alloc]initWithName:self.nameTextField.text email:self.emailTextField.text time:[NSDate date]];
    NSArray *parents = nil;
    if (parentCommit) parents = @[parentCommit];
    
    GTCommit *commit = [self.repo createCommitWithTree:tree message:self.commitMessageTextView.text author:signature committer:signature parents:parents updatingReferenceNamed:branch.reference.name error:&error];

    if (commit != nil || error != nil) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:[error description]  delegate:self cancelButtonTitle:@"Apology Accepted" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSString *message = nil;
    if (self.pushOnCommit.isOn) {
        // FIXME: Add push support
        message = @"Currently Pushing to a repository is not supported.";
    } else {
        NSString *workingDirStatus = self.repo.workingDirectoryClean ? @"Clean" : @"Dirty";
        message = [NSString stringWithFormat:@"Working Directory is %@",workingDirStatus];
    }
  
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Done" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedSegue"]) {
        IDTStatusViewController *statusVC = [segue destinationViewController];
        statusVC.statusDeltas = self.filesToCommit;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

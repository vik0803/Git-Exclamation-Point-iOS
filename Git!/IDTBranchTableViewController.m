//
//  IDTBranchTableViewController.m
//  Git!
//
//  Created by E&Z Pierson on 11/5/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTBranchTableViewController.h"

@interface IDTBranchTableViewController () <UIAlertViewDelegate>


@end

@implementation IDTBranchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView setEditing:NO];
}


#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = self.branchManager.branches[indexPath.row];
    if ([object isKindOfClass:[GTBranch class]]) {
        self.branch = object;
        BOOL success = [self.branchManager checkoutBranch:self.branch error:nil progressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
            
        }];
        if (success) {
            [self.branchManager.popoverController dismissPopoverAnimated:YES];
            [self.branchManager.popoverController.delegate popoverControllerDidDismissPopover:self.branchManager.popoverController];
        } else {
            NSLog(@"Failure");
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Name of Branch" message:@"Please type in the name of Branch" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
         self.branch = [self.branchManager createLocalBranchWithShortName:[alertView textFieldAtIndex:0].text];

    } else if (buttonIndex == 0) {
        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO];
    }
}


@end

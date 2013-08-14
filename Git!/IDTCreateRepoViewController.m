//
//  IDTCreateRepoViewController.m
//  Git!
//
//  Created by E&Z Pierson on 7/18/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTCreateRepoViewController.h"
#import <ObjectiveGit.h>
#import "IDTGitDirectory.h"
#import "IDTRepositoryTableViewController.h"
@interface IDTCreateRepoViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *cloneSwitch;
@property (weak, nonatomic) IBOutlet UITextField *repoNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *cloneURLTextField;

@end

@implementation IDTCreateRepoViewController

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
    self.repoNameTextField.placeholder = @"Type in the name of the Repo";
    self.cloneURLTextField.placeholder = @"Type in the URL of the git repository to clone. Make sure to turn on the clone switch aswell";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createRepo:(id)sender {
    IDTGitDirectory *gitRepository = Nil;
    if (self.cloneSwitch.on) {
        NSError *error = nil;
        NSString *nameString = [NSString stringWithFormat:@"Documents/%@",self.repoNameTextField.text];
        NSURL *fileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:nameString]];
        GTRepository *repo = [GTRepository cloneFromURL:[NSURL URLWithString:self.cloneURLTextField.text] toWorkingDirectory:fileURL barely:NO withCheckout:NO error:&error transferProgressBlock:^(const git_transfer_progress *transferProgress) {
            
        } checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
            
        }];
        if (error || repo == nil) {
            NSLog(@"error is %@",error);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Failure" message:error.description delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"Ok", nil];
            [alertView show];
        } else {
        gitRepository = [[IDTGitDirectory alloc]initWithRepo:repo];
        }
    }else {
        NSError *error = nil;
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",self.repoNameTextField.text]];
        [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:NO attributes:Nil error:&error];
        if (error) {
            NSLog(@"error is %@",error);
        }
        BOOL success = [GTRepository initializeEmptyRepositoryAtURL:[NSURL fileURLWithPath:path] bare:NO error:&error];
        if (success) {
            GTRepository *repo = [[GTRepository alloc]initWithURL:[NSURL fileURLWithPath:path] error:&error];
            gitRepository = [[IDTGitDirectory alloc]initWithRepo:repo];
        } else {
            NSLog(@"error is %@",error);
        }
    }
    UISplitViewController *splitView = (UISplitViewController *)self.presentingViewController;
    UINavigationController *navController = [splitView.viewControllers objectAtIndex:0];
    IDTRepositoryTableViewController *repoTableVC = [navController.viewControllers objectAtIndex:0];
    [self dismissViewControllerAnimated:YES completion:^{
        [repoTableVC.gitDirectories addObject:gitRepository];
        [repoTableVC.tableView reloadData];
    }];

}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

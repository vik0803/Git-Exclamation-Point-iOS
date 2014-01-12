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
@interface IDTCreateRepoViewController () <UITextFieldDelegate>
// Weather or not the repo we are creating is going to be cloned. Set to `YES` if the cloneURLTextField is filled.
@property (weak, nonatomic) IBOutlet UISwitch *cloneSwitch;
// The name is extracted from `cloneURLTextField`.
@property (weak, nonatomic) IBOutlet UITextField *repoNameTextField;
// The URL of the remote repository to clone.
@property (weak, nonatomic) IBOutlet UITextField *cloneURLTextField;
// Only shown if cloneSwitch is set to `YES`. Then is set to `YES`
@property (weak, nonatomic) IBOutlet UISwitch *cloneWithCheckoutSwitch;
// A simple label. We have this as a property because we sometimes need to hide it.
@property (weak, nonatomic) IBOutlet UILabel *checkoutLabel;
// As above.
@property (weak, nonatomic) IBOutlet UILabel *barelyLabel;
// Weather or not the cloned repo will be bare. Set to `NO`
@property (weak, nonatomic) IBOutlet UISwitch *cloneBarelySwitch;
// A textView used during a clone.
@property (weak, nonatomic) IBOutlet UITextView *textView;
// We need this property so we can dynaimcly show/hide it.
@property (weak, nonatomic) IBOutlet UILabel *consoleLable;
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

    self.view.tintColor = [UIColor purpleColor];
    self.cloneSwitch.on = NO;
    self.cloneWithCheckoutSwitch.hidden = YES;
    self.cloneBarelySwitch.hidden = YES;
    self.checkoutLabel.hidden = YES;
    self.barelyLabel.hidden = YES;
    [self.cloneSwitch addTarget:self action:@selector(cloneSwitchDidTurn) forControlEvents:UIControlEventValueChanged];
    self.repoNameTextField.placeholder = @"Type in the name of the Repo";
    self.cloneURLTextField.placeholder = @"Type in the URL of the git repository to clone.";
    self.cloneURLTextField.delegate = self;
    self.textView.editable = NO;
    self.consoleLable.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)createRepo:(id)sender {
    IDTGitDirectory *gitRepository = nil;
    [self.view endEditing:YES];
    if (self.cloneSwitch.on) {
        NSError *error = nil;
        gitRepository = [IDTGitDirectory cloneWithName:self.repoNameTextField.text URL:[NSURL URLWithString:self.cloneURLTextField.text] barely:self.cloneBarelySwitch.on checkout:self.cloneWithCheckoutSwitch.on transferProgressBlock:^(const git_transfer_progress *transfer_progress) {
            self.consoleLable.hidden = NO;
            NSString *string = [NSString stringWithFormat:@"Received %d objects and indexed %d out of  a total of %d \n",transfer_progress->received_objects,transfer_progress->indexed_objects,transfer_progress->total_objects];
            self.textView.text = [self.textView.text stringByAppendingString:string];
        } checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
            self.consoleLable.hidden = NO;
            NSString *string = [NSString stringWithFormat:@"Checking out Path %@. \n Completed %lu out of %lu \n",path,(unsigned long)completedSteps,(unsigned long)totalSteps];
            self.textView.text = [self.textView.text stringByAppendingString:string];
        } error:&error];
        
        if (error) {
            NSLog(@"error is %@",error);
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Failure" message:error.description delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alertView show];
            return;
        }
    } else {
        NSError *error = nil;
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@",self.repoNameTextField.text]];
        [[NSFileManager defaultManager]createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        if (error) {
            NSLog(@"error is %@",error);
            error = nil;
        }
        GTRepository *repo = [GTRepository initializeEmptyRepositoryAtFileURL:[NSURL fileURLWithPath:path] error:&error];
        if (repo) {
            gitRepository = [[IDTGitDirectory alloc]initWithRepo:repo];
        } else {
            NSLog(@"error is %@",error);
        }
    }
    
    UISplitViewController *splitView = (UISplitViewController *)self.presentingViewController;
    IDTRepositoryTableViewController *repoTableViewController = nil;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        UINavigationController *navigationController = splitView.viewControllers[0];
        repoTableViewController = (IDTRepositoryTableViewController *)navigationController.topViewController;
    } else {
        repoTableViewController = splitView.viewControllers[0];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [repoTableViewController.gitDirectories addObject:gitRepository];
        [repoTableViewController.tableView reloadData];
    }];

}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cloneSwitchDidTurn {
    if (self.cloneSwitch.on) {
        self.cloneWithCheckoutSwitch.hidden = NO;
        self.cloneBarelySwitch.hidden = NO;
        self.checkoutLabel.hidden = NO;
        self.barelyLabel.hidden = NO;
        self.cloneWithCheckoutSwitch.on = YES;
        self.cloneBarelySwitch.on = NO;
    } else {
        self.cloneWithCheckoutSwitch.hidden = YES;
        self.cloneBarelySwitch.hidden = YES;
        self.checkoutLabel.hidden = YES;
        self.barelyLabel.hidden = YES;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) {
        return;
    }
    NSURL *url = [[NSURL alloc]initWithString:textField.text];
    NSURLComponents *components = [[NSURLComponents alloc]initWithURL:url resolvingAgainstBaseURL:NO];
    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:@"[^/]+(?=/$|$)" options:0 error:nil];
    [regex enumerateMatchesInString:components.path options:0 range:NSMakeRange(0, components.path.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.length > 4) {
            NSRange removeExtraneousCharactersRanger = result.range;
            removeExtraneousCharactersRanger.length = removeExtraneousCharactersRanger.length - 4;
            self.repoNameTextField.text = [components.path substringWithRange:removeExtraneousCharactersRanger];
        }
    }];
    self.cloneSwitch.on = YES;
    [self cloneSwitchDidTurn];
}

@end

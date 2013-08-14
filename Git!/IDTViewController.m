//
//  IDTViewController.m
//  Git!
//
//  Created by E&Z Pierson on 6/29/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTViewController.h"
@interface IDTViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end

@implementation IDTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createRepo:(id)sender {
    NSError *error = nil;
    BOOL createWorked = [GTRepository initializeEmptyRepositoryAtURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trial.git"]]  error:&error];
    if (error || !createWorked) {
        NSLog(@"error is %@",error);
        NSLog(@"createWorked is %d",createWorked);
    }else {
        NSLog(@"createWorked is %d",createWorked);
    }
    GTRepository *repo = [[GTRepository alloc]initWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trial.git"]] error:&error];
    if (error) {
        NSLog(@"error is %@",error);
    }
    NSLog(@"commits is %d",[repo numberOfCommitsInCurrentBranch:nil]);
    
}

- (IBAction)commitToRepo:(id)sender {
//    GTRepository *repo = [[GTRepository alloc]initWithURL:[NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/trial.git"]] error:nil];
     
    //GTSignature *authorAndCommitter = [[GTSignature alloc]initWithName:@"Ezekiel" email:@"manit8525@gmail.com" time:nil];
//    GTCommit *commit  = [GTCommit commitInRepository:repo updateRefNamed:@"HEAD" author:authorAndCommitter committer:authorAndCommitter message:@"Well hello there. I wonder is this compatible with core git?" tree:nil parents:nil error:nil];
    
}
- (IBAction)cloneRepo:(id)sender {
    NSError *error = nil;
    NSURL *cloneURL;
    if (self.textField.text) {
        cloneURL = [NSURL URLWithString:self.textField.text];
    } else {
        cloneURL = [NSURL URLWithString:@"http://github.com/"];
    }
    NSURL *nameURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[@"Documents" stringByAppendingPathComponent:[cloneURL lastPathComponent]]]];
    NSString *string = [NSString stringWithString:[nameURL absoluteString]];
    string = [string substringWithRange:NSMakeRange(0, string.length -4)];
    nameURL = [NSURL fileURLWithPath:string];
    float progress = 0.0;
    GTRepository *clone = [GTRepository cloneFromURL:cloneURL toWorkingDirectory:nameURL barely:NO withCheckout:NO error:&error transferProgressBlock:^(const git_transfer_progress *transferProgress) {
        self.progressView.progress = progress + 0.1;
        NSLog(@"hello");
    } checkoutProgressBlock:nil];
    NSLog(@"Did the clone succeed? %@ and error is %@",clone,error);
    if (!error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Clone" message:@"The clone was successful!" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];        
    }
}
@end

//
//  IDTCommitViewController.h
//  Git!
//
//  Created by E&Z Pierson on 10/13/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"

@interface IDTCommitViewController : UIViewController
//Credentials. //TODO: These shouldn't be static.
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
//Credentials.
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
// A UISwitch wrapping a BOOL. Determiens weather or not the commit is also a push.
//TODO: Make this switch cause somthing to actualy happen.
@property (weak, nonatomic) IBOutlet UISwitch *pushOnCommit;
//The message of the commit.
@property (weak, nonatomic) IBOutlet UITextView *commitMessageTextView;
// An array of GTStatusDelta's. Set by the previous VC.
@property (nonatomic, strong) NSArray *filesToCommit;
// The repo to create the commit in. Set by the previous VC.
@property (nonatomic, strong) GTRepository *repo;


@end

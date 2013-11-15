//
//  IDTFileViewController.h
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"
#import "IDTGitDirectory.h"
@interface IDTFileViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic,strong) IDTGitDirectory *gitDirectory;

@end

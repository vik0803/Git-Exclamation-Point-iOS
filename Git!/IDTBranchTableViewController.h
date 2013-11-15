//
//  IDTBranchTableViewController.h
//  Git!
//
//  Created by E&Z Pierson on 11/5/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"
#import "IDTBranchManager.h"
@interface IDTBranchTableViewController : UITableViewController

// Set when we're about to dismiss.
@property (nonatomic, strong) GTBranch *branch;

@property (nonatomic, strong) IDTBranchManager *branchManager;

@end

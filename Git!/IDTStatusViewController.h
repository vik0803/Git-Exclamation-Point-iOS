//
//  IDTStatusViewController.h
//  Git!
//
//  Created by E&Z Pierson on 10/13/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"
@interface IDTStatusViewController : UIViewController

@property (nonatomic,strong) NSArray *statusDeltas;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

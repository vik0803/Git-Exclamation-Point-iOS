//
//  IDTChooseCollectionViewController.h
//  Git!
//
//  Created by E&Z Pierson on 10/11/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"
#import "IDTDiffViewController.h"
#import "IDTCommitViewController.h"
@interface IDTChooseCollectionViewController : UICollectionViewController

@property (nonatomic, strong) GTRepository *repo;


- (IBAction)selectCells:(UIBarButtonItem *)sender;

- (IBAction)dismiss:(UIBarButtonItem *)sender;

@end

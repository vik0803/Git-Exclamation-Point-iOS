//
//  IDTBranchManager.h
//  Git!
//
//  Created by E&Z Pierson on 11/12/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveGit.h"

@interface IDTBranchManager : NSObject <UITableViewDataSource>

-(instancetype)initWithPopoverController:(UIPopoverController *)popoverController repo:(GTRepository *)repo;

-(GTBranch *)createLocalBranchWithShortName:(NSString *)shortName;

-(BOOL)checkoutBranch:(GTBranch *)branch error:(NSError *)error progressBlock:(void (^) (NSString *path, NSUInteger completedSteps, NSUInteger totalSteps))progressBlock;

@property (nonatomic, strong) NSMutableArray *branches;

@property (nonatomic, strong, readonly) UIPopoverController *popoverController;


@end


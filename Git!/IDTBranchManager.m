//
//  IDTBranchManager.m
//  Git!
//
//  Created by E&Z Pierson on 11/12/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTBranchManager.h"
@interface IDTBranchManager ()


@property (nonatomic, strong, readwrite) UIPopoverController *popoverController;

@property (nonatomic, strong) GTRepository *repo;

@end

@implementation IDTBranchManager

-(instancetype)initWithPopoverController:(UIPopoverController *)popoverController repo:(GTRepository *)repo {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.popoverController = popoverController;
    self.repo = repo;
    self.branches = [[self.repo allBranchesWithError:nil]mutableCopy];
 
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:[self.branches copy]];
    NSString *string = @"Create New Branch";
    [array insertObject:string atIndex:0];
    self.branches = array;
    return self.branches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"branchCell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    GTBranch *branch = self.branches[indexPath.row];
    if ([branch isKindOfClass:[GTBranch class]]) {
        cell.textLabel.text = branch.shortName;
        if (branch.branchType == GTBranchTypeRemote) {
            NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:branch.shortName attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
            cell.textLabel.attributedText = attributedString;
        }
    } else {
        cell.textLabel.attributedText = [[NSAttributedString alloc]initWithString:(NSString *)branch attributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:0.41f green:0.91f blue:0.32f alpha:1.00f]}];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GTBranch *branch = self.branches[indexPath.row];
        NSError *error = nil;
        if ([branch deleteWithError:&error]) {
            [self.branches removeObjectAtIndex:indexPath.row];
            [self.popoverController dismissPopoverAnimated:YES];
        } else {
            NSLog(@"Error is %@",error);
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.branches[indexPath.row] isKindOfClass:[GTBranch class]] && [(GTBranch *)self.branches[indexPath.row] branchType] == GTBranchTypeLocal) {
        return YES;
    } else {
        return NO;
    }
}


-(GTBranch *)createLocalBranchWithShortName:(NSString *)shortName {
    NSError *error = nil;
    NSString *branchName = [NSString stringWithFormat:@"%@%@",[GTBranch localNamePrefix],shortName];
    
    GTReference *headReference = [self.repo headReferenceWithError:nil];
    GTReference *reference = [GTReference referenceByCreatingReferenceNamed:branchName fromReferenceTarget:headReference.OID.SHA inRepository:self.repo error:&error];
    GTBranch *branch = [GTBranch branchWithReference:reference repository:reference.repository];
    
    [self.repo checkoutReference:branch.reference strategy:GTCheckoutStrategyForce error:&error progressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
        NSLog(@"Checked out file: %@ \n",path);
        NSLog(@"Completed %lu out of %lu",(unsigned long)completedSteps,(unsigned long)totalSteps);
    }];
    if (error) {
        NSLog(@"error is %@",error);
    }
    if (branch) {
        return branch;
        [self.popoverController dismissPopoverAnimated:YES];
    }
    return nil;
    
}

-(BOOL)checkoutBranch:(GTBranch *)branch error:(NSError *)error progressBlock:(void (^)(NSString *, NSUInteger, NSUInteger))progressBlock {
    BOOL returnValue = NO;
    if (branch.branchType == GTBranchTypeLocal) {
       returnValue  = [self.repo checkoutReference:branch.reference strategy:GTCheckoutStrategyForce notifyFlags:GTCheckoutNotifyNone error:&error progressBlock:progressBlock notifyBlock:nil];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Unsupported Feature" message:@"Checking out a remote tracking branch is currently unsupported. Sorry." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
        returnValue = YES;
    }
    
    return returnValue;
}



@end

//
//  IDTChooseCollectionViewController.m
//  Git!
//
//  Created by E&Z Pierson on 10/11/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTChooseCollectionViewController.h"

@interface IDTChooseCollectionViewController ()

@property (nonatomic, strong) NSArray *statusDeltas;

@property (nonatomic, getter = isSelected) BOOL selected;

@property (nonatomic, strong) NSMutableArray *filesToCommit;

@end

@implementation IDTChooseCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSError *error = nil;
    __block NSInteger *numberOfFileStatuses = 0;
    __block NSMutableArray *createStatusDeltas = [@[] mutableCopy];
    [self.repo enumerateFileStatusWithOptions:@{ GTRepositoryStatusOptionsFlagsKey: @(GTRepositoryStatusFlagsExcludeSubmodules) } error:&error usingBlock:^(GTStatusDelta *headToIndex, GTStatusDelta *indexToWorkingDirectory, BOOL *stop) {
        numberOfFileStatuses++;
        if (headToIndex) {
            [createStatusDeltas addObject:headToIndex];
        } else if (indexToWorkingDirectory) {
            [createStatusDeltas addObject:indexToWorkingDirectory];
        }
    }];
    if(error) NSLog(@"Failure is %@",error);
    self.statusDeltas = createStatusDeltas;
    if (self.repo.workingDirectoryClean) {
        NSLog(@"Working directory clean!!!");
        //FIXME: This isn't good enough.
        CGPoint point = {250,250};
        CGSize size = {300,300};
        CGRect rect = {point,size};
        UILabel *label = [[UILabel alloc]initWithFrame:rect];
        label.text = @"Working Directory is ✨❕";
        [self.collectionView addSubview:label];
    }
    return createStatusDeltas.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ChooseCell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)cell.contentView.subviews[0];
    label.hidden = YES;
    GTStatusDelta *delta = self.statusDeltas[indexPath.row];
    switch (delta.status) {
        case GTStatusDeltaStatusAdded:
            cell.backgroundColor = [UIColor greenColor];
            break;
        case GTStatusDeltaStatusDeleted:
            cell.backgroundColor = [UIColor redColor];
            break;
        case GTStatusDeltaStatusUnmodified:
            cell.backgroundColor = [UIColor darkGrayColor];
            break;
        case GTStatusDeltaStatusModified:
            cell.backgroundColor = [UIColor blueColor];
            break;
        case GTStatusDeltaStatusCopied:
            NSLog(@"Make up a color");
            cell.backgroundColor = [UIColor blackColor];
            break;
        case GTStatusDeltaStatusIgnored:
            cell.backgroundColor = [UIColor brownColor];
            break;
        case GTStatusDeltaStatusUntracked:
            cell.backgroundColor = [UIColor lightGrayColor];
            break;
        case GTStatusDeltaStatusTypeChange:
            NSLog(@"I do not understand what this is. Sorry");
            break;
        case GTStatusDeltaStatusRenamed:
            cell.backgroundColor = [UIColor magentaColor];
            break;
        default:
            NSLog(@"What?");
            break;
    }
    
    return cell;
}

- (IBAction)selectCells:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Select"]) {
        self.selected = YES;
        sender.title = @"Continue";
        self.filesToCommit = [NSMutableArray array];
        [self dismiss:self.navigationItem.leftBarButtonItem];
    } else if ([sender.title isEqualToString:@"Continue"]) {
        [self performSegueWithIdentifier:@"segueToCommit" sender:sender];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isSelected) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        UILabel *label = (UILabel *)cell.contentView.subviews[0];
        [self toggleView:label statusDelta:self.statusDeltas[indexPath.row]];
    } else {
        [self performSegueWithIdentifier:@"segueToDiff" sender:indexPath];
    }
}


- (IBAction)dismiss:(UIBarButtonItem *)sender {
    if (self.isSelected && [sender.title isEqualToString:@"Dismiss"]) {
        sender.title = @"Cancel";
    } else if ([sender.title isEqualToString:@"Cancel"]) {
        self.selected = NO;
        sender.title = @"Dismiss";
        //Abort and reload!
        [self.collectionView reloadData];
        self.filesToCommit = nil;
        self.navigationItem.rightBarButtonItem.title = @"Select";
    } else if ([sender.title isEqualToString:@"Dismiss"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToDiff"]) {
        IDTDiffViewController *diffVC = [segue destinationViewController];
        diffVC.repo = self.repo;
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        diffVC.statusDelta = self.statusDeltas[indexPath.row];
    } else if ([segue.identifier isEqualToString:@"segueToCommit"]) {
        IDTCommitViewController *commitVC = [segue destinationViewController];
        commitVC.filesToCommit = self.filesToCommit;
        commitVC.repo = self.repo;
    }
}

#pragma mark Miscellaneous
//When the user taps to add or remove a cell to the array we need to determine what the user means, this method handles that.
-(void)toggleView:(UIView *)view statusDelta:(GTStatusDelta *)statusDelta {
    if (view.isHidden) {
        view.hidden = NO;
    } else {
        view.hidden = YES;
    }
    
    if ([self.filesToCommit containsObject:statusDelta]) {
        [self.filesToCommit removeObject:statusDelta];
    } else {
        [self.filesToCommit addObject:statusDelta];
    }
    
}


@end

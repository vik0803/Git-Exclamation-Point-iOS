//
//  IDTCommitViewController.m
//  Git!
//
//  Created by E&Z Pierson on 10/13/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTCommitViewController.h"
#import "IDTStatusViewController.h"
#import "IDTDocument.h"
#import "pathspec.h"
@interface IDTCommitViewController () <UIAlertViewDelegate>

@end

@implementation IDTCommitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pushOnCommit.on = NO;
    self.nameTextField.text = @"Ezekiel Pierson";
    self.emailTextField.text = @"manit8525@gmail.com";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)commit:(UIBarButtonItem *)sender {
    __block NSError *error = nil;
    
    GTCommit *commit = [self.repo lookupObjectByRefspec:@"HEAD" error:nil];
    GTTree *tree = commit.tree;
    GTTreeBuilder *builder = [[GTTreeBuilder alloc]initWithTree:tree error:&error];
    if (error) NSLog(@"error is %@",error); error = nil;
    for (GTStatusDelta *statusDelta in self.filesToCommit) {
        switch (statusDelta.status) {
            case GTStatusDeltaStatusModified || GTStatusDeltaStatusAdded:
                [self addEntry:statusDelta builder:builder error:nil];
                break;
            case GTStatusDeltaStatusDeleted:
                [self removeEntry:statusDelta builder:builder error:nil];
                break;
            default:
                break;
        }
    }

    tree = [builder writeTreeToRepository:self.repo error:&error];
    if (error) NSLog(@"error is %@",error); error = nil;
    
    [self finishCommit:tree];
}
-(void)finishCommit:(GTTree *)tree {
    NSError *error = nil;
    GTCommit *commit = [self.repo lookupObjectByRefspec:@"HEAD" error:nil];
    GTSignature *signature = [[GTSignature alloc]initWithName:self.nameTextField.text email:self.emailTextField.text time:[NSDate date]];
    [self updateIndex];
    NSArray *parents = nil;
    // We can't control everything in life. So be defensive.
    if (commit) {
        parents = @[commit];
    }
    [self.repo createCommitWithTree:tree message:self.commitMessageTextView.text author:signature committer:signature parents:parents updatingReferenceNamed:@"HEAD" error:&error];

    if (self.pushOnCommit.isOn) {
//    FIXME: Add Push support.
    } else {
        NSString *message = [NSString stringWithFormat:@"WorkingDir is %d",self.repo.isWorkingDirectoryClean];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Done" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embededSegue"]) {
        IDTStatusViewController *statusVC = [segue destinationViewController];
        statusVC.statusDeltas = self.filesToCommit;
    }
}

-(BOOL)checkForError:(NSInteger)gitError error:(NSError **)error {
    if (gitError < GIT_OK) {
        if (error != NULL) *error = [NSError git_errorFor:(int)gitError]; NSLog(@"error is %@",*error);
        return NO;
    } else {
        return YES;
    }
}

int callback(const char *path, const char *matched_pathspec, void *payload) {
    NSLog(@"Hello!");
    return 0;
}

-(void)updateIndex {

    NSMutableArray *paths = [[NSMutableArray alloc]initWithCapacity:self.filesToCommit.count];
    for (GTStatusDelta *statusDelta in self.filesToCommit) {
        [paths addObject:statusDelta.newFile.path];
    }
    const git_strarray strarray = [paths git_strarray];

    GTIndex *index = [self.repo indexWithError:nil];
    int returnCode = git_index_update_all(index.git_index, &strarray, NULL, NULL);
    [index write:nil];
    NSError *secondError = nil;
    [self checkForError:returnCode error:&secondError];

}

-(void)removeFromIndex {
    NSMutableArray *paths = [[NSMutableArray alloc]initWithCapacity:self.filesToCommit.count];
    for (GTStatusDelta *statusDelta in self.filesToCommit) {
        [paths addObject:statusDelta.newFile.path];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//FIXME: Make error handling work.
-(void)addEntry:(GTStatusDelta *)statusDelta builder:(GTTreeBuilder *)builder error:(NSError **)error {
    NSURL *fileURL = [NSURL fileURLWithPath:[self.repo.fileURL.path stringByAppendingPathComponent:statusDelta.newFile.path]];
    NSString *fileText = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [fileText dataUsingEncoding:NSUTF8StringEncoding];
    
    [builder addEntryWithOID:statusDelta.newFile.OID fileName:statusDelta.newFile.path fileMode:GTFileModeBlob error:error];
    [builder addEntryWithData:data fileName:statusDelta.newFile.path fileMode:GTFileModeBlob error:error];
    
}

-(void)removeEntry:(GTStatusDelta *)statusDelta builder:(GTTreeBuilder *)builder error:(NSError **)error {
    [builder removeEntryWithFileName:statusDelta.newFile.path error:error];
}



@end

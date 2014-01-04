//
//  IDTRepositoryTableViewController.m
//  Git!
//
//  Created by E&Z Pierson on 7/18/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTRepositoryTableViewController.h"
#import "IDTGitDirectory.h"
#import "ObjectiveGit.h"
#import "IDTFileViewController.h"
#import "NSError+AlertView.h"
@interface IDTRepositoryTableViewController ()
@end

@implementation IDTRepositoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];
    self.gitDirectories = [[NSMutableArray alloc]initWithCapacity:10];
    NSArray *array = [self arrayOfFoldersInFolder:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]];
    for (NSString *folder in array) {
        NSString *path = [NSString stringWithFormat:@"/Documents/%@",folder];
        IDTGitDirectory *gitDirectory = [[IDTGitDirectory alloc]initWithGitDirectoryURL:[NSURL fileURLWithPath:path]];
        if (gitDirectory) {
            [self.gitDirectories addObject:gitDirectory];
        }
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewRepo:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.gitDirectories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cellReuseRepo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IDTGitDirectory *gitDirectory = self.gitDirectories[indexPath.row];
    cell.textLabel.text = gitDirectory.name;
    
    return cell;
}
-(NSArray *)arrayOfFoldersInFolder:(NSString *)folder {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray* files = [fileManager contentsOfDirectoryAtPath:folder error:nil];
	NSMutableArray *directoryList = [NSMutableArray arrayWithCapacity:10];
    
	for(NSString *file in files) {
		NSString *path = [folder stringByAppendingPathComponent:file];
		BOOL isDir = NO;
		[fileManager fileExistsAtPath:path isDirectory:(&isDir)];
		if(isDir) {
			[directoryList addObject:file];
		}
	}
    
	return directoryList;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        IDTGitDirectory *gitDirectory = self.gitDirectories[indexPath.row];
        if ([self.gitDirectories containsObject:gitDirectory]) {
            [self.gitDirectories removeObject:gitDirectory];
            NSError *error = nil;
            [gitDirectory delete:&error];
            if (error) {
                [error showErrorInAlertView];
            } else {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

#pragma mark - Navigation

-(void)createNewRepo:(id)sender {
    [self performSegueWithIdentifier:@"segueToCreateRepo" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToFiles"]) {
        IDTFileViewController *fileVC = [segue destinationViewController];
        IDTGitDirectory *gitDirectory = self.gitDirectories[[self.tableView indexPathForSelectedRow].row];
        fileVC.gitDirectory = gitDirectory;
        
    } else if ([segue.identifier isEqualToString:@"segueToCreateRepo"]) {
        
    }
    
}

@end

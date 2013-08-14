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
#import <IDTFileViewController.h>
@interface IDTRepositoryTableViewController ()
@end

@implementation IDTRepositoryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.gitDirectories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellReuseRepo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IDTGitDirectory *gitDirectory = [self.gitDirectories objectAtIndex:indexPath.row];
    cell.textLabel.text = gitDirectory.name;
    return cell;
}
-(NSArray*)arrayOfFoldersInFolder:(NSString*) folder {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray* files = [fm contentsOfDirectoryAtPath:folder error:nil];
	NSMutableArray *directoryList = [NSMutableArray arrayWithCapacity:10];
    
	for(NSString *file in files) {
		NSString *path = [folder stringByAppendingPathComponent:file];
		BOOL isDir = NO;
		[fm fileExistsAtPath:path isDirectory:(&isDir)];
		if(isDir) {
			[directoryList addObject:file];
		}
	}
    
	return directoryList;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        IDTGitDirectory *gitObject = [self.gitDirectories objectAtIndex:indexPath.row];
        [self.gitDirectories removeObject:gitObject];
        [gitObject delete];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToFiles"]) {
        IDTFileViewController *fileVC = [segue destinationViewController];
        IDTGitDirectory *gitDirectory = [self.gitDirectories objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        fileVC.gitDirectory = gitDirectory;
        
    } else if ([segue.identifier isEqualToString:@"seugeToCreateRepo"]) {
        
    }
    
}

-(void)createNewRepo:(id)sender {
    [self performSegueWithIdentifier:@"seugeToCreateRepo" sender:self];
}

@end

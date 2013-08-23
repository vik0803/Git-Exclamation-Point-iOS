//
//  IDTFileViewController.m
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTFileViewController.h"
#import "IDTGitObject.h"
#import "IDTFileEditViewController.h"
@interface IDTFileViewController () <UIAlertViewDelegate>
//This is only used for the creation of a new file and nothing else. DO NOT USE.
@end

@implementation IDTFileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewFile:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.gitDirectory.gitObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IDTGitObject *gitObject = [self.gitDirectory.gitObjects objectAtIndex:indexPath.row];
    cell.textLabel.text = gitObject.name;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IDTGitObject *gitObject = self.gitDirectory.gitObjects[indexPath.row];
    if (gitObject.directory) {
        [self performSegueWithIdentifier:@"goDeeper" sender:self];
    } else {
        [self performSegueWithIdentifier:@"segueToEditFile" sender:self];
    }
}
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"segueToEditFile"]) {
        IDTFileEditViewController *fileEditVC = [segue destinationViewController];
        fileEditVC.gitFile = self.gitDirectory.gitObjects[[self.tableView indexPathForSelectedRow].row];
    } else if ([segue.identifier isEqualToString:@"goDeeper"]) {
        IDTFileViewController *fileVC = [segue destinationViewController];
        fileVC.gitDirectory = self.gitDirectory.gitObjects[[self.tableView indexPathForSelectedRow].row];
       // self.gitDirectory = nil;
    }
}


-(void)createNewFile:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New File" message:@"Create A New File" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create File",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *fileName = [alertView textFieldAtIndex:0].text;
        NSURL *fileURL = [NSURL fileURLWithPath:[self.gitDirectory.repo.fileURL.path stringByAppendingPathComponent:fileName]];
        IDTGitFile *gitFile = [IDTGitFile createWithURL:fileURL andRepo:self.gitDirectory.repo];
        [self.gitDirectory.gitObjects insertObject:gitFile atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
 if (editingStyle == UITableViewCellEditingStyleDelete) {
     IDTGitObject *gitObject = [self.gitDirectory.gitObjects objectAtIndex:indexPath.row];
     BOOL success = [gitObject delete];
     if (success) {
         [self.gitDirectory.gitObjects removeObject:gitObject];
         [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     } else {
         NSLog(@"PANIC");
     }
    }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
     [self.tableView reloadData];
    }
 }

@end

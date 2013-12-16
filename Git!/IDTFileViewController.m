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

@interface IDTFileViewController ()
// The gitFile passed into fileEditViewController. We check this variable every time a segue is requested by the user to make sure we're not making a duplicate segue.
@property (nonatomic, strong) IDTGitFile *displayFile;

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
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewFile:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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
    IDTGitObject *gitObject = self.gitDirectory.gitObjects[indexPath.row];
    if (!gitObject.isDirectory) {
        IDTGitFile *gitFile =  (IDTGitFile *)gitObject;
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:gitFile.name attributes:@{NSForegroundColorAttributeName:[gitFile colorFromStatus]}];
        cell.textLabel.attributedText = attributedString;
    } else {
        cell.textLabel.text = gitObject.name;
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IDTGitObject *gitObject = self.gitDirectory.gitObjects[indexPath.row];

    if (gitObject.directory) {
        [self performSegueWithIdentifier:@"goDeeper" sender:self];
    } else {
        // Make sure we're segueing to a different file not the same.
        if (![self.displayFile isEqual:self.gitDirectory.gitObjects[[self.tableView indexPathForSelectedRow].row]]) {
            [self performSegueWithIdentifier:@"segueToEditFile" sender:self];
        }
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"segueToEditFile"]) {
        IDTFileEditViewController *fileEditVC = [segue destinationViewController];
        fileEditVC.gitFile = self.gitDirectory.gitObjects[[self.tableView indexPathForSelectedRow].row];
        self.displayFile = self.gitDirectory.gitObjects[[self.tableView indexPathForSelectedRow].row];
    } else if ([segue.identifier isEqualToString:@"goDeeper"]) {
        IDTFileViewController *fileVC = [segue destinationViewController];
        fileVC.gitDirectory = self.gitDirectory.gitObjects[[self.tableView indexPathForSelectedRow].row];
    }
}

-(void)createNewFile:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"New File" message:@"Create a New File" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create File",nil];
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
        IDTGitObject *gitObject = self.gitDirectory.gitObjects[indexPath.row];
        NSError *error = nil;
        BOOL success = [gitObject delete:&error];
        if (success) {
             [self.gitDirectory.gitObjects removeObject:gitObject];
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error Deleting" message:[error description] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alertView show];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
         [self.tableView reloadData];
    }
}

@end

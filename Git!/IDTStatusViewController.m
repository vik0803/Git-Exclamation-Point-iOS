//
//  IDTStatusViewController.m
//  Git!
//
//  Created by E&Z Pierson on 10/13/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTStatusViewController.h"

@interface IDTStatusViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation IDTStatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    /* TODO: Remove this line of code in favor of in view-editing. (as opposed to the current approch which makes descisons rest solely on the opinion of IDTChooseCollectionViewController.) */
    self.tableView.allowsSelection = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.statusDeltas.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commitingCells"];
    GTStatusDelta *statusDelta = self.statusDeltas[indexPath.row];
    cell.textLabel.text = [statusDelta.newFile.path lastPathComponent];
    
    return cell;
}

@end

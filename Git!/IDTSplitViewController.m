//
//  IDTSplitViewController.m
//  new-new-Text-Editor
//
//  Created by E&Z Pierson on 4/29/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTSplitViewController.h"
#import "IDTFileEditViewController.h"
@interface IDTSplitViewController () <UISplitViewControllerDelegate>

@end

@implementation IDTSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SplitView

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
}

@end

//
//  IDTFileEditViewController.h
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDTGitFile.h"
@interface IDTFileEditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic,strong) IDTGitFile *gitFile;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *commitFile;

//This is called by the appDelegate.
-(void)closeDocument;
//This is called by the appDelegate.
-(void)openDocument;

@end

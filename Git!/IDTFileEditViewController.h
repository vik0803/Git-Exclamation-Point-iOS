//
//  IDTFileEditViewController.h
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDTGitObject.h"
@interface IDTFileEditViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@property (nonatomic,strong) IDTGitObject *gitObject;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *commitFile;

//This is called by the appDelagte.
-(void)closeDocument;

@end

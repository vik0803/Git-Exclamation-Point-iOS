//
//  IDTDiffViewController.h
//  Git!
//
//  Created by E&Z Pierson on 7/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"
#import "IDTGitObject.h"
@interface IDTDiffViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *changedTextView;
@property (weak, nonatomic) IBOutlet UITextView *unchangedTextVew;
@property (nonatomic,strong) IDTGitObject *gitObject;


- (IBAction)commitChanges:(id)sender;
- (IBAction)cancel:(id)sender;
@end

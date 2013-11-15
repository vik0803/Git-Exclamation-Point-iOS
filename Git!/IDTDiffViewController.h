//
//  IDTDiffViewController.h
//  Git!
//
//  Created by E&Z Pierson on 7/2/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveGit.h"
#import "IDTGitFile.h"
@interface IDTDiffViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *newTextView __attribute__((ns_returns_not_retained));
@property (nonatomic, weak) IBOutlet UITextView *oldTextView;

@property (nonatomic, strong) GTStatusDelta *statusDelta;

@property (nonatomic, strong) GTRepository *repo;

@end

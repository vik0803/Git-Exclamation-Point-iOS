//
//  IDTGitModel.h
//  Git!
//
//  Created by E&Z Pierson on 7/15/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveGit.h"
#import "IDTGitObject.h"
//A 'gitDirectory' is an object that is a folder. It means that the folder is tracked under 
@interface IDTGitDirectory : NSObject
@property (nonatomic,strong) GTRepository *repo;
@property (nonatomic,strong) NSMutableArray *gitObjects;
@property (nonatomic,strong) NSString *name;

-(instancetype)initWithGitDirectoryURL:(NSURL *)directoryURL;
-(instancetype)initWithRepo:(GTRepository *)repo;
-(BOOL)delete;
@end

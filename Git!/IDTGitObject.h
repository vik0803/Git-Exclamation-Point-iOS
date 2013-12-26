//
//  IDTGitObject.h
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveGit.h"
#import "IDTDocument.h"
//This is a abstract superclass for file system objects that are in managed by Git.
@interface IDTGitObject : NSObject

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) GTRepository *repo;

//This is set by the subclass.
@property (nonatomic, getter = isDirectory) BOOL directory;

-(instancetype)initWithObjectURL:(NSURL *)objectURL;

-(BOOL)delete:(NSError **)error;

-(NSString *)description;

@end

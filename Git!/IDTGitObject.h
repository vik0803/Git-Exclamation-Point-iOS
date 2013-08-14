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
@interface IDTGitObject : NSObject

@property (nonatomic,strong) IDTDocument *document;
@property (nonatomic) GTRepositoryFileStatus gitStatus;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) GTRepository *repo;
@property (nonatomic) BOOL directory;

-(instancetype)initWithFileURL:(NSURL *)fileURL gitRepo:(GTRepository *)repo;

-(BOOL)delete;

-(NSString *)description;

@end

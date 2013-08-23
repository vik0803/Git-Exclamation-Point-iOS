//
//  IDTGitFile.h
//  Git!
//
//  Created by E&Z Pierson on 8/21/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitObject.h"

@interface IDTGitFile : IDTGitObject

@property (nonatomic,strong) IDTDocument *document;
@property (nonatomic) GTRepositoryFileStatus gitStatus;

-(instancetype)initWithFileURL:(NSURL *)fileURL gitRepo:(GTRepository *)repo;

+(instancetype)createWithURL:(NSURL *)fileURL andRepo:(GTRepository *)repo;

@end

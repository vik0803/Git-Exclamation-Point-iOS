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
//This is a semi-abstract superclass. It's semi because you will actually use this object in client use but you will never cast to it.
@interface IDTGitObject : NSObject

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) GTRepository *repo;

//This is set by the subclass.
@property (nonatomic, getter = isDirectory) BOOL directory;

-(instancetype)initWithObjectURL:(NSURL *)objectURL;

-(BOOL)delete:(NSError **)error;

-(NSString *)description;

@end

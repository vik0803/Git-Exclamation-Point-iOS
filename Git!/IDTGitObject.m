//
//  IDTGitObject.m
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitObject.h"

@implementation IDTGitObject

-(instancetype)initWithObjectURL:(NSURL *)objectURL  {
    self = [super init];
    if (!self) return nil;
    self.name = [objectURL lastPathComponent];
    return self;
}


-(BOOL)delete {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"The Name is %@ \r The repo is %@ \r Is It a Directory? %d ",self.name,self.repo,self.directory];
}


@end

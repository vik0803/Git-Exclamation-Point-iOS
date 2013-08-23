//
//  IDTGitFile.m
//  Git!
//
//  Created by E&Z Pierson on 8/21/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitFile.h"

@implementation IDTGitFile
-(instancetype)initWithFileURL:(NSURL *)fileURL gitRepo:(GTRepository *)repo {
    NSParameterAssert(repo!=nil);
    NSParameterAssert(fileURL!=nil);
    self = [super initWithObjectURL:fileURL];
    if (!self) return nil;
    self.directory = NO;
    self.repo = repo;
    self.document = [[IDTDocument alloc]initWithFileURL:fileURL];
        
    return self;
}



-(BOOL)delete {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtURL:self.document.fileURL error:Nil]) {
        return YES;
    }
    return NO;
}


-(NSString *)description {
    return [NSString stringWithFormat:@"The document is %@ \r The Name is %@ \r The gitStatus is %d \r and The repo is %@ ",self.document,self.name,self.gitStatus,self.repo];
}
-(GTRepositoryFileStatus)gitStatus {
    GTRepositoryFileStatus status = 0;
    [self.repo enumerateFileStatusUsingBlock:^(NSURL *statusFileURL, GTRepositoryFileStatus status, BOOL *stop) {
        if ([statusFileURL isEqual:self.document.fileURL]) {
            status = status;
        }
    }];
    return status;
}

+(instancetype)createWithURL:(NSURL *)fileURL andRepo:(GTRepository *)repo {
    if (![[NSFileManager defaultManager]createFileAtPath:fileURL.path contents:nil attributes:nil]) return nil;

    return [[IDTGitFile alloc]initWithFileURL:fileURL gitRepo:repo];

}



@end

//
//  IDTGitObject.m
//  Git!
//
//  Created by E&Z Pierson on 6/30/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitObject.h"

@implementation IDTGitObject
-(instancetype)initWithFileURL:(NSURL *)fileURL gitRepo:(GTRepository *)repo {
    NSParameterAssert(repo!=nil);
    NSParameterAssert(fileURL!=nil);
    self = [super init];
    if (self) {
        NSStringEncoding encoding = NSUnicodeStringEncoding;
        NSError *error = nil;
        NSString *fileContents = [NSString stringWithContentsOfFile:fileURL.path usedEncoding:&encoding error:&error];
        fileContents = Nil;
        NSNumber *isDirectory = 0;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:Nil];
        if ([isDirectory boolValue]) {
            return nil;
        }
        if (error && ![isDirectory boolValue]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager createFileAtPath:fileURL.path contents:Nil attributes:Nil]) return nil;
        }
        self.document = [[IDTDocument alloc]initWithFileURL:fileURL];
        self.name = self.document.name;
        self.repo = repo;
        [self.repo enumerateFileStatusUsingBlock:^(NSURL *statusFileURL, GTRepositoryFileStatus status, BOOL *stop) {
            if ([statusFileURL isEqual:self.document.fileURL]) {
                self.gitStatus = status;
            }
        }];
    
    
    }
    
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


@end

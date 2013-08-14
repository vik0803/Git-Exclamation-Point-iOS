//
//  IDTGitModel.m
//  Git!
//
//  Created by E&Z Pierson on 7/15/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitDirectory.h"
@interface IDTGitDirectory ()
@property (nonatomic,strong) NSURL *directoryURL;
@end
@implementation IDTGitDirectory
-(instancetype)initWithGitDirectoryURL:(NSURL *)specificDirectoryURL {
    self = [super init];
    if (self) {
        NSError *error = nil;
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:specificDirectoryURL.path]];
        self.directoryURL = directoryURL;
        self.repo = [[GTRepository alloc]initWithURL:directoryURL error:&error];
        if (self.repo == nil || error != nil) return nil;
        self.name = [self.repo.fileURL lastPathComponent];
        self.gitObjects = [self enumerateGitObjectsURL:self.repo.fileURL];
        
    }

    return self;
}

-(instancetype)initWithRepo:(GTRepository *)repo {
    self = [super init];
    if (self == nil) return nil;
    self.repo = repo;
    self.directoryURL = repo.fileURL;
    if (self.repo == nil) {
        return nil;
    }
    self.name = [self.repo.fileURL lastPathComponent];
    self.gitObjects = [self enumerateGitObjectsURL:self.repo.fileURL];

    return self;
}
//an internal initlizer that may be opend up...
-(instancetype)initWithGitDirectoryURL:(NSURL *)directoryURL repo:(GTRepository *)repo {
    self = [super init];
    if (self) {
        self.directoryURL = directoryURL;
        self.name = [directoryURL lastPathComponent];
        self.repo = repo;
        self.gitObjects = [self enumerateGitObjectsURL:directoryURL];
    }
    
    return self;
}


-(NSMutableArray *)enumerateGitObjectsURL:(NSURL *)dirURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [fileManager contentsOfDirectoryAtURL:dirURL includingPropertiesForKeys:nil options:0 error:&error];
    if (error) {
        NSLog(@"error is %@",error);
    }
    NSMutableArray *objects = [[NSMutableArray alloc]init];
    for (NSURL *fileURL in array) {
        IDTGitObject *gitObject = [[IDTGitObject alloc]initWithFileURL:fileURL gitRepo:self.repo];
        if (gitObject == nil) {
            IDTGitDirectory *gitDirectory = [[IDTGitDirectory alloc]initWithGitDirectoryURL:fileURL repo:self.repo];
            [objects addObject:gitDirectory];
        } else {
            [objects addObject:gitObject];
        }
    }
    return objects;
}

-(BOOL)delete {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL sucess = [fileManager removeItemAtURL:self.directoryURL error:&error];
    if (error) {
        NSLog(@"error is %@",error);
        sucess = NO;
    }
    
    return sucess;
}

@end

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
    self = [super initWithObjectURL:specificDirectoryURL];
    if (self) {
        NSError *error = nil;
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:specificDirectoryURL.path]];
        self.directoryURL = directoryURL;
        self.repo = [[GTRepository alloc]initWithURL:directoryURL error:&error];
        if (self.repo == nil || error != nil) return nil;
        self.directory = YES;
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
    self.directory = YES;
    self.gitObjects = [self enumerateGitObjectsURL:self.repo.fileURL];

    return self;
}
-(instancetype)initWithSumbmodule:(GTSubmodule *)submodule {
    self = [super init];
    if (self == nil) return nil;

    return self;
}
//an internal initlizer that may be opend up...
-(instancetype)initWithGitDirectoryURL:(NSURL *)directoryURL repo:(GTRepository *)repo {
    self = [super initWithObjectURL:directoryURL];
    if (self) {
        self.directoryURL = directoryURL;
        self.repo = repo;
            self.directory = YES;
        self.gitObjects = [self enumerateGitObjectsURL:directoryURL];
    }
    
    return self;
}


-(NSMutableArray *)enumerateGitObjectsURL:(NSURL *)dirURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [fileManager contentsOfDirectoryAtURL:dirURL includingPropertiesForKeys:nil options:0 error:&error];
    if (error) NSLog(@"error is %@",error);
    
    NSMutableArray *objects = [[NSMutableArray alloc]initWithCapacity:array.count];
    for (NSURL *objectURL in array) {
        if (![self isDirectoryURL:objectURL]) {
            IDTGitFile *file = [[IDTGitFile alloc]initWithFileURL:objectURL gitRepo:self.repo];
            [objects addObject:file];
        } else {
            IDTGitDirectory *directory = [[IDTGitDirectory alloc]initWithGitDirectoryURL:objectURL repo:self.repo];
            [objects addObject:directory];
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


+(IDTGitDirectory *)cloneWithName:(NSString *)name URL:(NSURL *)url barely:(BOOL)bare checkout:(BOOL)checkout error:(NSError **)error {
    IDTGitDirectory *gitDirectory = nil;
    NSError *gitSpecificError = nil;
    NSString *nameString = [NSString stringWithFormat:@"Documents/%@",name];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:nameString]];
    
    GTRepository *repo = [GTRepository cloneFromURL:url toWorkingDirectory:fileURL barely:bare withCheckout:checkout error:&gitSpecificError transferProgressBlock:^(const git_transfer_progress *transferProgress) {
       
    } checkoutProgressBlock:^(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
        NSLog(@"does this work? %d and %d",completedSteps,totalSteps);
    }];
    
    if (gitSpecificError) {
        if (error !=NULL) *error = gitSpecificError;
        return nil;
    } else {
        gitDirectory = [[IDTGitDirectory alloc]initWithRepo:repo];
        return gitDirectory;
    }
}

-(void)downloadSubmodules {
    [self.repo enumerateSubmodulesRecursively:YES usingBlock:^(GTSubmodule *submodule, BOOL *stop) {
        NSError *error = nil;
        [submodule writeToParentConfigurationDestructively:NO error:&error];
        if (!error) {

        }else {
            NSLog(@"Error is %@",error);

        }
    }];
}



-(BOOL)isDirectoryURL:(NSURL *)objectURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    [fileManager fileExistsAtPath:objectURL.path isDirectory:&isDirectory];
    return isDirectory;
}


@end

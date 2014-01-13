//
//  IDTGitModel.m
//  Git!
//
//  Created by E&Z Pierson on 7/15/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitDirectory.h"

NSString * const IDTDownloadStatusDidChange = @"IDTDownloadStatusDidChange";

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
-(instancetype)initWithSubmodule:(GTSubmodule *)submodule {
    self = [super init];
    if (self == nil) return nil;

    return self;
}
//an internal initializer that may be exposed.
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

-(BOOL)delete:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtURL:self.directoryURL error:error];
    
    if (error) {
        NSLog(@"error is %@",*error);
        success = NO;
    }
    
    return success;
}

+ (void)cloneWithName:(NSString *)name URL:(NSURL *)url barely:(BOOL)bare checkout:(BOOL)checkout error:(NSError **)error completion:(void (^)(IDTGitDirectory *gitDirectory, BOOL success, NSError *error))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block IDTGitDirectory *gitDirectory = nil;
        NSError *gitSpecificError = nil;
        NSString *nameString = [NSString stringWithFormat:@"Documents/%@",name];
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:nameString]];
        NSDictionary *options = @{GTRepositoryCloneOptionsTransportFlags:@(1), GTRepositoryCloneOptionsCheckout :@(checkout), GTRepositoryCloneOptionsBare:@(bare) };
        GTRepository *repo = [GTRepository cloneFromURL:url toWorkingDirectory:directoryURL options:options error:&gitSpecificError transferProgressBlock:^void(const git_transfer_progress *transfer_progress) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString *status = [NSString stringWithFormat:@"Received %d objects and indexed %d out of  a total of %d",transfer_progress->received_objects,transfer_progress->indexed_objects,transfer_progress->total_objects];
                [[NSNotificationCenter defaultCenter]postNotificationName:IDTDownloadStatusDidChange object:status];
            });
        } checkoutProgressBlock:^void(NSString *path, NSUInteger completedSteps, NSUInteger totalSteps) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString *status = [NSString stringWithFormat:@"Checking out Path %@. \n Completed %lu out of %lu",path,(unsigned long)completedSteps,(unsigned long)totalSteps];
                [[NSNotificationCenter defaultCenter]postNotificationName:IDTDownloadStatusDidChange object:status];
            });
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            gitDirectory = [[IDTGitDirectory alloc]initWithRepo:repo];
            if (*error != NULL) *error = gitSpecificError;
            completionBlock(gitDirectory,(gitDirectory != nil ? YES : NO),*error);
        });
    });
}

- (BOOL)initializeSubmodulesError:(NSError **)error {
    [self.repo enumerateSubmodulesRecursively:NO usingBlock:^(GTSubmodule *submodule, BOOL *stop) {
        NSError *submoduleError = nil;
        [submodule writeToParentConfigurationDestructively:YES error:&submoduleError];
        if (!submoduleError) {
            [IDTGitDirectory cloneWithName:submodule.URLString.lastPathComponent URL:[NSURL URLWithString:submodule.URLString] barely:NO checkout:YES error:NULL completion:^(IDTGitDirectory *gitDirectory, BOOL success, NSError *error) {
                
            }];
            if (*error) {
                NSLog(@"error is %@",*error);
            }
        } else {
            
        }
    }];
    return YES;
}

-(BOOL)isDirectoryURL:(NSURL *)objectURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    [fileManager fileExistsAtPath:objectURL.path isDirectory:&isDirectory];
    return isDirectory;
}

@end

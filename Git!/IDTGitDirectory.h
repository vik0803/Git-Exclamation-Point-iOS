//
//  IDTGitModel.h
//  Git!
//
//  Created by E&Z Pierson on 7/15/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveGit.h"
#import "IDTGitObject.h"
#import <IDTGitFile.h>

extern NSString * const IDTDownloadStatusDidChange;
//A 'gitDirectory' is an object that is a folder. It means that the folder is tracked under Git.
@interface IDTGitDirectory : IDTGitObject

@property (nonatomic,strong) NSMutableArray *gitObjects;

- (instancetype)initWithGitDirectoryURL:(NSURL *)directoryURL;

- (instancetype)initWithRepo:(GTRepository *)repo;

- (BOOL)delete:(NSError **)error;

+ (void)cloneWithName:(NSString *)name URL:(NSURL *)url barely:(BOOL)bare checkout:(BOOL)checkout error:(NSError **)error completion:(void (^)(IDTGitDirectory *gitDirectory, BOOL success, NSError *error))completionBlock;

@end

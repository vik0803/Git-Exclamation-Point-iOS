//
//  IDTCommitHelper.m
//  Git!
//
//  Created by E&Z Pierson on 11/28/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTTreeCreator.h"
#import "ObjectiveGit.h"
#import "NSError+AlertView.h"
#import "git2/pathspec.h"
#import "ObjectiveGit/NSArray+StringArray.h"
#import "IDTTreeWriter.h"

@interface IDTTreeCreator ()

@property (nonatomic, strong) GTRepository *repo;

@end

@implementation IDTTreeCreator

- (instancetype)initWithRepository:(GTRepository *)repo {
    self = [super init];
    if (self == nil) return nil;
    self.repo = repo;
    
    return self;
}

- (GTTree *)initialCommit:(NSError **)error {
    NSAssert(self.repo.HEADUnborn == YES, @"Error: you can only create an initial commit when the HEAD is unborn.");
    
    GTIndex *index = [self.repo indexWithError:error];
    [index updatePathspecs:nil error:error passingTest:nil];
    GTTree *tree = [index writeTree:error];
    
    return tree;
}


- (GTTree *)commitFiles:(NSArray *)files error:(NSError **)error {
    if (self.repo.HEADUnborn) {
        return [self initialCommit:error];
    }
    
    BOOL success = NO;
    GTTree *tree = [self writeSelectedChangesToTree:files success:&success error:error];
    if (!success) {
        NSLog(@"Error is %@",*error);
        return nil;
    }
    
    GTIndex *index = [self.repo indexWithError:error];
    NSMutableArray *pathspecs = [[NSMutableArray alloc]initWithCapacity:files.count];
    for (GTStatusDelta *statusDelta in files) {
        [pathspecs addObject:statusDelta.newFile.path];
    }
    
    [index updatePathspecs:pathspecs error:error passingTest:^(NSString *matchedPathspec, NSString *path, BOOL *stop) {
        NSLog(@"path is %@",path);
        return YES;
    }];
    [index write:error];

    if (error) {
        if (*error) return nil;
    }
    
    return tree;
}

- (GTTree *)writeSelectedChangesToTree:(NSArray *)files success:(BOOL *)success error:(NSError **)error {
    NSError *internalError = nil;
    GTBranch *branch  = [self.repo currentBranchWithError:&internalError];
    GTCommit *commit = [self.repo lookUpObjectByRevParse:branch.reference.name error:&internalError];
    GTTree *tree = commit.tree;
   
    for (GTStatusDelta *statusDelta in files) {
        switch (statusDelta.status) {
            case GTStatusDeltaStatusModified: {
                tree = [self addEntry:statusDelta tree:tree error:&internalError];
                break;
            }
            case GTStatusDeltaStatusAdded: {
                tree = [self addEntry:statusDelta tree:tree error:&internalError];
                break;
            }
            case GTStatusDeltaStatusDeleted: {
                tree = [self removeEntry:statusDelta tree:tree error:&internalError];
                break;
            }
            default: {
                NSString *description = [NSString stringWithFormat:@"Error: trying to commit file with unimplemented status type: %u",statusDelta.status];
                internalError = [NSError errorWithDomain:@"IDTGitError" code:12 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(description, @"")}];
                break;
            }
        }
    }
    
    if (internalError != nil) {
        if(success != nil) *success = NO;
        if (error) *error = internalError;
    } else {
        if(success != nil) *success = YES;
    }

    return tree;
}

- (GTTree *)addEntry:(GTStatusDelta *)statusDelta tree:(GTTree *)tree error:(NSError **)error {
    NSMutableArray *treeWriters = [NSMutableArray array];
    IDTTreeWriter *initialWriter = [[IDTTreeWriter alloc]initWithTree:tree parent:nil name:@"" written:NO];
    [treeWriters addObject:initialWriter];
    
    for (NSString *name in statusDelta.newFile.path.pathComponents) {
        GTTreeEntry *entry = [tree entryWithName:name];
        if (entry.type == GTObjectTypeTree) {
            tree = (GTTree *)[entry GTObject:error];
            IDTTreeWriter *writer = [[IDTTreeWriter alloc]initWithTree:tree parent:[treeWriters lastObject] name:entry.name written:NO];
            
            [treeWriters addObject:writer];
        }
        
        if (entry.type == GTObjectTypeBlob) {
            IDTTreeWriter *treeWriter = [treeWriters lastObject];
            GTTreeBuilder *subBuilder = [[GTTreeBuilder alloc]initWithTree:treeWriter.tree error:error];
            [subBuilder addEntryWithOID:statusDelta.newFile.OID fileName:entry.name fileMode:GTFileModeBlob error:error];

            treeWriter.tree = [subBuilder writeTreeToRepository:self.repo error:error];
            treeWriter.written = YES;
            tree = [treeWriter recurse:error];
        }
    }

    return tree;
}

- (GTTree *)removeEntry:(GTStatusDelta *)statusDelta tree:(GTTree *)tree error:(NSError **)error {
    NSMutableArray *treeWriters = [NSMutableArray array];
    IDTTreeWriter *initialWriter = [[IDTTreeWriter alloc]initWithTree:tree parent:nil name:@"" written:NO];
    [treeWriters addObject:initialWriter];
    
    for (NSString *name in statusDelta.newFile.path.pathComponents) {
        GTTreeEntry *entry = [tree entryWithName:name];
        
        if (entry.type == GTObjectTypeTree) {
            tree = (GTTree *)[entry GTObject:error];
            IDTTreeWriter *writer = [[IDTTreeWriter alloc]initWithTree:tree parent:[treeWriters lastObject] name:entry.name written:NO];
            [treeWriters addObject:writer];
        }
        
        if (entry.type == GTObjectTypeBlob) {
            IDTTreeWriter *writer = [treeWriters lastObject];
            GTTreeBuilder *subBuilder = [[GTTreeBuilder alloc]initWithTree:writer.tree error:error];
            [subBuilder removeEntryWithFileName:entry.name error:error];
            
            writer.tree = [subBuilder writeTreeToRepository:self.repo error:error];
            writer.written = YES;
            tree = [writer recurse:error];
        }
    }

    return tree;
}

@end

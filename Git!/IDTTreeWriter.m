//
//  IDTCommitWriter.m
//  Git!
//
//  Created by E&Z Pierson on 2/10/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

#import "IDTTreeWriter.h"

@implementation IDTTreeWriter

- (instancetype)initWithTree:(GTTree *)tree parent:(IDTTreeWriter *)parent name:(NSString *)name written:(BOOL)isWritten {
    self = [super init];
    if (self == nil) return nil;
    
    _tree = tree;
    _builder = [[GTTreeBuilder alloc]initWithTree:_tree error:nil];
    _parent = parent;
    _name = name;
    _written = isWritten;
    
    return self;
}

- (GTTree *)recurse:(NSError **)error {
    if (!self.isWritten) {
        if (*error != nil) *error = [NSError errorWithDomain:@"IDTCommitWriterError" code:-1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Calling write too early. Come back later", nil)}];
        return nil;
    }

    GTTree *tree = [IDTTreeWriter recursivelyAddAndWriteTree:self error:error];
    
    return tree;
}

+ (GTTree *)recursivelyAddAndWriteTree:(IDTTreeWriter *)commitWriter error:(NSError **)error {
    if (commitWriter.parent == nil) {
        return commitWriter.tree;
    }
    
    NSAssert(commitWriter.parent != nil, @"Failure");
    NSAssert(commitWriter != nil, @"Failure");

    GTTreeEntry *treeEntry = [commitWriter.parent.builder addEntryWithOID:commitWriter.tree.OID fileName:commitWriter.name fileMode:GTFileModeTree error:error];
    commitWriter.parent.tree = [commitWriter.parent.builder writeTreeToRepository:commitWriter.tree.repository error:error];
    GTTree *tree = [IDTTreeWriter recursivelyAddAndWriteTree:commitWriter.parent error:error];

    if (commitWriter.parent.tree == nil || treeEntry == nil) {
        return nil;
    }
    
    return tree;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p> name: %@, parent: %@, tree: %@, is written: %d, ", NSStringFromClass([self class]), self, self.name, self.parent, self.tree, self.isWritten];
}

@end

//
//  IDTCommitWriter.h
//  Git!
//
//  Created by E&Z Pierson on 2/10/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

#import "ObjectiveGit.h"
#import <Foundation/Foundation.h>

@interface IDTTreeWriter : NSObject

// Should these be private?
@property (nonatomic, strong, readonly) IDTTreeWriter *parent;

@property (nonatomic, strong) GTTree *tree;

@property (nonatomic, strong) GTTreeBuilder *builder;

@property (nonatomic, getter = isWritten) BOOL written;

@property (nonatomic, copy) NSString *name;

- (instancetype)initWithTree:(GTTree *)tree parent:(IDTTreeWriter *)parent name:(NSString *)name written:(BOOL)isWritten;

- (GTTree *)recurse:(NSError **)error;

@end

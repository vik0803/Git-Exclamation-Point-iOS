//
//  IDTTestCase.m
//  Git!
//
//  Created by E&Z Pierson on 3/18/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

#import "IDTTestCase.h"
#import "SSZipArchive.h"

@implementation IDTTestCase

- (NSURL *)fixturesURL {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"com.piersonBro.git!/fixtures"]];
}

- (NSURL *)pathForFixtureRepositoryNamed:(NSString *)name {
    return [NSURL fileURLWithPath:[self.fixturesURL.path stringByAppendingPathComponent:name]];
}

- (GTRepository *)testAppFixtureRepository {
    return [[GTRepository alloc]initWithURL:[self pathForFixtureRepositoryNamed:@"Test_App"] error:nil];
}

- (GTRepository *)bareFixtureRepository {
    return [[GTRepository alloc]initWithURL:[self pathForFixtureRepositoryNamed:@"testrepo.git"] error:nil];
}

- (GTRepository *)submoduleFixtureRepository {
    return [[GTRepository alloc]initWithURL:[self pathForFixtureRepositoryNamed:@"repo-with-submodule"] error:nil];
}

- (GTRepository *)conflictedFixtureRepository {
    return [[GTRepository alloc]initWithURL:[self pathForFixtureRepositoryNamed:@"conflicted-repo"] error:nil];
}

@end

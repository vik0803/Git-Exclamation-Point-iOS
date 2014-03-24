//
//  IDTTestCase.h
//  Git!
//
//  Created by E&Z Pierson on 3/18/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

#define SPT_SUBCLASS IDTTestCase
#import "Specta.h"

@interface IDTTestCase : SPTXCTestCase

@property (nonatomic, strong) NSURL *fixturesURL;

@property (nonatomic, strong) GTRepository *testAppFixtureRepository;

@property (nonatomic, strong) GTRepository *bareFixtureRepository;

@property (nonatomic, strong) GTRepository *submoduleFixtureRepository;

@property (nonatomic, strong) GTRepository *conflictedFixtureRepository;

@end

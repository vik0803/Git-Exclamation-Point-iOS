//
//  IDTCommitHelper.h
//  Git!
//
//  Created by E&Z Pierson on 11/28/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveGit.h"

@interface IDTTreeCreator : NSObject

// Subject to change as my whimsey takes me.
- (instancetype)initWithRepository:(GTRepository *)repo;


- (GTTree *)commitFiles:(NSArray *)files error:(NSError **)error;

@end

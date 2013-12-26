//
//  NSError+NSError_AlertView.m
//  Git!
//
//  Created by E&Z Pierson on 11/15/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "NSError+AlertView.h"

@implementation NSError (NSError_AlertView)

-(void)showErrorInAlertView {
    if (!self) {
        return;
    }
    NSLog(@"error is %@",self);
    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"Error" message:[self description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alerView show];
}

@end

//
//  IDTTestObserver.m
//  Git!
//
//  Created by E&Z Pierson on 3/20/14.
//  Copyright (c) 2014 E&Z Pierson. All rights reserved.
//

#import "IDTTestObserver.h"
#import "SSZipArchive.h"

@implementation IDTTestObserver

- (void)startObserving {
    NSString *zippedRepositoriesPath = [[NSBundle bundleForClass:self.class] pathForResource:@"fixtures" ofType:@"zip"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager createDirectoryAtURL:self.fixturesURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (!error) {
        BOOL success = [SSZipArchive unzipFileAtPath:zippedRepositoriesPath toDestination:self.fixturesURL.path];
        expect(success).to.beTruthy();
    } else {
        NSLog(@"error is %@",error);
    }
    [super startObserving];
}
- (void)stopObserving {
    [super stopObserving];
    [[NSFileManager defaultManager]removeItemAtPath:[self.fixturesURL.path stringByDeletingLastPathComponent]  error:nil];
}

// FIXME: Possible unnesscary duplication of code?
- (NSURL *)fixturesURL {
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"com.piersonBro.git!/fixtures"]];
}

@end

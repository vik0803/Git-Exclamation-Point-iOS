//
//  IDTGitFile.m
//  Git!
//
//  Created by E&Z Pierson on 8/21/13.
//  Copyright (c) 2013 E&Z Pierson. All rights reserved.
//

#import "IDTGitFile.h"
#import "NSError+AlertView.h"
@implementation IDTGitFile
-(instancetype)initWithFileURL:(NSURL *)fileURL gitRepo:(GTRepository *)repo {
    NSParameterAssert(repo!=nil);
    NSParameterAssert(fileURL!=nil);
    self = [super initWithObjectURL:fileURL];
    if (!self) return nil;
    self.directory = NO;
    self.repo = repo;
    self.document = [[IDTDocument alloc]initWithFileURL:fileURL];
        
    return self;
}
// TODO: Test this method.
+(instancetype)createWithURL:(NSURL *)fileURL andRepo:(GTRepository *)repo {
    if (![[NSFileManager defaultManager]createFileAtPath:fileURL.path contents:nil attributes:nil]) return nil;
    NSError *error = nil;
    
    GTIndex *index = [repo indexWithError:&error];
    if (error) {
        [error showErrorInAlertView];
    }
    NSString *intermediaryString = [fileURL.path stringByReplacingOccurrencesOfString:repo.fileURL.path withString:@""];
    //Cut the / at the beginning of the path.
    NSString *reletiveString = [intermediaryString substringFromIndex:1];
    [index addFile:reletiveString error:&error];
    if (error) {
        [error showErrorInAlertView];
    }
    [index write:&error];
    if (error) {
        [error showErrorInAlertView];
    }
    
    return [[IDTGitFile alloc]initWithFileURL:fileURL gitRepo:repo];
    
}
// TODO: Test this method.
-(BOOL)delete:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtURL:self.document.fileURL error:error];
    if (!success) {
        return NO;
    }
    GTIndex *index = [self.repo indexWithError:nil];
    NSString *intermediaryString = [self.document.fileURL.path stringByReplacingOccurrencesOfString:self.repo.fileURL.path withString:@""];
    //Cut the / at the beginning of the path.
    NSString *reletivePath = [intermediaryString substringFromIndex:1];
    if ([index removeFile:reletivePath error:error]) {
        [index write:nil];
        return YES;
    } else {
        return NO;
    }

}

-(NSString *)description {
    return [NSString stringWithFormat:@"The document is %@ \r The Name is %@ \r The gitStatus is %d \r and The repo is %@ ",self.document,self.name,self.gitStatus,self.repo];
}

-(GTFileStatusFlags)gitStatus {
    NSError *error = nil;
    BOOL success = 0;
    NSString *intermediaryString = [self.document.fileURL.path stringByReplacingOccurrencesOfString:self.repo.fileURL.path withString:@""];
    //Cut the / at the beginning of the path.
    NSString *reletiveString = [intermediaryString substringFromIndex:1];
    GTFileStatusFlags flags = [self.repo statusForFile:[NSURL URLWithString:reletiveString] success:&success error:&error];
    if (success) {
        return flags;
    } else {
        return 0;
    }
}

-(UIColor *)colorFromStatus {
    switch (self.gitStatus) {
        case GTFileStatusModifiedInIndex:
            return [UIColor blueColor];
            break;
        case GTFileStatusModifiedInWorktree:
            return [UIColor blueColor];
            break;
        case GTFileStatusDeletedInIndex:
            return [UIColor redColor];
            break;
        case GTFileStatusDeletedInWorktree:
            return [UIColor blueColor];
            break;
        case GTFileStatusNewInIndex:
            return [UIColor greenColor];
            break;
        case GTFileStatusNewInWorktree:
            return [UIColor greenColor];
            break;
        case GTFileStatusIgnored:
            return [UIColor lightGrayColor];
        default:
            return [UIColor blackColor];
            break;
    }
}


@end

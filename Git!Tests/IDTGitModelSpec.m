#import "Specta.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "IDTGitFile.h"

SpecBegin(IDTGitObject)

beforeEach(^{
    // TODO: Find a way to get a gitRepo in the tests.
    IDTGitFile *gitFile = [[IDTGitFile alloc]initWithFileURL:[NSURL fileURLWithPath:@"Hello!"] gitRepo:nil];
    expect(gitFile).to.beTruthy();
});

describe(@"General", ^{
    it(@"should be able to provide basic info about the file or directory", ^{

    });
});

SpecEnd

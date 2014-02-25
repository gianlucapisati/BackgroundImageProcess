//
//  BulkOperation.m
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import "BulkDownloadOperation.h"
#import "DatabaseManager.h"

@implementation BulkDownloadOperation

-(id)initWithPhoto:(Photo*)p{
    self = [super init];
    if (self)
    {
        self.photo = p;
        
        _isExecuting = NO;
        _isFinished = NO;
    }
    
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start {
    
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString* image = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"sw/www/img/%@.jpg",self.photo.id_photo]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:image];
    
    if(fileExists){
        [self finish];
    }else{
        NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"sw/www/img/%@.jpg",self.photo.id_photo]];
        NSData *thedata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://srvwsw2.vidiemme.lan:8080/serviceclient/ps/download/%@",self.photo.id_photo]]];
        [thedata writeToFile:localFilePath atomically:YES];
        
        [self finish];
    }
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    UIWebView *webview = [[UIWebView alloc] init];
    [webview stringByEvaluatingJavaScriptFromString:@"console.log('new download completed')"];
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

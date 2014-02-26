//
//  BulkOperation.m
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import "BulkDownloadOperation.h"
#import "DatabaseManager.h"
#import <Cordova/CDV.h>

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
        [self finishWithStatus:2];
    }else{
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@services/ps/download/%@",self.baseURL,self.photo.id_photo]]];
        
        NSString *authCredentials = [NSString stringWithFormat:@"%@:%@", self.username, self.token];
        [request setValue:authCredentials forHTTPHeaderField:@"Authorization"];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * response,
                                                   NSData * data,
                                                   NSError * error) {
                                   if (!error){
                                       NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"sw/www/img/%@.jpg",self.photo.id_photo]];
                                       [data writeToFile:localFilePath atomically:YES];
                                       
                                       [self finishWithStatus:1];
                                   } else {
                                       NSLog(@"ERRORE: %@", error);
                                       [self finishWithStatus:0];
                                   }
                                   
                               }];
    }
}

- (void)finishWithStatus:(int)status
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    if(status == 1 || status == 2){
        [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,%d,'download')",self.total,self.current]];
    }
    else if(status == 0)
        [self.webview stringByEvaluatingJavaScriptFromString:@"console.log('download error')"];
    
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

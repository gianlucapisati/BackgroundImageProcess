

//
//  BulkOperation.m
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import "BulkUploadOperation.h"
#import "DatabaseManager.h"

@implementation BulkUploadOperation

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
    NSLog(@"id foto %@",self.photo.id_photo);
    
    NSString *tmp = [self.photo.uri substringFromIndex:16];
    UIImage* tmpimage = [UIImage imageWithContentsOfFile:tmp];
    NSData *imageData = UIImageJPEGRepresentation(tmpimage , 90);
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/ps/upload/%@",self.baseURL,self.photo.id_photo];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSString *authCredentials = [NSString stringWithFormat:@"%@:%@", self.username, self.token];
    [request setValue:authCredentials forHTTPHeaderField:@"Authorization"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    if(returnString){
        [self finish:self.photo.id_photo];
    }
}

- (void)finish:(NSString*)id_photo
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished = YES;
    
    [DatabaseManager deletePhotoWithId:id_photo];
    
    [self.webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,%d,'upload')",self.total,self.current]];
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

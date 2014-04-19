

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

-(id)initWithDocument:(Document*)d{
    self = [super init];
    if (self)
    {
        self.Document = d;
        
        _isExecuting = NO;
        _isFinished = NO;
        _bulkUploadOperations = NO;
    }
    
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start {
    
//    if (![NSThread isMainThread])
//    {
//        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
//        return;
//    }

    dispatch_async(dispatch_get_main_queue(), ^{

        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = YES;
        [self didChangeValueForKey:@"isExecuting"];
        
    });
    
    NSLog(@"id foto %@",self.document.id_document);
    
    NSString *tmp = [self.document.uri stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
    UIImage* tmpimage = [UIImage imageWithContentsOfFile:tmp];
    NSData *imageData = UIImageJPEGRepresentation(tmpimage , 90);
    
    NSString *urlString = [NSString stringWithFormat:@"%@services/ps/upload/%@",self.baseURL,self.document.id_document];
    
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
        [self finish:self.document.id_document];
    }
}

- (void)finish:(NSString*)id_document
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"bulkUploadOperations"];
        
        _isExecuting = NO;
        _isFinished = YES;
        _bulkUploadOperations = YES;
        
        //[DatabaseManager deletePhotoWithId:id_document];
        
        [self.webview writeJavascript:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,%d,'upload')",self.total,self.current]];
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"bulkUploadOperations"];
    });
    
}

@end

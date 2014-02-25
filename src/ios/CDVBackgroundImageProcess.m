//
//  CDVBackgroundImageProcess.m
//
//
//  Created by Gianluca Pisati on 21/01/14.
//
//

#import "CDVBackgroundImageProcess.h"


@implementation CDVBackgroundImageProcess

- (void)uploadPhotos:(CDVInvokedUrlCommand *)command {
    // Retrieve the JavaScript-created date String from the CDVInvokedUrlCommand instance.
    // When we implement the JavaScript caller to this function, we'll see how we'll
    // pass an array (command.arguments), which will contain a single String.
    [DatabaseManager sharedDatabase];
    
    NSString *username  = [command.arguments objectAtIndex:0];
    NSString *token     = [command.arguments objectAtIndex:1];
    NSString *baseURL   = [command.arguments objectAtIndex:2];
    
    [self uploadAllFilesWithUsername:username andToken:token andBaseURL:baseURL];
    
    
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [[NSDictionary alloc] initWithObjectsAndKeys : @"true", @"success", nil];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)downloadPhotos:(CDVInvokedUrlCommand *)command {
    // Retrieve the JavaScript-created date String from the CDVInvokedUrlCommand instance.
    // When we implement the JavaScript caller to this function, we'll see how we'll
    // pass an array (command.arguments), which will contain a single String.
    NSString *username  = [command.arguments objectAtIndex:0];
    NSString *token     = [command.arguments objectAtIndex:1];
    NSString *baseURL   = [command.arguments objectAtIndex:2];
    
    
    [DatabaseManager sharedDatabase];
    
    [self downloadAllFilesWithUsername:username andToken:token andBaseURL:baseURL];
    
    
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [[NSDictionary alloc] initWithObjectsAndKeys : @"true", @"success", nil];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)uploadAllFilesWithUsername:(NSString *) username andToken:(NSString*) token andBaseURL:(NSString*) baseURL{
    _bulkSendArray = [DatabaseManager getPhotosForBulkUpload];
    
    _bulkUploadQueue = [[NSOperationQueue alloc] init];
    _bulkUploadQueue.name = @"bulkQueue";
    _bulkUploadQueue.MaxConcurrentOperationCount = 2;
    
    for(Photo *p in _bulkSendArray){
        BulkUploadOperation *newOperation = [[BulkUploadOperation alloc] initWithPhoto:p];
        newOperation.username = username;
        newOperation.token = token;
        newOperation.baseURL = baseURL;
        [_bulkUploadQueue addOperation:newOperation];
    }
    [_bulkUploadQueue addObserver:self forKeyPath:@"bulkUploadOperations" options:0 context:NULL];
}


- (void)downloadAllFilesWithUsername:(NSString *) username andToken:(NSString*) token andBaseURL:(NSString*) baseURL{
    _bulkDownloadArray = [DatabaseManager getPhotosForBulkDownload];
    
    _bulkDownloadQueue = [[NSOperationQueue alloc] init];
    _bulkDownloadQueue.name = @"bulkQueue";
    _bulkDownloadQueue.MaxConcurrentOperationCount = 2;
    
    for(Photo *p in _bulkDownloadArray){
        BulkDownloadOperation *newOperation = [[BulkDownloadOperation alloc] initWithPhoto:p];
        newOperation.username = username;
        newOperation.token = token;
        newOperation.baseURL = baseURL;
        [_bulkDownloadQueue addOperation:newOperation];
    }
    [_bulkDownloadQueue addObserver:self forKeyPath:@"bulkDownloadOperations" options:0 context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == _bulkUploadQueue && [keyPath isEqualToString:@"bulkUploadOperations"]) {
        if ([_bulkUploadQueue.operations count] == 0) {
            UIWebView *webview = [[UIWebView alloc] init];
            [webview stringByEvaluatingJavaScriptFromString:@"alert('upload completed')"];
        }
    }else if(object == _bulkDownloadQueue && [keyPath isEqualToString:@"bulkDownloadOperations"]){
        if ([_bulkDownloadQueue.operations count] == 0) {
            UIWebView *webview = [[UIWebView alloc] init];
            [webview stringByEvaluatingJavaScriptFromString:@"alert('download completed')"];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

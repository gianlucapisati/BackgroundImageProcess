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


- (void)downloadDocuments:(CDVInvokedUrlCommand *)command {
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
    if([_bulkSendArray count]>0){
        [self writeJavascript:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,0,'upload')",[_bulkSendArray count]]];
    }
    _bulkUploadQueue = [[NSOperationQueue alloc] init];
    _bulkUploadQueue.name = @"bulkQueue";
    _bulkUploadQueue.MaxConcurrentOperationCount = 1;
    int count = 1;
    
    for(Document *d in _bulkSendArray){
        BulkUploadOperation *newOperation = [[BulkUploadOperation alloc] initWithDocument:d];
        newOperation.username = username;
        newOperation.token = token;
        newOperation.baseURL = baseURL;
        newOperation.total = [_bulkSendArray count];
        newOperation.current = count;
        newOperation.webview = self.webView;
        [_bulkUploadQueue addOperation:newOperation];
        count++;
    }
    [_bulkUploadQueue addObserver:self forKeyPath:@"bulkUploadOperations" options:0 context:NULL];
}


- (void)downloadAllFilesWithUsername:(NSString *) username andToken:(NSString*) token andBaseURL:(NSString*) baseURL{
    _bulkDownloadArray = [DatabaseManager getDocumentsForBulkDownload];
    if([_bulkDownloadArray count]>0){
        [self writeJavascript:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,0,'download')",[_bulkDownloadArray count]]];
    }
    
    _bulkDownloadQueue = [[NSOperationQueue alloc] init];
    _bulkDownloadQueue.name = @"bulkQueue";
    _bulkDownloadQueue.MaxConcurrentOperationCount = 1;
    int count = 1;
    for(Document *d in _bulkDownloadArray){
        BulkDownloadOperation *newOperation = [[BulkDownloadOperation alloc] initWithDocument:d];
        newOperation.username = username;
        newOperation.token = token;
        newOperation.baseURL = baseURL;
        newOperation.total = [_bulkDownloadArray count];
        newOperation.current = count;
        newOperation.webview = self.webView;
        [_bulkDownloadQueue addOperation:newOperation];
        
        count++;
    }
    [_bulkDownloadQueue addObserver:self forKeyPath:@"bulkDownloadOperations" options:0 context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == _bulkUploadQueue && [keyPath isEqualToString:@"bulkUploadOperations"]) {
        if ([_bulkUploadQueue.operations count] == 0) {
            UIWebView *webview = [[UIWebView alloc] init];
            [webview stringByEvaluatingJavaScriptFromString:@"console.log('upload completed')"];
        }
    }else if(object == _bulkDownloadQueue && [keyPath isEqualToString:@"bulkDownloadOperations"]){
        if ([_bulkDownloadQueue.operations count] == 0) {
            UIWebView *webview = [[UIWebView alloc] init];
            [webview stringByEvaluatingJavaScriptFromString:@"console.log('download completed')"];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

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
    
    [self uploadAllFiles];
    
    
    // Create an object with a simple success property.
    NSDictionary *jsonObj = [[NSDictionary alloc] initWithObjectsAndKeys : @"true", @"success", nil];
    
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
                                     ];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

    
    
- (void)uploadAllFiles{
    _bulkSendArray = [DatabaseManager getPhotosForBulkUpload];
        
    _bulkQueue = [[NSOperationQueue alloc] init];
    _bulkQueue.name = @"bulkQueue";
    _bulkQueue.MaxConcurrentOperationCount = 2;
    
    for(Photo *p in _bulkSendArray){
        BulkOperation *newOperation = [[BulkOperation alloc] initWithPhoto:p];
        [_bulkQueue addOperation:newOperation];
    }
    [_bulkQueue addObserver:self forKeyPath:@"bulkUploadOperations" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == _bulkQueue && [keyPath isEqualToString:@"bulkUploadOperations"]) {
        if ([_bulkQueue.operations count] == 0) {
            NSLog(@"queue has completed");
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

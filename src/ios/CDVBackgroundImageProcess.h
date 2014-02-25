//
//  CDVBackgroundImageProcess.h
//
//
//  Created by Gianluca Pisati on 21/01/14.
//
//

#import <Cordova/CDV.h>
#import "DatabaseManager.h"
#import "BulkUploadOperation.h"
#import "BulkDownloadOperation.h"


@interface CDVBackgroundImageProcess : CDVPlugin{
    NSArray *_bulkSendArray;
    NSArray *_bulkDownloadArray;
    NSOperationQueue *_bulkUploadQueue;
    NSOperationQueue *_bulkDownloadQueue;
    NSMutableArray *_operationArray;
}

- (void)uploadPhotos:(CDVInvokedUrlCommand *)command;
- (void)downloadPhotos:(CDVInvokedUrlCommand *)command;
#pragma mark - Util_Methods
- (void) uploadAllFiles;
- (void) downloadAllFiles;



@end

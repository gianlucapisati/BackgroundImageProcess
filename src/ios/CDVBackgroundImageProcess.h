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
    NSArray *_bulkDownloadArray;
    NSMutableArray *_operationArray;
}

@property (nonatomic, retain) NSOperationQueue *bulkUploadQueue;
@property (nonatomic, retain) NSOperationQueue *bulkDownloadQueue;

- (void)uploadPhotos:(CDVInvokedUrlCommand *)command;
- (void)downloadDocuments:(CDVInvokedUrlCommand *)command;
#pragma mark - Util_Methods
- (void)uploadAllFilesWithUsername:(NSString *) username andToken:(NSString*) token andBaseURL:(NSString*) baseURL andPhotosTosend:(NSString*)photosToSend;
- (void) downloadAllFilesWithUsername:(NSString *)username andToken:(NSString*)token andBaseURL:(NSString*)baseURL;



@end

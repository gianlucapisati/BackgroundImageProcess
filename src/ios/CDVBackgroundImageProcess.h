//
//  CDVBackgroundImageProcess.h
//  
//
//  Created by Gianluca Pisati on 21/01/14.
//
//

#import <Cordova/CDV.h>


@interface CDVBackgroundImageProcess : CDVPlugin{
    NSArray *_bulkSendArray;
    NSOperationQueue *_bulkQueue;
    NSMutableArray *_operationArray;
}

- (void) backgroundimageprocess:(CDVInvokedUrlCommand *)command;

#pragma mark - Util_Methods
    - (void) uploadAllFiles;


    
@end

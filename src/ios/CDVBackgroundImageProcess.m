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
    
    NSString *username      = [command.arguments objectAtIndex:0];
    NSString *token         = [command.arguments objectAtIndex:1];
    NSString *baseURL       = [command.arguments objectAtIndex:2];
    NSString *photosToSend  = [command.arguments objectAtIndex:3];
    
    [self uploadAllFilesWithUsername:username andToken:token andBaseURL:baseURL andPhotosTosend:photosToSend];
    
    
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

- (void)uploadAllFilesWithUsername:(NSString *) username andToken:(NSString*) token andBaseURL:(NSString*) baseURL andPhotosTosend:(NSString*)photosToSend{
    if([photosToSend class] != [NSNull class]){
        NSData *jsonData = [photosToSend dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSArray *jsonArray = (NSArray *)[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&e];

        NSMutableArray *bulkSendArray = [NSMutableArray array];
        
        for(NSDictionary *dic in jsonArray){
            NSString * id_photo = [dic valueForKey:@"id"];
            NSString * uri      = [dic valueForKey:@"uri"];
            Document *currentPhoto = [[Document alloc] initWithIdDocument:id_photo andExtension:@"jpg" andUri:uri];
            
            [bulkSendArray addObject:currentPhoto];
        }
        
        
        if([bulkSendArray count]>0){
            [self writeJavascript:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,0,'upload')",[bulkSendArray count]]];
        }
        self.bulkUploadQueue = [[NSOperationQueue alloc] init];
        self.bulkUploadQueue.name = @"bulkQueue";
        self.bulkUploadQueue.MaxConcurrentOperationCount = 1;
        int count = 1;
        
        for(Document *d in bulkSendArray){
            BulkUploadOperation *newOperation = [[BulkUploadOperation alloc] initWithDocument:d];
            newOperation.username = username;
            newOperation.token = token;
            newOperation.baseURL = baseURL;
            newOperation.total = [bulkSendArray count];
            newOperation.current = count;
            newOperation.webview = self;
            
            [newOperation addObserver:self forKeyPath:@"bulkUploadOperations" options:0 context:NULL];
            [self.bulkUploadQueue addOperation:newOperation];
            count++;
        }
    }
}


- (void)downloadAllFilesWithUsername:(NSString *) username andToken:(NSString*) token andBaseURL:(NSString*) baseURL{
    _bulkDownloadArray = [DatabaseManager getDocumentsForBulkDownload];
    if([_bulkDownloadArray count]>0){
        [self writeJavascript:[NSString stringWithFormat:@"SW.Renderer.handleProgress(%d,0,'download')",[_bulkDownloadArray count]]];
    }
    
    self.bulkDownloadQueue = [[NSOperationQueue alloc] init];
    self.bulkDownloadQueue.name = @"bulkQueue";
    self.bulkDownloadQueue.MaxConcurrentOperationCount = 1;
    int count = 1;
    for(Document *d in _bulkDownloadArray){
        BulkDownloadOperation *newOperation = [[BulkDownloadOperation alloc] initWithDocument:d];
        newOperation.username = username;
        newOperation.token = token;
        newOperation.baseURL = baseURL;
        newOperation.total = [_bulkDownloadArray count];
        newOperation.current = count;
        newOperation.webview = self;
        [newOperation addObserver:self forKeyPath:@"bulkDownloadOperations" options:0 context:NULL];

        [self.bulkDownloadQueue addOperation:newOperation];
        
        count++;
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"bulkUploadOperations"]) {
        if ([self.bulkUploadQueue.operations count] == 0) {
            [self writeJavascript:@"localStorage.setItem('photosToSend','[]'); console.log('upload completed')"];
        }
    }else if([keyPath isEqualToString:@"bulkDownloadOperations"]){
        if ([self.bulkDownloadQueue.operations count] == 0) {
            [self writeJavascript:@"console.log('download completed')"];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

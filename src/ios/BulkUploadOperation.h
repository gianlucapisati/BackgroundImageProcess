//
//  BulkOperation.h
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>

#import "Document.h"

@interface BulkUploadOperation : NSOperation{
    int _kind;
    BOOL _isExecuting;
    BOOL _isFinished;
    BOOL _bulkUploadOperations;
}

-(id)initWithDocument:(Document*)d;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) CDVPlugin *webview;
@property (nonatomic) int current;
@property (nonatomic) int total;

@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;
@property (readonly) BOOL bulkUploadOperations;

@property (strong, nonatomic) Document * document;

@end

//
//  BulkOperation.h
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Photo.h"

@interface BulkDownloadOperation : NSOperation{
    int _kind;
    BOOL _isExecuting;
    BOOL _isFinished;
}

-(id)initWithPhoto:(Photo*)p;

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *baseURL;

@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

@property (strong, nonatomic) Photo * photo;

@end

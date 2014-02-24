//
//  BulkOperation.h
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Photo.h"

@interface BulkOperation : NSOperation{
    int _kind;
    BOOL _isExecuting;
    BOOL _isFinished;
}

-(id)initWithCustomer:(Photo*)p;

@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

@property (strong, nonatomic) Photo * photo;

@end

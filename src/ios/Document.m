//
//  Document.m
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import "Document.h"

@implementation Document

-(id)initWithIdDocument:(NSString*)id_document andExtension:(NSString*)extension andUri:(NSString *)uri{
    self = [super init];
    if (self)
    {
        self.id_document = id_document;
        self.extension = extension;
        self.uri = uri;
    }
    
    return self;
}

@end

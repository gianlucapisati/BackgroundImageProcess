//
//  Photo.m
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import "Photo.h"

@implementation Photo

-(id)initWithIdPhoto:(NSString*)id_photo andUri:(NSString *)uri{
    self = [super init];
    if (self)
    {
        self.id_photo = id_photo;
        self.uri = uri;
    }
    
    return self;
}

@end

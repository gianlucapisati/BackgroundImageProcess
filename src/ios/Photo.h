//
//  Photo.h
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject{
    NSString *id_photo;
    NSString *uri;
}

-(id)initWithIdPhoto:(int)id_photo andUri:(NSString *)uri;

@end

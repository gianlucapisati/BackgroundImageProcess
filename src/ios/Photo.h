//
//  Photo.h
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject{
}

-(id)initWithIdPhoto:(NSString*)id_photo andUri:(NSString *)uri;

@property(nonatomic,strong) NSString *id_photo;
@property(nonatomic,strong) NSString *uri;


@end

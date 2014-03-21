//
//  Document.h
//  PerfectStore
//
//  Created by Gianluca Pisati on 18/11/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Document : NSObject{
}

-(id)initWithIdDocument:(NSString*)id_document andExtension:(NSString*)extension andUri:(NSString *)uri;

@property(nonatomic,strong) NSString *id_document;
@property(nonatomic,strong) NSString *extension;
@property(nonatomic,strong) NSString *uri;


@end

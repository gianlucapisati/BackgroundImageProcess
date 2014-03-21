//
//  DatabaseManager.h
//  PerfectStore
//
//  Created by matteo petrioli on 19/02/13.
//  Copyright (c) 2013 Vidiemme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Document.h"

@interface DatabaseManager : NSObject{
    
}

+ (DatabaseManager *)sharedDatabase;

+(NSArray*)getPhotosForBulkUpload;
+(NSArray*)getDocumentsForBulkDownload;
+(void)deletePhotoWithId:(NSString*)id_document;
@end

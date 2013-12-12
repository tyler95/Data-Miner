//
//  DMPullStockData.h
//  Data Miner
//
//  Created by Tyler Gustafson on 11/26/13.
//  Copyright (c) 2013 Tyler Gustafson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMPullStockData : NSObject {
    NSString *_Main;
    NSDate *_date;
}

@property (strong, nonatomic) NSString *Main;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *trim;
@property (strong, nonatomic) NSString *ID;
@property (strong, nonatomic) NSString *Weekday;


//@property (strong, nonatomic) NSArrayController *arrayController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (id)initWithHTML:(NSString *)Main ID:(NSString *)ID Weekday:(NSString *)weekday;
- (void)extractAndUploadData:(NSString *)inString;



- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)arrayController;

@end

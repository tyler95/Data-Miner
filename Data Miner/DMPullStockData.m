//
//  DMPullStockData.m
//  Data Miner
//
//  Created by Tyler Gustafson on 11/26/13.
//  Copyright (c) 2013 Tyler Gustafson. All rights reserved.
//

#import "DMPullStockData.h"
#import <CoreData/CoreData.h>
#import "StockHistory.h"
#import "AFHTTPClient.h"

@implementation DMPullStockData

@synthesize date = _date;
@synthesize Main = _Main;
@synthesize ID = _ID;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (id)initWithHTML:(NSString *)Main ID:(NSString *)ID Weekday:(NSString *)weekday{
    self.Weekday = weekday;
    self.ID = ID;
    self.Main = Main;
    [self beginParse];
    return self;
}


- (void)beginParse{
    NSString *body = [self removeEnds];
    int count = 0;
    NSArray *components = [self splitData:body];
    
    while (count < components.count){
        NSString *acomp = components[count];
        [self extractAndUploadData:acomp];
        count++;
    }
}

- (NSString *)removeInvisibles:(NSString *)inString{
    inString = [inString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    inString = [inString stringByReplacingOccurrencesOfString:@" " withString:@""];
    inString = [inString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    inString = [inString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    return inString;
}

- (NSString *)removeEnds{
    NSArray *tmp = [self.Main componentsSeparatedByString:@"<span id=\"ctl00_Main_lblDate\">"];
    
    NSString *beforeDate = tmp[1];
    NSArray *removeDate = [beforeDate componentsSeparatedByString:@"</span></b>"];
    NSString *dateString = removeDate[0];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    self.date = [df dateFromString:dateString];
    
    
    
    NSString *cleanBeforeDate = [self removeInvisibles:beforeDate];
    
    NSArray *removeHeader = [cleanBeforeDate componentsSeparatedByString:@"span><tableborder=\"0\"width=\"100%\"align=\"center\"><tbody><tr><tdwidth=\"100px\"><b>"];
    
    NSString *bottom = removeHeader[1];
    
    
    NSArray *removeBottom = [bottom componentsSeparatedByString:@"Sys.Application.initialize();"];
    
    NSString *body = removeBottom[0];
    
    return body;
    
}

- (NSArray *)splitData:(NSString *)inString{
    NSArray *components = [inString componentsSeparatedByString:@"table><tableborder=\"0\"width=\"100%\"align=\"center\"><tbody><tr><tdwidth=\"100px\"><b>"];
    return components;
}

- (NSString *)getTextBetween:(NSString *)beforeString And:(NSString *)afterString From:(NSString *)fullString{
    NSArray *tmp = [fullString componentsSeparatedByString:beforeString];
    NSString *beforeRemoved = tmp[1];
    tmp = [beforeRemoved componentsSeparatedByString:afterString];
    NSString *clean = tmp[0];
    if (tmp.count > 1){
        NSMutableArray *removedFirst = [NSMutableArray arrayWithArray:tmp];
        [removedFirst removeObjectAtIndex:0];
        self.trim = [removedFirst componentsJoinedByString:afterString];
    }
    else{
        self.trim = tmp[1];
    }
    return clean;
}

- (void)extractAndUploadData:(NSString *)inString{
    NSString *Company = [self getTextBetween:@"lblCompany\">" And:@"</span><ahref=\"/" From:inString];
    NSString *Symbol = [self getTextBetween:@"Stock_Quote/symboldata.aspx?symbol=" And:@"\">(" From:self.trim];
    NSString *Close = [self getTextBetween:@"lblClose\">" And:@"</span></td><tdstyle=\"width:" From:self.trim];
    NSString *Volume = [self getTextBetween:@"lblChange\">" And:@"</span></td></tr><tr><td>&nbsp;</" From:self.trim];
    NSString *IntradayHigh = [self getTextBetween:@"_Label7\">" And:@"</span></td><tdstyle=\"color:#3A7EBD;font-" From:self.trim];
    NSString *PercentChange = [self getTextBetween:@"_Label8\">" And:@"</span></td>" From:self.trim];
    NSString *DollarChange = [self getTextBetween:@"lblVol\">" And:@"</span></td>" From:self.trim];
    NSString *DollarVolume = [self getTextBetween:@"_lblPer\">" And:@"</span></td>" From:self.trim];
    NSString *Open = [self getTextBetween:@"_Label6\">" And:@"</span></td>" From:self.trim];
    NSString *PreviousClose = [self getTextBetween:@"_Label9\">" And:@"</span></td>" From:self.trim];
    NSString *M3High = [self getTextBetween:@"_Label1\">" And:@"</span></td>" From:self.trim];
    NSString *M3VolumeAvg = [self getTextBetween:@"_Label4\">" And:@"</span></td>" From:self.trim];
    NSString *M3Low = [self getTextBetween:@"_Label2\">" And:@"</span></td>" From:self.trim];
    NSString *M3PercentChange = [self getTextBetween:@"_Label5\">" And:@"</span></td>" From:self.trim];
    NSString *M3DollarVolumeAvg = [self getTextBetween:@"_Label3\">" And:@"</span></td>" From:self.trim];
    NSString *Promoter = [self getTextBetween:@"_lblPromoterName\">" And:@"</span></td>" From:self.trim];
    NSString *Compensation = [self getTextBetween:@"lblCompensation\">" And:@"</span></td>" From:self.trim];
    
   /* NSLog(@"Company: %@\nSymbol: %@\nClose: %@\nVolume: %@\nIntraday High: %@\nPercent Change: %@\nDollar Change: %@\nDollarVolume: %@\nOpen: %@\nPrevious Close: %@\n3 Month High: %@\n3 Month Average Volume: %@\n3 Month Low: %@\n3 Month Percent Change: %@\n3 Month Dollar Volume Average: %@\nPromoter: %@\nCompensation: %@\n", Company, Symbol, Close, Volume, IntradayHigh, PercentChange, DollarChange, DollarVolume, Open, PreviousClose, M3High, M3VolumeAvg, M3Low, M3PercentChange, M3DollarVolumeAvg, Promoter, Compensation);*/
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StockHistory" inManagedObjectContext:self.managedObjectContext];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterNoStyle];
    
    if ([PercentChange isEqualToString:@"N/A"]){
        if (![PreviousClose isEqualToString:@"N/A"] && ![Close isEqualToString:@"N/A"]) {
            PercentChange = [NSString stringWithFormat:@"%f",(Close.floatValue - PreviousClose.floatValue) / PreviousClose.floatValue];
        }
        else {
            PreviousClose = @"9999";
        }
    }
    
    if ([DollarChange isEqualToString:@"N/A"])
        DollarChange = @"9999";
    if ([Open isEqualToString:@"N/A"])
        Open = @"9999";
    if ([Close isEqualToString:@"N/A"])
        Close = @"9999";
    if ([IntradayHigh isEqualToString:@"N/A"])
        IntradayHigh = @"9999";
    if ([PreviousClose isEqualToString:@"N/A"])
        PreviousClose = @"9999";
    if ([M3Low isEqualToString:@"N/A"])
        M3Low = @"9999";
    if ([M3High isEqualToString:@"N/A"])
        M3High = @"9999";
    if ([M3PercentChange isEqualToString:@"N/A"])
        M3PercentChange = @"9999";
    
    Volume = [Volume stringByReplacingOccurrencesOfString:@"," withString:@""];
    M3VolumeAvg = [M3VolumeAvg stringByReplacingOccurrencesOfString:@"," withString:@""];
    M3DollarVolumeAvg = [M3DollarVolumeAvg stringByReplacingOccurrencesOfString:@"," withString:@""];
    DollarVolume = [DollarVolume stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    StockHistory *newDoc = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    newDoc.company = Company;
    newDoc.symbol = Symbol;
    newDoc.close = [f numberFromString:Close];
    newDoc.volume = [f numberFromString:Volume];
    newDoc.intradayhigh = [f numberFromString:IntradayHigh];
    newDoc.percentchange = [f numberFromString:PercentChange];
    newDoc.dollarchange = [f numberFromString:DollarChange];
    newDoc.dollarvolume = [f numberFromString:DollarVolume];
    newDoc.open = [f numberFromString:Open];
    newDoc.previousclose = [f numberFromString:PreviousClose];
    newDoc.m3high = [f numberFromString:M3High];
    newDoc.m3volumeavg = [f numberFromString:M3VolumeAvg];
    newDoc.m3low = [f numberFromString:M3Low];
    newDoc.m3percentchange = [f numberFromString:M3PercentChange];
    newDoc.m3dollarvolumeavg = [f numberFromString:M3DollarVolumeAvg];
    newDoc.promoter = Promoter;
    newDoc.compensation = Compensation;
    newDoc.date = self.date;
    newDoc.id = [f numberFromString:self.ID];
    newDoc.weekday = self.Weekday;
    
    
    NSError *error = nil;
    
    [self.managedObjectContext save:&error];
    
    /*  NSString *post = [NSString stringWithFormat:@"Company=%@&Symbol=%@&Close=%@&Volume=%@&IntradayHigh=%@&PercentChange=%@&DollarChange=%@&DollarVolume=%@&Open=%@&PreviousClose=%@&M3High=%@&M3VolumeAvg=%@&M3Low=%@&M3PercentChange=%@&M3DollarVolumeAvg=%@&Promoter=%@&Compensation=%@", Company, Symbol, Close, Volume, IntradayHigh, PercentChange, DollarChange, DollarVolume, Open, PreviousClose, M3High, M3VolumeAvg, M3Low, M3PercentChange, M3DollarVolumeAvg, Promoter, Compensation];
     NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     
     NSString *postLength = [NSString stringWithFormat:@"%ld", (unsigned long)[postData length]];
     
     NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
     [request setURL:[NSURL URLWithString:@"http://192.168.42.22:70/StockUpload.php"]];
     [request setHTTPMethod:@"POST"];
     [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
     [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
     [request setHTTPBody:postData];*/
    
    
    /*
     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://192.168.42.22:70/StockUpload.php"]];
     
     
     
     
     
     
     
     NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
     self.date, @"Date",
     Company, @"Company",
     Symbol, @"Symbol",
     Close, @"Close",
     Volume, @"Volume",
     IntradayHigh, @"IntradayHigh",
     PercentChange, @"PercentChange",
     DollarChange, @"DollarChange",
     DollarVolume, @"DollarVolume",
     Open, @"Open",
     PreviousClose, @"PreviousClose",
     M3High, @"M3High",
     M3VolumeAvg, @"M3VolumeAvg",
     M3Low, @"M3Low",
     M3PercentChange, @"M3PercentChange",
     M3DollarVolumeAvg, @"M3DollarVolumeAvg",
     Promoter, @"Promoter",
     Compensation, @"Compensation",
     nil];
     
     
     
     
     NSURLRequest *postRequest = [httpClient multipartFormRequestWithMethod:@"POST"
     path:@"http://192.168.42.22:70/StockUpload.php"
     parameters:params
     constructingBodyWithBlock:^(id formData) {
     
     }];
     
     AFHTTPRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:postRequest];
     [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
     //CGFloat progress = ((CGFloat)totalBytesWritten) / totalBytesExpectedToWrite;
     //progressBlock(progress);
     }];
     
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
     if (operation.response.statusCode == 200 || operation.response.statusCode == 201) {
     NSLog(@"Status Code: %ld", (long)operation.response.statusCode);
     NSLog(@"Created, %@", responseObject);
     } else {
     //completionBlock(NO, nil);
     NSLog(@"Status Code: %ld", (long)operation.response.statusCode);
     }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     // completionBlock(NO, error);
     NSLog(@"Status Code w/Fail : %ld", (long)operation.response.statusCode);
     }];
     
     
     
     NSOperationQueue *queue = [[NSOperationQueue alloc] init];
     [queue addOperation:operation];
     
     
     
     */
    
    
    
    
    
}

/*
 
 - (NSFetchedResultsController *)fetchedResultsController
 {
 if (_fetchedResultsController != nil) {
 return _fetchedResultsController;
 }
 
 NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
 // Edit the entity name as appropriate.
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"CMSPitMaster" inManagedObjectContext:self.managedObjectContext];
 [fetchRequest setEntity:entity];
 
 // Set the batch size to a suitable number.
 [fetchRequest setFetchBatchSize:50];
 
 // Edit the sort key as appropriate.
 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
 NSArray *sortDescriptors = @[sortDescriptor];
 
 [fetchRequest setSortDescriptors:sortDescriptors];
 
 // Edit the section name key path and cache name if appropriate.
 // nil for section name key path means "no sections".
 NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
 aFetchedResultsController.delegate = self;
 self.fetchedResultsController = aFetchedResultsController;
 
 NSError *error = nil;
 if (![self.fetchedResultsController performFetch:&error]) {
 // Replace this implementation with code to handle the error appropriately.
 // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
 abort();
 }
 
 return _fetchedResultsController;
 }
 */
- (void)arrayController
{
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"StockHistory" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:50];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"percentchange" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    
    //NSLog(@"The array: %@", array);
    
    [self loopArray:array];
}

- (void)loopArray:(NSArray *)array{
    for (int c = 0; array.count > c; c++) {
        StockHistory *history = [array objectAtIndex:c];
        [self printData:history];
    }
}

- (void)printData:(StockHistory *)obj{
    NSLog(@"Company: %@\nSymbol: %@\nClose: %@\nVolume: %@\nIntraday High: %@\nPercent Change: %@\nDollar Change: %@\nDollarVolume: %@\nOpen: %@\nPrevious Close: %@\n3 Month High: %@\n3 Month Average Volume: %@\n3 Month Low: %@\n3 Month Percent Change: %@\n3 Month Dollar Volume Average: %@\nPromoter: %@\nCompensation: %@\n", obj.company, obj.symbol, obj.close, obj.volume, obj.intradayhigh, obj.percentchange, obj.dollarchange, obj.dollarvolume, obj.open, obj.previousclose, obj.m3high, obj.m3volumeavg, obj.m3low, obj.m3percentchange, obj.m3dollarvolumeavg, obj.promoter, obj.compensation);
}

#pragma mark Core Data Stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Stocks.sqlite"];
    //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        /* Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         */
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}





@end

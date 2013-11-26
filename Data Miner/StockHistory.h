//
//  StockHistory.h
//  Data Miner
//
//  Created by Tyler Gustafson on 11/26/13.
//  Copyright (c) 2013 Tyler Gustafson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StockHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * close;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * compensation;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * dollarchange;
@property (nonatomic, retain) NSNumber * dollarvolume;
@property (nonatomic, retain) NSNumber * intradayhigh;
@property (nonatomic, retain) NSNumber * m3dollarvolumeavg;
@property (nonatomic, retain) NSNumber * m3high;
@property (nonatomic, retain) NSNumber * m3low;
@property (nonatomic, retain) NSNumber * m3percentchange;
@property (nonatomic, retain) NSNumber * m3volumeavg;
@property (nonatomic, retain) NSNumber * open;
@property (nonatomic, retain) NSNumber * percentchange;
@property (nonatomic, retain) NSNumber * previousclose;
@property (nonatomic, retain) NSString * promoter;
@property (nonatomic, retain) NSString * symbol;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * weekday;
@property (nonatomic, retain) NSString * track1;
@property (nonatomic, retain) NSString * track2;

@end

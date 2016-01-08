//
//  USGSDataRequest.h
//  EarthQuakeApp
//
//  Created by Robert Payne on 12/15/15.
//  Copyright © 2015 Robert Payne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EarthquakePoint.h"

#define kEndPointPrefix @"https://service.iris.edu/fdsnws/event/1/query?"

@protocol USGSDataRequestDelegate <NSObject>
-(void)dataRequestSuccess:(NSArray<EarthquakePoint*>*)data;
-(void)dataRequestError;
@end

@interface USGSDataRequest : NSObject <NSXMLParserDelegate>

@property (nonatomic)id<USGSDataRequestDelegate> delegate;

-(void)requestDataWithRect:(MKMapRect)rect minMagnitude:(NSNumber*)minMag maxMagnitude:(NSNumber*)maxMag startTime:(NSDate*)start endTime:(NSDate*)endTime;
-(void)requestDataWithRect:(MKMapRect)rect;

@end

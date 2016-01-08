//
//  USGSDataRequest.m
//  EarthQuakeApp
//
//  Created by Robert Payne on 12/15/15.
//  Copyright © 2015 Robert Payne. All rights reserved.
//

#import "USGSDataRequest.h"

@implementation USGSDataRequest {
    NSMutableArray      *earthQuakePoints;
    EarthquakePoint     *currentPoint;
    NSNumber            *currentLongitude;
    NSNumber            *currentLatitude;
    NSString            *currentElement;
    NSString            *previousElement;
    NSNumberFormatter   *numberFormatter;
}

-(void)requestDataWithRect:(MKMapRect)rect {
    [self requestDataWithRect:rect minMagnitude:@1.0 maxMagnitude:@10.0 startTime:nil endTime:nil];
}

-(void)requestDataWithRect:(MKMapRect)rect minMagnitude:(NSNumber*)minMag maxMagnitude:(NSNumber*)maxMag startTime:(NSDate*)start endTime:(NSDate*)endTime {
    
    earthQuakePoints = [NSMutableArray new];
    numberFormatter = [[NSNumberFormatter alloc]init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *endDate = [NSDate date];
    
    NSString *endDateString = [dateFormatter stringFromDate:endDate];
    NSString *startDateString = [dateFormatter stringFromDate:[endDate dateByAddingTimeInterval:-86400.0]];
    
    NSString *minMagnitude = [NSString stringWithFormat:@"%@", minMag];
    
    NSString *urlString = [NSString stringWithFormat:@"%@start=%@&end=%@&minmagnitude=%@",
                           kEndPointPrefix, startDateString, endDateString, minMagnitude];
    [self urlRequestWithURLString:urlString];
}

-(void)urlRequestWithURLString:(NSString*)urlString {
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                if(error) {
                    
                    [self.delegate dataRequestError];
                } else if(data) {

                    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
                    parser.delegate = self;
                    if(![parser parse]) {
                        
                        [self.delegate dataRequestError];
                    }
                }
            }] resume];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{

    previousElement = currentElement;
    currentElement = elementName;

    if([elementName isEqualToString:@"event"]) {
        
        currentPoint = [EarthquakePoint new];
        currentLongitude = @-999;
        currentLatitude = @-999;
        currentPoint.magnitude = @-999;
        currentPoint.locationName = @"";
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {    
    
    if([previousElement isEqualToString:@"type"] &&
       [currentElement isEqualToString:@"text"] && [currentPoint.locationName isEqualToString:@""]) {
        
        currentPoint.locationName = string;
    } else if([previousElement isEqualToString:@"mag"] && currentPoint.magnitude.intValue == -999) {
        
        currentPoint.magnitude = [numberFormatter numberFromString:string];
    } else if([previousElement isEqualToString:@"latitude"] && currentLatitude.intValue == -999) {
        
        currentLatitude = [numberFormatter numberFromString:string];
    } else if([previousElement isEqualToString:@"longitude"] && currentLongitude.intValue == -999) {
        
        currentLongitude = [numberFormatter numberFromString:string];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"event"]) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(currentLatitude.doubleValue, currentLongitude.doubleValue);
        currentPoint.coordinate = location;
        [earthQuakePoints addObject:currentPoint];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.delegate dataRequestSuccess:earthQuakePoints];
}

@end

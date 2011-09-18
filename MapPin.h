//
//  MapPin.h
//  TableApp
//
//  Created by Francois Chabat on 15/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapPin : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}
-(void)setCoordinate:(CLLocationCoordinate2D)myCoordinate title:(NSString*)myTitle subtitle:(NSString*)mySubtitle;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* subtitle;

@end
//
//  Localisation.h
//  TableApp
//
//  Created by Francois Chabat on 07/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "Photo.h"

@interface Localisation : NSObject <CLLocationManagerDelegate> {
    NSMutableArray *neighbourhoods;
    NSMutableArray *photos;
    CLLocationManager *locationManager;
    NSOperationQueue *requestQueue;
    NSOperationQueue *responseQueue;
    CLLocation *bestEffortLocation;
    CLLocation *uploadPhotoLocation;
    int nbLocationUpdates;
}
-(void)startLocalisation;
-(void)startRequest;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *neighbourhoods;
@property (nonatomic, retain) CLLocation *bestEffortLocation;
@property (nonatomic, retain) CLLocation *uploadPhotoLocation;
@end


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
    NSMutableData *jsonData;
}
-(void)startLocalisation;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableSet *neighbourhoods;

@end


//
//  MapPin.m
//  TableApp
//
//  Created by Francois Chabat on 15/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin
@synthesize coordinate=_coordinate;
@synthesize title=_title;
@synthesize subtitle=_subtitle;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
-(void)setCoordinate:(CLLocationCoordinate2D)myCoordinate title:(NSString*)myTitle subtitle:(NSString*)mySubtitle;
{
    self.coordinate = myCoordinate;
    self.title = myTitle;
    self.subtitle = mySubtitle;
}

-(void)dealloc
{
    [_title release];
    [_subtitle release];
    [super dealloc];
}
@end

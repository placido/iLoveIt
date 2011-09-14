//
//  Localisation.m
//  TableApp
//
//  Created by Francois Chabat on 07/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Localisation.h"
#import "SBJson.h"
#import "TableAppAppDelegate.h"

@implementation Localisation

@synthesize locationManager=_locationManager;
@synthesize neighbourhoods=_neighbourhoods;

- (id)init
{
    self = [super init];
    if (self) {
        CLLocationManager *aLocationManager = [[CLLocationManager alloc] init];
        aLocationManager.delegate = self;
        self.locationManager = aLocationManager;
        [aLocationManager release];
    }
    return self;
}

-(void)startLocalisation {
    
    [self.locationManager startUpdatingLocation];
    // BEGIN: Simulate a didUpdateToLocation message
    CLLocation *simulatedLocation = [[CLLocation alloc] initWithLatitude:50 longitude:-1];
    [self locationManager:self.locationManager didUpdateToLocation:simulatedLocation fromLocation:simulatedLocation];
    [simulatedLocation release];
    // END
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Updated device location");
    NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
    NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
    // Got the device location, call the web service
	jsonData = [[NSMutableData data] retain];
    NSString *url = [[NSString alloc] initWithFormat:@"http://ec2-79-125-90-3.eu-west-1.compute.amazonaws.com:8080/ilove/api/app?lat=%f&lng=%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    NSLog(@"Requesting %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // TO DO: handle multiple location updates with increased accuracy
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Failed to receive location");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[jsonData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[jsonData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	 NSLog(@"Connection failed");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	[jsonData release];
    NSLog(@"Received JSON string");
    
    // Parse JSON string
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:jsonString error:&error];    
    [jsonParser release], jsonParser = nil;
    
    // Process the neighbourhoods
    neighbourhoods = [NSMutableArray array];
    NSArray *hoods = [jsonObject objectForKey:@"hoods"];
    for (NSDictionary *hood in hoods) {
        [neighbourhoods addObject:[hood objectForKey:@"name"]];
        NSLog(@"Neighbourhood name: %@", [hood objectForKey:@"name"]);
    }
    // Set the nav bar title
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.gridViewController.navigationItem.title = [NSString stringWithFormat:@"I love %@", [neighbourhoods objectAtIndex:0]];
    
    // Process the photos
    photos = [NSMutableArray array];
    int x = 0; int y = 0;
    NSArray *jsonPhotos = [jsonObject objectForKey:@"photos"];
    for (NSDictionary *photo in jsonPhotos) {
        NSDictionary *photoIdDict = [photo objectForKey:@"_id"];
        NSString *photoId = [photoIdDict objectForKey:@"$oid"];
        NSString *caption = [photo objectForKey:@"caption"];
        NSArray *coordinates = [photo objectForKey:@"location"];
        NSNumber *latitude = [coordinates objectAtIndex:0];
        NSNumber *longitude = [coordinates objectAtIndex:1];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];   
        NSLog(@"Photo id: %@", photoId);
        NSLog(@"Photo caption: %@", caption);
        NSLog(@"Photo coordinates: %@, %@", latitude, longitude);

        Photo *photo = [[Photo alloc] initWithPhotoId:photoId caption:caption x:x y:y location:location];
        [location release];
        [photos addObject:photo];
        x += 160;
        if (x>160) {
            x = 0;
            y += 160;
        }
    }

    // Update the scrollView dimensions
    [delegate.gridViewController.scrollView setContentSize:CGSizeMake(320, y+160)];
    // Stop the spinner
    [delegate.gridViewController.spinner stopAnimating];
    // Start loading thumbnails asynchronously
    for (Photo* photo in photos) {
        [photo loadThumbnail];
    } 
}

- (void)dealloc
{
    NSLog(@"Deallocating");
    [_neighbourhoods release];
    [_locationManager stopUpdatingLocation];
    [_locationManager release];
    [super dealloc];
}

@end

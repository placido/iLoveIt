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
#import "Thumbnail.h"
#import "GridViewController.h"
#import "ASIHTTPRequest.h"

@implementation Localisation

@synthesize locationManager=_locationManager;
@synthesize neighbourhoods=_neighbourhoods;
@synthesize bestEffortLocation=_bestEffortLocation;

- (id)init
{
    NSLog(@"Initialising Localisation");
    self = [super init];
    if (self) {
        nbLocationUpdates = 0;
        CLLocationManager *aLocationManager = [[CLLocationManager alloc] init];
        aLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        aLocationManager.delegate = self;
        self.locationManager = aLocationManager;
        [aLocationManager release];
        NSMutableArray *aNeighbourhoods = [[NSMutableArray alloc] initWithObjects:nil];
        self.neighbourhoods = aNeighbourhoods;
        [aNeighbourhoods release];
        photos = [[NSMutableArray alloc] initWithObjects:nil];
        // Create queue of JSON requests. Process one at a time
        requestQueue = [[NSOperationQueue alloc] init];
        [requestQueue setMaxConcurrentOperationCount:1];
        // Create queue of JSON responses. Process one at a time
        responseQueue = [[NSOperationQueue alloc] init];
        [responseQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

-(void)startLocalisation {
    [self.locationManager startUpdatingLocation];
    #if TARGET_IPHONE_SIMULATOR
    // Simulate a didUpdateToLocation message
    NSDate* now = [[NSDate alloc] init];
    CLLocation *simulatedLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(51.0, -1.0) altitude:1.0 horizontalAccuracy:kCLLocationAccuracyThreeKilometers verticalAccuracy:kCLLocationAccuracyThreeKilometers timestamp:now];
    [self locationManager:self.locationManager didUpdateToLocation:simulatedLocation fromLocation:simulatedLocation];
    [simulatedLocation release];
    [now release];
    #endif
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"Updated device location: (%f, %f)", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    nbLocationUpdates++;

    // Ignore cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    // Test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    
    // Test the measurement to see if it is more accurate than the previous measurement
    if (self.bestEffortLocation == nil || self.bestEffortLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        self.bestEffortLocation = newLocation;
        [self startRequest];
    }
    // Required accuracy? Stop location service
    if ((nbLocationUpdates > 3) || (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy)) {
        [self.locationManager stopUpdatingLocation];
        NSLog(@"Stopped updating location at (%f, %f)", self.bestEffortLocation.coordinate.latitude, self.bestEffortLocation.coordinate.longitude);
    }
}

-(void)startRequest
{
    NSString *url = [[NSString alloc] initWithFormat:@"http://ec2-79-125-90-3.eu-west-1.compute.amazonaws.com:8080/ilove/api/app?lat=%f&lng=%f&ts=%d", self.bestEffortLocation.coordinate.latitude, self.bestEffortLocation.coordinate.longitude, [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]]];
    NSLog(@"Adding request to queue: %@", url);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [request setTimeOutSeconds:15];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setShouldAttemptPersistentConnection:YES];
    [requestQueue addOperation:request];  
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.gridViewController.spinner stopAnimating];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Failed to find location. Please try again later." 
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)requestDone:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    NSLog(@"Received JSON response for: %@", request.url);
    
    // Parse JSON string
    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
    NSError *error = nil;
    NSDictionary *jsonObject = [jsonParser objectWithString:response error:&error];    
    [jsonParser release], jsonParser = nil;
    
    // Process the neighbourhoods
    NSMutableArray *newNeighbourhoods = [[NSMutableArray alloc] init];
    NSArray *hoods = [jsonObject objectForKey:@"hoods"];

    for (int i=0; i<[hoods count]; i++) {
        NSDictionary *hood = [hoods objectAtIndex:i];
        [newNeighbourhoods insertObject:[hood objectForKey:@"name"] atIndex:i];
        // NSLog(@"Neighbourhood %d is %@", i, [newNeighbourhoods objectAtIndex:i]);
    }
    // TO DO: Set error alert
    if ([newNeighbourhoods count] == 0) {
        [newNeighbourhoods insertObject:@"it" atIndex:0];
    }
    self.neighbourhoods = newNeighbourhoods;

    
    // Set the nav bar title
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.gridViewController.navigationItem.title = [NSString stringWithFormat:@"I love %@", [self.neighbourhoods objectAtIndex:0]];
    
    // Populate the array of photos
    NSMutableArray *newPhotos = [[NSMutableArray alloc] init];
    NSArray *jsonPhotos = [jsonObject objectForKey:@"photos"];
    for (int i=0; i<[jsonPhotos count]; i++) {
        NSDictionary* jsonPhoto = [jsonPhotos objectAtIndex:i];
        NSDictionary *photoIdDict = [jsonPhoto objectForKey:@"_id"];
        NSString *photoId = [photoIdDict objectForKey:@"$oid"];
        NSString *caption = [jsonPhoto objectForKey:@"caption"];
        NSArray *coordinates = [jsonPhoto objectForKey:@"location"];
        NSNumber *latitude = [coordinates objectAtIndex:0];
        NSNumber *longitude = [coordinates objectAtIndex:1];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];   
       // NSLog(@"Photo id: %@ / Caption: %@ / Coordinates: (%@, %@)", photoId, caption, latitude, longitude);
        Photo *photo = [[Photo alloc] initWithPhotoId:photoId caption:caption location:location];
        [newPhotos insertObject:photo atIndex:i];
        [location release];
    }
    NSMutableArray *oldPhotos = photos;
    photos = newPhotos;
    // Stop the spinner
    [delegate.gridViewController.spinner stopAnimating];
    
    // Release old photos
    for (Photo *oldPhoto in oldPhotos) {
        [oldPhoto release];
    }
    [oldPhotos release];

    
    // Populate the array of thumbnails
    NSMutableArray *thumbnails = delegate.gridViewController.thumbnails;
    int x = 0; int y = 0; 
    for (int i=0; i<[photos count]; i++) {
        // move the thumbnail currently at (x, y) out-of-sight
        for (int j=0; j<[thumbnails count]; j++) {
            Thumbnail *theThumbnail = [thumbnails objectAtIndex:j];
            if ((theThumbnail.x == x) && (theThumbnail.y == y)) {
                NSLog(@"Moving \"%@\" out of sight", theThumbnail.photo.caption);
                [theThumbnail moveToX:-160 y:-160];
            }
        }
        Photo *photo = [photos objectAtIndex:i];
        // Check whether there is already a thumbnail with this photo
        Boolean alreadyExists = NO;
        for (int j=0; j<[thumbnails count]; j++) {
            Thumbnail *theThumbnail = [thumbnails objectAtIndex:j];
            if ([theThumbnail.photo.photoId isEqualToString:photo.photoId]) {
                NSLog(@"There is already a thumbnail with photo id %@. Moving \"%@\" to (%d, %d)", photo.photoId, theThumbnail.photo.caption, x, y);
                [theThumbnail moveToX:x y:y];
                alreadyExists = YES;
            }
        }
        if (!alreadyExists) {
            // create a new thumbnail
            Thumbnail* thumbnail = [[Thumbnail alloc] initWithX:x y:y photo:photo];
            [thumbnails addObject:thumbnail];
            [thumbnail load];
            NSLog(@"Created new thumbnail \"%@\" at (%d, %d)", thumbnail.photo.caption, thumbnail.x, thumbnail.y);
        }
        x += 160;
        if (x>160) {
            x = 0;
            y += 160;
        }
    }
    
    // Update the scrollView dimensions
    if (x > 0) { 
        y +=160; 
    }
    [delegate.gridViewController.scrollView setContentSize:CGSizeMake(320, y)];
    
    // remove the thumbnails that are now out-of-sight
    for (int j=0; j<[thumbnails count]; j++) {
        Thumbnail *theThumbnail = [thumbnails objectAtIndex:j];
        if ((theThumbnail.x == -160) && (theThumbnail.y == -160)) {
            NSLog(@"Removing out-of-sight thumbnail \"%@\"", theThumbnail.photo.caption);
            [theThumbnail.imageView removeFromSuperview];
            [thumbnails removeObject:theThumbnail];
            [theThumbnail release];
        }
    }
    
  
}

- (void)requestWentWrong:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
    if ([photos count] == 0) {
        // if photos array is empty display message. Otherwise fail silently
        TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate.gridViewController.spinner stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Could not connect to server. Please try again later." 
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)dealloc
{
    NSLog(@"Deallocating Localisation");
    [requestQueue release];
    [responseQueue release];
    [photos release];
    [_bestEffortLocation release];
    [_neighbourhoods release];
    [_locationManager stopUpdatingLocation];
    [_locationManager release];
    [super dealloc];
}

@end

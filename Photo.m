//
//  Photo.m
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "TableAppAppDelegate.h"
#import "Constants.h"

@implementation Photo

@synthesize photoId=_photoId;
@synthesize caption=_caption;
@synthesize urlThumbnail=_urlThumbnail;
@synthesize urlLarge=_urlLarge;
@synthesize location=_location;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithPhotoId:(NSString *)myPhotoId caption:(NSString *)myCaption location:(CLLocation *)myLocation
{
    self = [self init];
   // NSLog(@"Initialising photo %@ with caption %@", self, myCaption);
    self.photoId = myPhotoId;
    self.caption = myCaption;
    NSString *baseUrl = [NSString stringWithFormat:@"%@/%@/", cdnUrl, self.photoId];
    self.urlThumbnail = [NSURL URLWithString:[baseUrl stringByAppendingString:@"small.jpeg"]];
    self.urlLarge = [NSURL URLWithString:[baseUrl stringByAppendingString:@"large.jpeg"]];
    self.location = myLocation;
    return self;
}

- (id) initFromJSON:(NSDictionary*)json
{
    self = [self init];
    NSDictionary *photoIdDict = [json objectForKey:@"_id"];
    self.photoId = [photoIdDict objectForKey:@"$oid"];
    self.caption = [json objectForKey:@"caption"]; 
    NSString *baseUrl = [NSString stringWithFormat:@"%@/%@/", cdnUrl, self.photoId];
    self.urlThumbnail = [NSURL URLWithString:[baseUrl stringByAppendingString:@"small.jpeg"]];
    self.urlLarge = [NSURL URLWithString:[baseUrl stringByAppendingString:@"large.jpeg"]];
    NSArray *coordinates = [json objectForKey:@"location"];
    NSNumber *latitude = [coordinates objectAtIndex:0];
    NSNumber *longitude = [coordinates objectAtIndex:1];
    self.location = [[[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue] autorelease];  
    return self;
}

- (void)dealloc
{
   // NSLog(@"Deallocating Photo");
    [_location release];
    [_caption release];
    [_urlThumbnail release];
    [_urlLarge release];
    [_photoId release];
    [super dealloc];
}
@end

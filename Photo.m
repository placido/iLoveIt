//
//  Photo.m
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "TableAppAppDelegate.h"

@implementation Photo

@synthesize photoId=_photoId;
@synthesize caption=_caption;
@synthesize urlThumbnail=_urlThumbnail;
@synthesize urlLarge=_urlLarge;
@synthesize thumbnail=_thumbnail;
@synthesize location=_location;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) initWithPhotoId:(NSString *)myPhotoId caption:(NSString *)myCaption x:(int)myX y:(int)myY location:(CLLocation *)myLocation
{
    self = [self init];
    NSLog(@"Initialising photo %@ with caption %@", self, myCaption);
    self.photoId = myPhotoId;
    self.caption = myCaption;
    NSString *baseUrl = [NSString stringWithFormat:@"http://d1w26viojcn1vr.cloudfront.net/uploads/%@/", self.photoId];
    self.urlThumbnail = [NSURL URLWithString:[baseUrl stringByAppendingString:@"small.jpeg"]];
    self.urlLarge = [NSURL URLWithString:[baseUrl stringByAppendingString:@"large.jpeg"]];
    self.thumbnail = [[Thumbnail alloc] initWithX:myX y:myY photo:self];
    self.location = myLocation;
    return self;
}

- (void) loadThumbnail
{
    [self.thumbnail.spinner startAnimating];
    // Load URL asynchronously
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] 
                                        initWithTarget:self
                                        selector:@selector(loadImageAtUrl:) 
                                        object:self.urlThumbnail];
    [queue addOperation:operation]; 
    [operation release]; 
}

-(void)loadImageAtUrl:(NSURL*)url {
    NSLog(@"Loading %@", url.absoluteString);
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:url];
    UIImage* image = [[[UIImage alloc] initWithData:imageData] autorelease];
    [imageData release];
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
}

-(void)displayImage:(UIImage *)image {
    [self.thumbnail setImage:image];
   // [image release]; 
    NSLog(@"Added image view");    
}

- (void)dealloc
{
    [_location release];
    [_caption release];
    [_urlThumbnail release];
    [_urlLarge release];
    [_thumbnail release];
    [_photoId release];
    [super dealloc];
}
@end

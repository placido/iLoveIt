//
//  DetailViewController.m
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "TableAppAppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@implementation DetailViewController
@synthesize scrollView = _scrollView;
@synthesize imageView=_imageView;
@synthesize caption=_caption;
@synthesize spinner=_spinner;
@synthesize photo=_photo;
@synthesize mapView=_mapView;
@synthesize pin=_pin;
@synthesize request=_request;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"Initialising DetailViewController");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Create the scrollView
        UIScrollView *myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        // myScrollView.delegate = self;
        myScrollView.showsVerticalScrollIndicator = YES;
        myScrollView.showsHorizontalScrollIndicator = YES;
        myScrollView.userInteractionEnabled = YES;
        myScrollView.scrollEnabled = YES;
        myScrollView.bounces = YES;
        myScrollView.backgroundColor = [UIColor blackColor];
        [myScrollView setContentSize:CGSizeMake(320, 740)];
        self.scrollView = myScrollView;
        [self.view addSubview:self.scrollView];
                
        // Create the spinner
        UIActivityIndicatorView *mySpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        mySpinner.center = CGPointMake(160, 160);
        mySpinner.hidesWhenStopped = YES;
        [mySpinner startAnimating];
        self.spinner = mySpinner;
        
        // Create the image view
        UIImageView *myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        self.imageView = myImageView;
        
        // Create the UILabel caption
        UILabel *myCaption = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, 280, 20)];
        myCaption.text = @"Caption goes here";
        myCaption.textColor = [UIColor whiteColor];
        myCaption.backgroundColor = [UIColor clearColor];
        self.caption = myCaption;
        
        // Create the map
        MKMapView *myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 360, 320, 320)];
        self.mapView = myMapView;
        
        // Create the pin
        MapPin *myPin = [[MapPin alloc] init];
        self.pin = myPin;
        [self.mapView addAnnotation:self.pin];
        
        // Attach the elements to the scrollView
        [self.scrollView addSubview:self.spinner];
        [self.scrollView addSubview:self.caption];
        [self.scrollView addSubview:self.mapView];
        [self.scrollView addSubview:self.imageView];

        // release 
        [myImageView release];
        [myScrollView release];
        [mySpinner release];
        [myCaption release];
        [myMapView release];
        [myPin release];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)setThePhoto:(Photo*)myPhoto 
{
    self.photo = myPhoto;
    self.caption.text = self.photo.caption;
    NSLog(@"Showing detailed view of %@", self.photo.caption);
    
    [self.imageView setHidden:YES];
    [self.spinner startAnimating];
    
    // Center and zoom the map
    // TO DO: Zoom out a bit if bestEffortLocation and photo.location are almost identical
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    CLLocationCoordinate2D southWest = delegate.localisation.bestEffortLocation.coordinate;
    CLLocationCoordinate2D northEast = southWest;
    southWest.latitude = MIN(southWest.latitude, self.photo.location.coordinate.latitude);
    southWest.longitude = MIN(southWest.longitude, self.photo.location.coordinate.longitude);
    northEast.latitude = MAX(northEast.latitude, self.photo.location.coordinate.latitude);
    northEast.longitude = MAX(northEast.longitude, self.photo.location.coordinate.longitude);
    CLLocation *locSouthWest = [[CLLocation alloc] initWithLatitude:southWest.latitude longitude:southWest.longitude];
    CLLocation *locNorthEast = [[CLLocation alloc] initWithLatitude:northEast.latitude longitude:northEast.longitude];
    // This is a diag distance (if you wanted tighter you could do NE-NW or NE-SE)
    CLLocationDistance meters = [locSouthWest distanceFromLocation:locNorthEast];
    MKCoordinateRegion region;
    region.center.latitude = (southWest.latitude + northEast.latitude) / 2.0;
    region.center.longitude = (southWest.longitude + northEast.longitude) / 2.0;
    region.span.latitudeDelta = meters / 111319.5;
    region.span.longitudeDelta = 0.0;
    [self.mapView setRegion:region animated:YES];
    //_savedRegion = [_mapView regionThatFits:region];
    //[_mapView setRegion:_savedRegion animated:YES];
    [locSouthWest release];
    [locNorthEast release];
    
    // Set the pin   
    [self.pin setCoordinate:self.photo.location.coordinate title:self.photo.caption subtitle:@""];
    
    // Load URL asynchronously
    ASIHTTPRequest *theRequest = [ASIHTTPRequest requestWithURL:self.photo.urlLarge];
    [theRequest setDelegate:self];
    [theRequest startAsynchronous];
    [theRequest setTimeOutSeconds:15];
    [theRequest setNumberOfTimesToRetryOnTimeout:2];
    self.request = theRequest; 
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest
{
    NSError *error = [request error];
    NSLog(@"Large image request failed: %@", [error localizedFailureReason]);
    [self.spinner stopAnimating];
}

- (void)requestFinished:(ASIHTTPRequest *)theRequest
{    
    NSData *imageData = [theRequest responseData];
    UIImage* image = [[UIImage alloc] initWithData:imageData];
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
}

-(void)displayImage:(UIImage *)image {
    [self.spinner stopAnimating];
    // set new image
    [self.imageView setImage:image];
    [self.imageView setHidden:NO];
}

#pragma mark - View lifecycle

-(void)viewDidAppear:(BOOL)animated {
    [self.mapView setShowsUserLocation:YES]; // turn on location service when view in sight
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.mapView setShowsUserLocation:NO]; // turn off location service when view not in sight
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    NSLog(@"Deallocating DetaiViewController");
    [_request clearDelegatesAndCancel];
    [_pin release];
    [_scrollView release];
    [_mapView release];
    [_imageView release];
    [_caption release];
    [_spinner release];
    [_photo release];
    [super dealloc];
}


@end

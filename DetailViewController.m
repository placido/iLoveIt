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
        myMapView.showsUserLocation = YES;
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
    
    // Center the map
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005f, 0.005f);  // Hard-coded zoom level
    MKCoordinateRegion region = MKCoordinateRegionMake([self.photo.location coordinate], span);
    [self.mapView setRegion:region animated:YES];
    
    // Set the pin   
    [self.pin setCoordinate:self.photo.location.coordinate title:self.photo.caption subtitle:@""];
    
    // Load URL asynchronously
    ASIHTTPRequest *theRequest = [ASIHTTPRequest requestWithURL:self.photo.urlLarge];
    [theRequest setDelegate:self];
    [theRequest startAsynchronous];
    [theRequest setTimeOutSeconds:15];
    [theRequest setNumberOfTimesToRetryOnTimeout:2];
    self.request = theRequest; 

   // NSOperationQueue *queue = [NSOperationQueue new];
   // NSInvocationOperation *operation = [[NSInvocationOperation alloc] 
  //                                      initWithTarget:self
  //                                      selector:@selector(loadImageAtUrl:) 
  //                                      object:self.photo.urlLarge];
  //  [queue addOperation:operation]; 
  //  [operation release];
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

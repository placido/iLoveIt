//
//  DetailViewController.m
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "TableAppAppDelegate.h"

@implementation DetailViewController
@synthesize scrollView = _scrollView;
@synthesize imageView=_imageView;
@synthesize caption=_caption;
@synthesize spinner=_spinner;
@synthesize photo=_photo;
@synthesize mapView=_mapView;
@synthesize pinView=_pinView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
        [myScrollView release];
        
        // Create the spinner
        UIActivityIndicatorView *mySpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        mySpinner.center = CGPointMake(160, 160);
        mySpinner.hidesWhenStopped = YES;
        [mySpinner startAnimating];
        self.spinner = mySpinner;
        [mySpinner release];
        
        // Create the UILabel caption
        UILabel *myCaption = [[UILabel alloc] initWithFrame:CGRectMake(10, 330, 280, 20)];
        myCaption.text = @"Caption goes here";
        myCaption.textColor = [UIColor whiteColor];
        myCaption.backgroundColor = [UIColor clearColor];
        self.caption = myCaption;
        [myCaption release];
        
        // Create the map
        MKMapView *myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 360, 320, 320)];
        self.mapView = myMapView;
        [myMapView release];
        
        // Create the pin
        MKPinAnnotationView *myPinView = [[MKPinAnnotationView alloc] init];
        self.pinView = myPinView;
        [myPinView release];
        
        // Attach the elements to the scrollView
        [self.scrollView addSubview:self.spinner];
        [self.scrollView addSubview:self.caption];
        [self.scrollView addSubview:self.mapView];

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
    
    // remove existing image view
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        [self.imageView release];
        [self.spinner startAnimating];
    }
    
    // Center the map
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005f, 0.005f);  // Hard-coded zoom level
    MKCoordinateRegion region = MKCoordinateRegionMake([self.photo.location coordinate], span);
    [self.mapView setRegion:region animated:YES];
    // TO DO: SET THE PIN    
    
    // Load URL asynchronously
    NSOperationQueue *queue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] 
                                        initWithTarget:self
                                        selector:@selector(loadImageAtUrl:) 
                                        object:self.photo.urlLarge];
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

    // TO DO: Check memory allocation. SHould init the object once and just use the setImage selector
    self.imageView = [[UIImageView alloc]initWithImage:image];
    self.imageView.frame =  CGRectMake(0, 0, 320, 320);
    [self.scrollView addSubview:self.imageView];
    [self.spinner stopAnimating];

    NSLog(@"Added image view");    
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
    NSLog(@"Deallocating");
    [_pinView release];
    [_scrollView release];
    [_mapView release];
    [_imageView release];
    [_caption release];
    [_spinner release];
    [_photo release];
    [super dealloc];
}


@end

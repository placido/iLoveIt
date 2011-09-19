//
//  Thumbnail.m
//  TableApp
//
//  Created by Francois Chabat on 03/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Thumbnail.h"
#import "TableAppAppDelegate.h"
#import "ASIHTTPRequest.h"

@implementation Thumbnail
@synthesize imageView=_imageView;
@synthesize spinner=_spinner;
@synthesize button=_button;
@synthesize x=_x;
@synthesize y=_y;
@synthesize photo=_photo;
@synthesize request=_request;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithX:(int)myX y:(int)myY photo:(Photo*)myPhoto {
    self = [self init];
    self.x = myX;
    self.y = myY;
    self.photo = myPhoto;

    // Create image
    UIImageView *myImageView = [[UIImageView alloc] init];
    myImageView.frame = CGRectMake(self.x, self.y, 159, 159);
    self.imageView = myImageView;
    [myImageView release];
    
    // Create spinner
    UIActivityIndicatorView *mySpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    mySpinner.center = CGPointMake(myX+80, myY+80);
	mySpinner.hidesWhenStopped = YES;
    self.spinner = mySpinner;
    [mySpinner release];
    
    // Create button
    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    myButton.frame = CGRectMake(myX, myY, 159, 159);
    [myButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.button = myButton;
    
    // Add spinner and button to ScrollView
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    UIScrollView *theScrollView = delegate.gridViewController.scrollView;
    [theScrollView addSubview:self.spinner];  
    [theScrollView addSubview:self.button];

    return self; 
}

-(void)moveToX:(int)myX y:(int)myY;
{
    self.x = myX;
    self.y = myY;
    self.spinner.center = CGPointMake(myX+80, myY+80);
    self.button.frame = CGRectMake(myX, myY, 159, 159);
    self.imageView.frame = CGRectMake(myX, myY, 159, 159);
}

- (void)load
{
    [self.spinner startAnimating];
    ASIHTTPRequest *theRequest = [ASIHTTPRequest requestWithURL:self.photo.urlThumbnail];
    [theRequest setDelegate:self];
    [theRequest setTimeOutSeconds:15];
    [theRequest setNumberOfTimesToRetryOnTimeout:2];
    [theRequest setShouldAttemptPersistentConnection:YES];
    [theRequest startAsynchronous];
    self.request = theRequest; 
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest
{
    NSError *error = [request error];
    NSLog(@"Thumbnail request failed: %@", [error localizedFailureReason]);
    [self.spinner stopAnimating];
}

- (void)requestFinished:(ASIHTTPRequest *)theRequest
{    
    NSData *imageData = [theRequest responseData];
    UIImage* image = [[[UIImage alloc] initWithData:imageData] autorelease];
    [self performSelectorOnMainThread:@selector(displayImage:) withObject:image waitUntilDone:NO];
}

- (void)displayImage:(UIImage *)image {
    [self.imageView setImage:image];
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    UIScrollView *scrollView = delegate.gridViewController.scrollView;
    [scrollView addSubview:self.imageView];
    [self.spinner stopAnimating];
   // NSLog(@"Added image view");    
}

- (IBAction)buttonClicked:(id)sender
{
    Photo *myPhoto = (Photo *)(self.photo);
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.detailViewController setThePhoto:myPhoto];
    [delegate.navigationController pushViewController:delegate.detailViewController animated:YES];
}

- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    [_imageView release];
    [_spinner release];
    [_button release];
    [_photo release];
    [super dealloc];
}
@end

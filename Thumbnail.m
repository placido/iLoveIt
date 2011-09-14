//
//  Thumbnail.m
//  TableApp
//
//  Created by Francois Chabat on 03/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Thumbnail.h"
#import "TableAppAppDelegate.h"

@implementation Thumbnail
@synthesize imageView=_imageView;
@synthesize spinner=_spinner;
@synthesize button=_button;
@synthesize x=_x;
@synthesize y=_y;
@synthesize photo=_photo;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithX:(int)myX y:(int)myY photo:(id)myPhoto {
    self = [self init];
    self.x = myX;
    self.y = myY;
    self.photo = myPhoto;

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
    [myButton release];
    
    // Add spinner and button to ScrollView
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    UIScrollView *theScrollView = delegate.gridViewController.scrollView;
    [theScrollView addSubview:self.spinner];  
    [theScrollView addSubview:self.button];
    NSLog(@"Added spinner and button");    

    return self; 
}


- (IBAction)buttonClicked:(id)sender
{
    Photo *myPhoto = (Photo *)(self.photo);
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.detailViewController setThePhoto:myPhoto];
    [delegate.navigationController pushViewController:delegate.detailViewController animated:YES];

}

- (void)setImage:(UIImage *)image {
    self.imageView = [[UIImageView alloc]initWithImage:image];
    // self.imageView.center = CGPointMake(self.x, self.y);
    self.imageView.frame = CGRectMake(self.x, self.y, 159, 159);
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    UIScrollView *scrollView = delegate.gridViewController.scrollView;
    [scrollView addSubview:self.imageView];
    [self.spinner stopAnimating];
}

- (void)dealloc
{
    [_imageView release];
    [_spinner release];
    [_button release];
    [_photo release];
    [super dealloc];
}
@end

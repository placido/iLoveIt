//
//  GridViewController.m
//  TableApp
//
//  Created by Francois Chabat on 24/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "TableAppAppDelegate.h"
#import "GridViewController.h"

@implementation GridViewController
@synthesize scrollView = _scrollView;
@synthesize spinner=_spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"Init view");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIScrollView *myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        // myScrollView.delegate = self;
        myScrollView.showsVerticalScrollIndicator = YES;
        myScrollView.showsHorizontalScrollIndicator = YES;
        myScrollView.userInteractionEnabled = YES;
        myScrollView.scrollEnabled = YES;
        myScrollView.bounces = YES;
        myScrollView.backgroundColor = [UIColor blackColor];
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
        [self.view addSubview:self.spinner];

    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSLog(@"Loaded view");
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    NSLog(@"Unloaded view");
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
    [_spinner release];
    [_scrollView release];
    [super dealloc];
}

@end

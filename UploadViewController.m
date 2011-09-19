//
//  UploadViewController.m
//  TableApp
//
//  Created by Francois Chabat on 12/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UploadViewController.h"
#import "TableAppAppDelegate.h"
#import "ASIFormDataRequest.h"

@implementation UploadViewController
@synthesize imageView = _imageView;
@synthesize caption = _caption;
@synthesize neighbourhood = _neighbourhood;
@synthesize send = _send;
@synthesize progress = _progress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.view.backgroundColor = [UIColor blackColor];

        // Initialise caption input field
        CGRect frame = CGRectMake(10,10,230,30);
        UITextField *aCaption = [[UITextField alloc] initWithFrame:frame];
        aCaption.borderStyle = UITextBorderStyleRoundedRect;
        aCaption.textColor = [UIColor blackColor];
        aCaption.font = [UIFont systemFontOfSize:17.0];
        aCaption.placeholder = @"Enter a title...";
        // aCaption.autocorrectionType = UITextAutoCorrectionTypeNo;
        aCaption.keyboardType = UIKeyboardTypeDefault;
        aCaption.returnKeyType = UIReturnKeyDone;
        aCaption.clearButtonMode = UITextFieldViewModeWhileEditing;
        aCaption.delegate = self;
        self.caption = aCaption;
        [aCaption release];
        [self.view addSubview:self.caption];
        
        // Initialise progress bar
        UIProgressView *myProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 50, 300, 20)];
        myProgress.progressViewStyle = UIProgressViewStyleBar;
        self.progress = myProgress;
        [self.view addSubview:self.progress];
        [myProgress release];
        
        // Initialise picker
       // UIPickerView *myNeighbourhood = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 40, 320, 50)];
       // myNeighbourhood.delegate = self; 
       // myNeighbourhood.dataSource = self;
       // self.neighbourhood = myNeighbourhood;
       // [myNeighbourhood release];
       // [self.view addSubview:self.neighbourhood];
        
        // Initialise button
        UIButton *mySend= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        mySend.frame = CGRectMake(250, 10, 60, 30);
        [mySend setTitle:@"Send" forState:UIControlStateNormal];
        [mySend addTarget:self action:@selector(sendPhoto) forControlEvents:UIControlEventTouchUpInside];
        self.send = mySend;
        [self.view addSubview:self.send];
        
        // Initialise image view
        UIImageView *anImageView = [[UIImageView alloc] init];
        anImageView.frame =  CGRectMake(0, 80, 320, 320);
        self.imageView = anImageView;
        [anImageView release];
        [self.view addSubview:self.imageView];
        
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    return [delegate.localisation.neighbourhoods count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    return [delegate.localisation.neighbourhoods objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    NSLog(@"Selected %@ at index: %i", [delegate.localisation.neighbourhoods objectAtIndex:row], row);
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 200;
    return sectionWidth;
}

-(void)sendPhoto 
{
    NSLog(@"Sending photo with caption  %@, user %@", self.caption.text, [UIDevice currentDevice].uniqueIdentifier);
    [self.caption resignFirstResponder]; // remove keyboard
    [self.send setHidden:YES]; // remove button
    [self.send setEnabled:NO]; 
    
    // Prepare the HTTP Post request
    NSURL *url = [NSURL URLWithString:@"http://ec2-79-125-90-3.eu-west-1.compute.amazonaws.com:8080/ilove/api/photo"];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    request.delegate = self;
    
    // Pass user and caption
    [request setPostValue:[UIDevice currentDevice].uniqueIdentifier forKey:@"user"];
    [request setPostValue:self.caption.text forKey:@"caption"];
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    // Pass coordindate
    CLLocation *location = delegate.localisation.bestEffortLocation;
    NSString *lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    [request setPostValue:lat forKey:@"lat"];
    [request setPostValue:lng forKey:@"lng"];
    // Pass JPEG image data
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 100);
    [request setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"myPhoto"];

    // Set the progress bar
    [request setUploadProgressDelegate:self.progress];
    
    // Start the asynchronous request
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    NSLog(@"Got response: %@", responseString);
    [request release];
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navigationController popToRootViewControllerAnimated:YES];
    [delegate.localisation startRequest];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Got error: %@", error);
    [request release];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Could not connect to server. Please try again later." 
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navigationController popToRootViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // remove keyboard
    return NO;
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
    [_progress release];
    [_send release];
    [_imageView release];
    [_neighbourhood release];
    [_caption release];
    [super dealloc];
}


@end

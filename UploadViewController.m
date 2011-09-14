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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.view.backgroundColor = [UIColor blackColor];

        // Initialise caption input field
        CGRect frame = CGRectMake(10,10,300,30);
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
        
        // Initialise picker
        UIPickerView *myNeighbourhood = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 50, 150, 30)];
        myNeighbourhood.backgroundColor = [UIColor clearColor];
        myNeighbourhood.delegate = self; 
        myNeighbourhood.showsSelectionIndicator = YES;
       // TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
       // NSMutableArray *neighbourhoods = delegate.localisation.neighbourhoods;
       // for(NSString *name in neighbourhoods) {
       //     NSLog(@"Picker name %@", name);
       // }
        
      //  [[[StatesPickerItem alloc] initWithName:@"Wyoming" value:@"WY" flag:[UIImage imageNamed:@"Wyoming.png"]] autorelease], nil];
       // for (StatesPickerItem *item in pickerItems) {
        //    [mypicker selectRow:[pickerItems indexOfObject:item] inComponent:0 animated:YES];
       // }

        
        self.neighbourhood = myNeighbourhood;
        [myNeighbourhood release];
        // [self.view addSubview:self.neighbourhood];
        
        // Initialise button
        UIButton *mySend= [UIButton buttonWithType:UIButtonTypeRoundedRect];
        mySend.frame = CGRectMake(250, 45, 60, 30);
        [mySend setTitle:@"Send" forState:UIControlStateNormal];
        [mySend addTarget:self action:@selector(sendPhoto) forControlEvents:UIControlEventTouchUpInside];
        self.send = mySend;
        [mySend release];
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

-(void)sendPhoto 
{
    NSLog(@"Sending photo with caption  %@, user %@", self.caption.text, [UIDevice currentDevice].uniqueIdentifier);
    [self.caption resignFirstResponder]; // remove keyboard
    
    // Prepare the HTTP Post request
    NSURL *url = [NSURL URLWithString:@"http://ec2-79-125-90-3.eu-west-1.compute.amazonaws.com:8080/ilove/api/photo"];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:url];
    // Pass user and caption
    [request setPostValue:[UIDevice currentDevice].uniqueIdentifier forKey:@"user"];
    [request setPostValue:self.caption.text forKey:@"caption"];
    TableAppAppDelegate *delegate = (TableAppAppDelegate *)[UIApplication sharedApplication].delegate;
    // Pass coordindates
    CLLocation *location = delegate.localisation.locationManager.location;
    NSString *lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
    [request setPostValue:lat forKey:@"lat"];
    [request setPostValue:lng forKey:@"lng"];
    // Pass JPEG image data
    NSData *imageData = UIImageJPEGRepresentation(self.imageView.image, 100);
    [request setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"myPhoto"];

    // Start the request
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"Response: %@", response);
    }
    [request release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // remove keyboard
    return NO;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSUInteger numRows = 5;
    return numRows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = [@"" stringByAppendingFormat:@"%d",row];
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 150;
    return sectionWidth;
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
    [_send release];
    [_imageView release];
    [_neighbourhood release];
    [_caption release];
    [super dealloc];
}


@end

//
//  TableAppAppDelegate.m
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TableAppAppDelegate.h"
#import "GridViewController.h"
#import "UploadViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"

@implementation TableAppAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize gridViewController = _gridViewController;
@synthesize detailViewController = _detailViewController;
@synthesize uploadViewController = _uploadViewController;
@synthesize imagePickerController = _imagePickerController;
@synthesize actionSheet = _actionSheet;
@synthesize localisation = _localisation;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Create grid view
    GridViewController *aGridViewController = [[GridViewController alloc] initWithNibName:@"GridViewController" bundle:nil];
    aGridViewController.navigationItem.title = @"I love it around here";
    self.gridViewController = aGridViewController;

    // Create navigation controller
    UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:aGridViewController];
    [aNavigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController = aNavigationController;
    
    // Create camera button and assign it to navigation item of grid view
    UIBarButtonItem *aCameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(choosePhoto)];
    self.gridViewController.navigationItem.rightBarButtonItem = aCameraButton;
    
    // Create the action sheet
    UIActionSheet *anActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo", @"Choose photo", nil];
    self.actionSheet = anActionSheet;
       
    // Create localisation
    Localisation *aLocalisation = [[Localisation alloc] init];
    self.localisation = aLocalisation;
    
    // Turn HTTP cacheing on
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
    
    // Release initial instances
    [aLocalisation release];
    [aCameraButton release];
    [anActionSheet release];
    [aNavigationController release];
    [aGridViewController release];

    // Set the view
    [self.window addSubview:self.navigationController.view];
    [self.window makeKeyAndVisible];
    
    // The application gets started in the DidBecomeActive 

    return YES;
}

- (void)choosePhoto
{
    // show the action sheet
    [self.actionSheet showInView:self.gridViewController.scrollView];
    // free memory: release the detail view
    self.detailViewController = nil;
    // create image picker controller
    UIImagePickerController *anImagePickerController = [[UIImagePickerController alloc] init];
    anImagePickerController.delegate = self;
    anImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    anImagePickerController.allowsEditing = YES;
    self.imagePickerController = anImagePickerController;
    [anImagePickerController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex) {
        case 0:
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.gridViewController presentModalViewController:self.imagePickerController animated:YES];
            break;
        case 1:
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.gridViewController presentModalViewController:self.imagePickerController animated:YES];
            break;
        case 2:
            self.imagePickerController = nil;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"Got new image");
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [self.gridViewController dismissModalViewControllerAnimated:YES];
    self.imagePickerController = nil;    
    
    // Create upload view
    if (self.uploadViewController == nil) {
        UploadViewController *anUploadViewController = [[UploadViewController alloc] initWithNibName:@"UploadViewController" bundle:nil];
        [anUploadViewController.imageView setImage:image];
        self.uploadViewController = anUploadViewController;
        [anUploadViewController release];
    }
    [self.navigationController pushViewController:self.uploadViewController animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Cancelled");
    [self.gridViewController dismissModalViewControllerAnimated:YES];
    self.imagePickerController = nil;    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"applicationDidBecomeActive invoked: start localisation");
    [self.localisation startLocalisation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_localisation release];
    [_actionSheet release];
    [_imagePickerController release];
    [_uploadViewController release];
    [_gridViewController release];
    [_detailViewController release];
    [_navigationController release];
    [_window release];
    [super dealloc];
}

@end

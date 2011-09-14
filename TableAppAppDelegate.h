//
//  TableAppAppDelegate.h
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewController.h"
#import "DetailViewController.h"
#import "UploadViewController.h"
#import "Localisation.h"

@interface TableAppAppDelegate : NSObject <UIApplicationDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
{
    @public
    UIWindow *window;
    UINavigationController *navigationController;
    GridViewController *gridViewController;
    DetailViewController *detailViewController;
    UploadViewController *uploadViewController;
    UIImagePickerController *imagePickerController;
    UIActionSheet *actionSheet;
    Localisation *localisation;
}

-(void) choosePhoto;
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet GridViewController *gridViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet UploadViewController *uploadViewController;
@property (nonatomic, retain) IBOutlet UIImagePickerController *imagePickerController;
@property (nonatomic, retain) IBOutlet UIActionSheet *actionSheet;
@property (nonatomic, retain) Localisation* localisation;

@end

//
//  UploadViewController.h
//  TableApp
//
//  Created by Francois Chabat on 12/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadViewController : UIViewController <UIPickerViewDelegate>
{
    UIImageView *imageView;
    UITextField *caption;
    UIPickerView *neighbourhood;
    UIButton *send;
}
-(void)sendPhoto;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UITextField *caption;
@property (nonatomic, retain) IBOutlet UIPickerView *neighbourhood;
@property (nonatomic, retain) IBOutlet UIButton *send;

@end

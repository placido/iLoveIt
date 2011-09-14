//
//  Thumbnail.h
//  TableApp
//
//  Created by Francois Chabat on 03/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Thumbnail : NSObject
{
    UIImageView *imageView;
    UIActivityIndicatorView *spinner;
    UIButton *button;
    int x;
    int y;
    id photo;
}

-(id)initWithX:(int)myX y:(int)myY photo:(id)myPhoto;
-(void)setImage:(UIImage *)image;
-(IBAction)buttonClicked:(id)sender;

@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIButton *button;
@property(assign) int x;
@property(assign) int y;
@property(assign) id photo;

@end
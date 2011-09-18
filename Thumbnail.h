//
//  Thumbnail.h
//  TableApp
//
//  Created by Francois Chabat on 03/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"
#import "ASIHTTPRequest.h"

@interface Thumbnail : NSObject
{
    Photo* photo;
    UIImageView *imageView;
    UIActivityIndicatorView *spinner;
    UIButton *button;
    int x;
    int y;
    ASIHTTPRequest *request;
}

-(id)initWithX:(int)myX y:(int)myY photo:(Photo*)myPhoto;
-(void)moveToX:(int)myX y:(int)my;
-(void)load;
-(IBAction)buttonClicked:(id)sender;

@property(nonatomic, retain) Photo* photo;
@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) UIActivityIndicatorView *spinner;
@property(nonatomic, retain) UIButton *button;
@property(assign) int x;
@property(assign) int y;
@property(nonatomic, retain) ASIHTTPRequest* request;

@end
//
//  Photo.h
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Thumbnail.h"

@interface Photo : NSObject
{
    NSString *photoId;
    NSString *caption;
    NSURL *urlThumbnail;
    NSURL *urlLarge;
    Thumbnail *thumbnail;
    CLLocation *location;
}

-(id)initWithPhotoId:(NSString*)photoId caption:(NSString*)caption x:(int)myX y:(int)myY location:(CLLocation*)location;
-(void)loadThumbnail;

@property(nonatomic, retain) NSString *photoId;
@property(nonatomic, retain) NSString *caption;
@property(nonatomic, retain) NSURL *urlThumbnail;
@property(nonatomic, retain) NSURL *urlLarge;
@property(nonatomic, retain) Thumbnail *thumbnail;
@property(nonatomic, retain) CLLocation *location;

@end



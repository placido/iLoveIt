//
//  DetailViewController.h
//  TableApp
//
//  Created by Francois Chabat on 21/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "Photo.h"
#import "MapPin.h"
#import <MapKit/MapKit.h>
#import "ASIHTTPRequest.h"

@interface DetailViewController : UIViewController
{
    UIScrollView *scrollView;
    UIImageView *imageView;
    UILabel *caption;
    UIActivityIndicatorView *spinner;
    MKMapView *mapView;
    MapPin *pin;
    Photo *photo;
    ASIHTTPRequest *request;
}

-(void)setThePhoto:(Photo *)photo;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *caption;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) MapPin *pin;
@property(nonatomic, retain) ASIHTTPRequest* request;

@end

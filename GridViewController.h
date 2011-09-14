//
//  GridViewController.h
//  TableApp
//
//  Created by Francois Chabat on 24/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface GridViewController : UIViewController 
{
    UIScrollView *scrollView;
    UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@end

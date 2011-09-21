//
//  Constants.m
//  TableApp
//
//  Created by Francois Chabat on 21/09/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@implementation Constants
NSString * const apiUrl = @"http://ec2-79-125-90-3.eu-west-1.compute.amazonaws.com:8080/ilove/api/";
NSString * const cdnUrl = @"http://d1w26viojcn1vr.cloudfront.net/uploads";

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

@end
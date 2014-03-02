//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by Derek Bassett on 3/1/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationDetailsViewController : UITableViewController

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CLPlacemark *placemark;

@end

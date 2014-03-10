//
//  LocationsViewController.h
//  MyLocations
//
//  Created by Derek Bassett on 3/9/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

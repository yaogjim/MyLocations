//
//  FirstViewController.m
//  MyLocations
//
//  Created by Derek Bassett on 3/1/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "CurrentLocationViewController.h"

@interface CurrentLocationViewController ()

@end

@implementation CurrentLocationViewController
{
  CLLocationManager *_locationManager;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder])) {
    _locationManager = [[CLLocationManager alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getLocation:(id)sender
{
  _locationManager.delegate = self;
  _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"didFailWithError %@", error);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation *newLocation = [locations lastObject];

  NSLog(@"didUpdateLocations %@", newLocation);
}

@end

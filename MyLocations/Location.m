//
//  Location.m
//  MyLocations
//
//  Created by Derek Bassett on 3/3/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic category;
@dynamic date;
@dynamic latitude;
@dynamic locationDescription;
@dynamic longitude;
@dynamic placemark;

- (CLLocationCoordinate2D)coordinate
{
  return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString *)title
{
  if ([self.locationDescription length] > 0) {
    return self.locationDescription;
  } else {
    return @"(No Description)";
  }
}

- (NSString *)subtitle
{
  return self.category;
}

@end

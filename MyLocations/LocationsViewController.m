//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Derek Bassett on 3/9/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "LocationsViewController.h"
#import "location.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController
{
  NSArray *_locations;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
  [fetchRequest setEntity:entity];

  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
  [fetchRequest setSortDescriptors:@[sortDescriptor]];

  NSError *error;
  NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  if(foundObjects == nil){
    FATAL_CORE_DATA_ERROR(error);
    return;
  }

  _locations = foundObjects;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];

  Location *location = _locations[indexPath.row];

  UILabel *descriptionLabel = (UILabel *)[cell viewWithTag:100];
  descriptionLabel.text = location.locationDescription;

  UILabel *addressLabel = (UILabel *)[cell viewWithTag:101];
  addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                       location.placemark.subThoroughfare,
                       location.placemark.thoroughfare,
                       location.placemark.locality];
    
  return cell;
}

@end

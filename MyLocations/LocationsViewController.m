//
//  LocationsViewController.m
//  MyLocations
//
//  Created by Derek Bassett on 3/9/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "LocationsViewController.h"
#import "Location.h"
#import "LocationCell.h"
#import "locationDetailsViewController.h"

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
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"EditLocation"]) {
    UINavigationController *navigationController = segue.destinationViewController;

    LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;

    controller.managedObjectContext = self.managedObjectContext;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Location *location = _locations[indexPath.row];
    controller.locationToEdit = location;
  }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  LocationCell *locationCell = (LocationCell *)cell;
  Location *location = _locations[indexPath.row];

  if ([location.locationDescription length] > 0) {
    locationCell.descriptionLabel.text = location.locationDescription;
  } else {
    locationCell.descriptionLabel.text = @"(No Description)";
  }

  if (location.placemark != nil) {
    locationCell.addressLabel.text = [NSString stringWithFormat:@"%@ %@, %@",
                       location.placemark.subThoroughfare,
                       location.placemark.thoroughfare,
                       location.placemark.locality];
  } else {
    locationCell.addressLabel.text = [NSString stringWithFormat: @"Lat: %.8f, Long: %.8f",
                                      [location.latitude doubleValue],
                                      [location.longitude doubleValue]];
  }

}

@end

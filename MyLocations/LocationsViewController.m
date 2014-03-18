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

@interface LocationsViewController ()<NSFetchedResultsControllerDelegate>

@end

@implementation LocationsViewController
{
  NSFetchedResultsController *_fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController
{
  if (_fetchedResultsController == nil) {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptor =
      [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];

    [fetchRequest setFetchBatchSize:20];

    _fetchedResultsController =
        [[NSFetchedResultsController alloc]
          initWithFetchRequest:fetchRequest
          managedObjectContext:self.managedObjectContext
          sectionNameKeyPath:nil
          cacheName:@"Locations"];

    _fetchedResultsController.delegate = self;
  }
  return _fetchedResultsController;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self performFetch];
}

- (void)performFetch
{
  [NSFetchedResultsController deleteCacheWithName:@"Locations"];

  NSError *error;
  if(![self.fetchedResultsController performFetch:&error]){
    FATAL_CORE_DATA_ERROR(error);
    return;
  }
}

- (void)dealloc
{
  _fetchedResultsController.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location"];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  LocationCell *locationCell = (LocationCell *)cell;
  Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"EditLocation"]) {
    UINavigationController *navigationController = segue.destinationViewController;

    LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;

    controller.managedObjectContext = self.managedObjectContext;

    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    controller.locationToEdit = location;
  }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent: (NSFetchedResultsController *)controller
{
  NSLog(@"*** controllerWillChangeContent"); [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  switch (type) {
    case NSFetchedResultsChangeInsert:
      NSLog(@"*** NSFetchedResultsChangeInsert (object)");
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeDelete:
      NSLog(@"*** NSFetchedResultsChangeDelete (object)");
      [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeUpdate:
      NSLog(@"*** NSFetchedResultsChangeUpdate (object)");
      [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
    case NSFetchedResultsChangeMove:
      NSLog(@"*** NSFetchedResultsChangeMove (object)");
      [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                            withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
  switch (type) {
    case NSFetchedResultsChangeInsert:
      NSLog(@"*** NSFetchedResultsChangeInsert (section)");
      [self.tableView insertSections:[NSIndexSet
                                      indexSetWithIndex:sectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
      break;
    case NSFetchedResultsChangeDelete:
      NSLog(@"*** NSFetchedResultsChangeDelete (section)");
      [self.tableView deleteSections:[NSIndexSet
                                      indexSetWithIndex:sectionIndex]
                    withRowAnimation:UITableViewRowAnimationFade];
    break;
  }
}

- (void)controllerDidChangeContent:
  (NSFetchedResultsController *)controller
{
  NSLog(@"*** controllerDidChangeContent");
  [self.tableView endUpdates];
}

@end

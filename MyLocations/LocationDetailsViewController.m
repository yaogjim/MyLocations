//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by Derek Bassett on 3/1/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "LocationDetailsViewController.h"

@interface LocationDetailsViewController ()

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation LocationDetailsViewController

- (IBAction)done:(id)sender
{
  [self closeScreen];
}

- (IBAction)cancel:(id)sender
{
  [self closeScreen];
}

- (void)closeScreen
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.descriptionTextView.text = @"";
  self.categoryLabel.text = @"";

  self.latitudeLabel.text = [NSString stringWithFormat: @"%.8f", self.coordinate.latitude];
  self.longitudeLabel.text = [NSString stringWithFormat: @"%.8f", self.coordinate.longitude];

  if (self.placemark != nil) {
    self.addressLabel.text = [self stringFromPlacemark:self.placemark];
  } else {
    self.addressLabel.text = @"No Address Found";
  }

  self.dateLabel.text = [self formatDate:[NSDate date]];
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
  return [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@",
          thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
          thePlacemark.locality, thePlacemark.administrativeArea,
          thePlacemark.postalCode, thePlacemark.country];
}

- (NSString *)formatDate:(NSDate *)theDate
{
  static NSDateFormatter * formatter = nil;
  if(formatter == nil) {
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
  }
  return [formatter stringFromDate:theDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 && indexPath.row == 0){
    return 88;
  } else if (indexPath.section == 2 && indexPath.row == 2){

    CGRect rect = CGRectMake(100, 10, 205, 10000);
    self.addressLabel.frame = rect;
    [self.addressLabel sizeToFit];

    rect.size.height = self.addressLabel.frame.size.height;
    self.addressLabel.frame = rect;

    return self.addressLabel.frame.size.height + 20;
  } else {
    return 44;
  }
}
@end

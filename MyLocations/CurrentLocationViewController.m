//
//  FirstViewController.m
//  MyLocations
//
//  Created by Derek Bassett on 3/1/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "LocationDetailsViewController.h"
#import "NSMutableString+AddText.h"

@interface CurrentLocationViewController ()
  <UITabBarControllerDelegate>

@end

@implementation CurrentLocationViewController
{
  CLLocationManager *_locationManager;
  CLLocation *_location;

  BOOL _updatingLocation;
  NSError *_lastLocationError;

  CLGeocoder *_geocoder;
  CLPlacemark *_placemark;
  BOOL _performingReverseGeocoding;
  NSError *_lastGeocodingError;

  UIButton *_logoButton;
  BOOL _logoVisible;

  UIActivityIndicatorView *_spinner;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  if ((self = [super initWithCoder:aDecoder])) {
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.tabBarController.delegate = self;
  self.tabBarController.tabBar.translucent = NO;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  [self updateLabels];
  [self configureGetButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getLocation:(id)sender
{
  if(_logoVisible) {
    [self hideLogoView];
  }

  if(_updatingLocation) {
    [self stopLocationManager];
  } else {
    _location = nil;
    _lastLocationError = nil;
    _placemark = nil;
    _lastGeocodingError = nil;

    [self startLocationManager];
  }

  [self updateLabels];
  [self configureGetButton];
}

- (void)hideLogoView
{
  if (!_logoVisible) {
    return;
  }

  _logoVisible = NO;
  self.containerView.hidden = NO;

  self.containerView.center = CGPointMake(
                                          self.view.bounds.size.width * 2.0f,
                                          40.0f + self.containerView.bounds.size.height / 2.0f);

  CABasicAnimation *panelMover = [CABasicAnimation animationWithKeyPath:@"position"];
  panelMover.removedOnCompletion = NO;
  panelMover.fillMode = kCAFillModeForwards;
  panelMover.duration = 0.6;
  panelMover.fromValue = [NSValue valueWithCGPoint:self.containerView.center];
  panelMover.toValue = [NSValue valueWithCGPoint:CGPointMake(160.0f, self.containerView.center.y)];
  panelMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
  panelMover.delegate = self;
  [self.containerView.layer addAnimation:panelMover forKey:@"panelMover"];

  CABasicAnimation *logoMover = [CABasicAnimation animationWithKeyPath: @"position"];
  logoMover.removedOnCompletion = NO;
  logoMover.fillMode = kCAFillModeForwards;
  logoMover.duration = 0.5;
  logoMover.fromValue = [NSValue valueWithCGPoint:_logoButton.center];
  logoMover.toValue = [NSValue valueWithCGPoint: CGPointMake(-160.0f, _logoButton.center.y)];
  logoMover.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
  [_logoButton.layer addAnimation:logoMover forKey:@"logoMover"];

  CABasicAnimation *logoRotator = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  logoRotator.removedOnCompletion = NO;
  logoRotator.fillMode = kCAFillModeForwards;
  logoRotator.duration = 0.5;
  logoRotator.fromValue = @0.0f;
  logoRotator.toValue = @(-2.0f * M_PI);
  logoRotator.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  [_logoButton.layer addAnimation:logoRotator forKey:@"logoRotator"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [self.containerView.layer removeAllAnimations];
  self.containerView.center = CGPointMake(self.view.bounds.size.width / 2.0f,
                                          40.0f + self.containerView.bounds.size.height / 2.0f);

  [_logoButton.layer removeAllAnimations];
  [_logoButton removeFromSuperview];
  _logoButton = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:@"TagLocation"]) {
    UINavigationController *navigationController = segue.destinationViewController;

    LocationDetailsViewController *controller = (LocationDetailsViewController *)navigationController.topViewController;
    controller.coordinate = _location.coordinate;
    controller.placemark = _placemark;
    controller.managedObjectContext = self.managedObjectContext;
  }
}

#pragma mark - Logo View

- (void)showLogoView
{
  if (_logoVisible) {
    return;
  }

  _logoVisible = YES;
  self.containerView.hidden = YES;

  _logoButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_logoButton setBackgroundImage:
    [UIImage imageNamed:@"Logo"] forState:UIControlStateNormal];
  [_logoButton sizeToFit];
  [_logoButton addTarget:self action:@selector(getLocation:)
        forControlEvents:UIControlEventTouchUpInside];
  _logoButton.center = CGPointMake(
                                   self.view.bounds.size.width / 2.0f,
                                   self.view.bounds.size.height / 2.0f - 49.0f);

  [self.view addSubview:_logoButton];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  // NSLog(@"didFailWithError %@", error);

  if (error.code == kCLErrorLocationUnknown) {
    return;
  }

  [self stopLocationManager];
  _lastLocationError = error;

  [self updateLabels];
  [self configureGetButton];
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
  CLLocation *newLocation = [locations lastObject];

  // NSLog(@"didUpdateLocations %@", newLocation);

  if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
    return;
  }

  if (newLocation.horizontalAccuracy < 0) {
    return;
  }

  CLLocationDistance distance = MAXFLOAT;
  if(_location != nil) {
    distance = [newLocation distanceFromLocation:_location];
  }

  if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {

    _lastLocationError = nil;
    _location = newLocation;
    [self updateLabels];

    if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
      // NSLog(@"*** We're done!");
      [self stopLocationManager];
      [self configureGetButton];

      if (distance > 0) {
        _performingReverseGeocoding = NO;
      }
    }

    if(!_performingReverseGeocoding) {
      // NSLog(@"*** Going to geocode");

      _performingReverseGeocoding = YES;

      [_geocoder reverseGeocodeLocation:_location completionHandler:^(NSArray *placemarks, NSError *error) {
        // NSLog (@"*** Found placemarks: %@, error: %@", placemarks, error);

        _lastGeocodingError = error;
        if(error == nil && [placemarks count] > 0) {
          _placemark = [placemarks lastObject];
        } else {
          _placemark = nil;
        }

        _performingReverseGeocoding = NO;
        [self updateLabels];
      }];
    }
  } else if (distance < 1.0) {
    NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
    if(timeInterval > 10) {
      // NSLog(@"*** Force done!");
      [self stopLocationManager];
      [self updateLabels];
      [self configureGetButton];
    }
  }
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark
{
  NSMutableString *line1 = [NSMutableString stringWithCapacity:100];
  [line1 addText:thePlacemark.subThoroughfare withSeparator:@""];
  [line1 addText:thePlacemark.thoroughfare withSeparator:@" "];

  NSMutableString *line2 = [NSMutableString stringWithCapacity:100];
  [line2 addText:thePlacemark.locality withSeparator:@""];
  [line2 addText:thePlacemark.administrativeArea withSeparator:@" "];
  [line2 addText:thePlacemark.postalCode withSeparator:@" "];

  if ([line1 length] == 0){
    [line2 appendString:@"\n "];
    return line2;
  } else {
    [line1 appendString:@"\n"];
    [line1 appendString:line2];
    return line1;
  }
}

- (void) updateLabels
{
  if (_location != nil) {
    self.latitudeLabel.text = [NSString stringWithFormat: @"%.8f", _location.coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat: @"%.8f", _location.coordinate.longitude];
    self.tagButton.hidden = NO;
    self.messageLabel.text = @"";
    if (_placemark != nil) {
      self.addressLabel.text = [self stringFromPlacemark: _placemark];
    } else if (_performingReverseGeocoding) {
      self.addressLabel.text = @"Searching for Address...";
    } else if (_lastGeocodingError != nil) {
      self.addressLabel.text = @"Error Finding Address";
    } else {
      self.addressLabel.text = @"No Address Found";
    }

    self.latitudeTextLabel.hidden = NO;
    self.longitudeTextLabel.hidden = NO;
  } else {
    self.latitudeLabel.text = @"";
    self.longitudeLabel.text = @"";
    self.addressLabel.text = @"";
    self.tagButton.hidden = YES;

    NSString *statusMessage;
    if (_lastLocationError != nil) {
      if ([_lastLocationError.domain isEqualToString:kCLErrorDomain] && _lastLocationError.code == kCLErrorDenied) {
        statusMessage = @"Location Services Disabled";
      } else {
        statusMessage = @"Error Getting Location";
      }
    } else if (![CLLocationManager locationServicesEnabled]) {
      statusMessage = @"Location Services Disabled";
    } else if (_updatingLocation){
      statusMessage = @"Searching...";
    } else {
      statusMessage = @"";
      [self showLogoView];
    }
    self.messageLabel.text = statusMessage;

    self.latitudeTextLabel.hidden = YES;
    self.longitudeTextLabel.hidden = YES;
  }
}

- (void)configureGetButton
{
  if (_updatingLocation) {
    [self.getButton setTitle:@"Stop" forState:UIControlStateNormal];

    if (_spinner == nil) {
      _spinner = [[UIActivityIndicatorView alloc]
                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      _spinner.center = CGPointMake(
                                    self.messageLabel.center.x,
                                    self.messageLabel.center.y + _spinner.bounds.size.height/2.0f + 15.0f);
      [_spinner startAnimating];
      [self.containerView addSubview:_spinner];
    }
  } else {
    [self.getButton setTitle:@"Get My Location" forState:UIControlStateNormal];

    [_spinner removeFromSuperview];
    _spinner = nil;
  }
}

- (void)startLocationManager
{
  if ([CLLocationManager locationServicesEnabled]) {
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_locationManager startUpdatingLocation];
    _updatingLocation = YES;

    [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
  }
}

- (void)stopLocationManager
{
  if (_updatingLocation){
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];

    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _updatingLocation = NO;
  }
}

- (void)didTimeOut:(id)obj
{
  // NSLog(@"*** Time out");

  if (_location == nil) {
    [self stopLocationManager];

    _lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];

    [self updateLabels];
    [self configureGetButton];
  }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
  shouldSelectViewController:(UIViewController *)viewController
{
  tabBarController.tabBar.translucent = (viewController != self);
  return YES;
}

@end

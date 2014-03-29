//
//  MyTabBarController.m
//  MyLocations
//
//  Created by Derek Bassett on 3/29/14.
//  Copyright (c) 2014 Two Cavemen LLC. All rights reserved.
//

#import "MyTabBarController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
  return nil;
}

@end

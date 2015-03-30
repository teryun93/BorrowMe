//
//  MainFeed.h
//  BorrowMe
//
//  Created by Tom Lee on 2/1/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostObject.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>

@interface MainFeed : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) PFUser* currentUser;
@property (strong, nonatomic) NSMutableArray* posts;
@property (strong, nonatomic) UINavigationBar* navBar;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

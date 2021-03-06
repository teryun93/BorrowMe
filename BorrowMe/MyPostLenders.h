//
//  MyPostLenders.h
//  BorrowMe
//
//  Created by Tom Lee on 3/9/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MyPostObject.h"

@interface MyPostLenders : UITableViewController

@property (strong, nonatomic) PFUser* currentUser;
@property (strong, nonatomic) MyPostObject* receivedMyPostObject;
@property (strong, nonatomic) NSMutableArray* responses;
@property (strong, nonatomic) PFUser* viewUser;


@end

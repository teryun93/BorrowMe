//
//  PostObject.h
//  BorrowMe
//
//  Created by Tom Lee on 2/9/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface PostObject : NSObject

@property (strong, nonatomic) PFUser* user;
@property (strong, nonatomic) NSString* item;
@property (strong, nonatomic) PFObject* post;

- (void) setUserObject:(PFUser *)user;
- (void) setItemObject:(NSString *)item;
- (PFUser*) getUser;
- (NSString*) getItem;
- (void) setPostObject:(PFObject *)postObject;
- (PFObject*) getPost;

@end
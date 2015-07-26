//
//  MyPosts.m
//  BorrowMe
//
//  Created by Tom Lee on 2/24/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import "MyPosts.h"
#import "MyPostObject.h"
#import "MyPost.h"
#import "MyPostNoLenders.h"
#import "MyPostLenders.h"
#import "PostObject.h"
#import "LoadingCell.h"
#import "MyPostsSelectorHeaderCell.h"

@implementation MyPosts

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.currentUser = [PFUser currentUser];
    //NSLog(@"%@", self.currentUser);
    //[self pullFromDatabase];
    //[self.tableView reloadData];
    
    //
    //    self.navBar = self.navigationController.navigationBar;
    //    [self.navBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //    [self.navBar setShadowImage:[UIImage new]];
    //    self.navBar.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self.filterSegmentedControl setTitle:@"Posts"forSegmentAtIndex:0];
    [self.filterSegmentedControl setTitle:@"Items"forSegmentAtIndex:1];
    [self.filterSegmentedControl setTitle:@"Messages"forSegmentAtIndex:2];
    [self.filterSegmentedControl setSelectedSegmentIndex:0];
    
    //self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.currentUser = [PFUser currentUser];
    self.myPosts = [[NSMutableArray alloc] init];
    [self pullFromDatabase];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init]; [refreshControl addTarget:self action:@selector(pullFromDatabase) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
        
    /*
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:gestureRecognizer];
    */
    
}

-(void)swipeLeft:(UISwipeGestureRecognizer *)recognizer {
    
    [self performSegueWithIdentifier:@"NewPostSegue" sender:self];
    
}

- (void) pullFromDatabase
{
  
    NSLog(@"I'm in pull from db");
    self.tableView.scrollEnabled = NO;
    MyPostObject* loadingCell = [[MyPostObject alloc] init];
    [self.myPosts addObject:loadingCell];
    
    PFQuery* queryMyPosts = [[self.currentUser relationForKey:@"posts"] query];
    NSLog(@"%@", queryMyPosts);
    [queryMyPosts orderByAscending:@"deadline"];
    [queryMyPosts findObjectsInBackgroundWithBlock:^(NSArray *myPosts, NSError *error) {
        
        NSLog(@"%@", error);
        
        if (!error) {
            

            NSLog(@"my Posts %@", myPosts);
            if([myPosts count] > 0)
            {
                
                [self.myPosts removeAllObjects];
                
            }
            
        
            for (PFObject *myPost in myPosts) {

                
                MyPostObject* newMyPost = [[MyPostObject alloc] init];
                [newMyPost initialize];
                
                PFUser* user = (PFUser*)[[[myPost relationForKey:@"user"] query] getFirstObject];

                newMyPost.myPostPFObject = myPost;
                
                newMyPost.item = [myPost valueForKey:@"item"];
                
                NSArray* responses = [[[myPost relationForKey:@"responses"] query] findObjects];
                
                //NSLog(@"these are responses count   !!!!  %lu", (unsigned long)[responses count]);
                [newMyPost.responses addObjectsFromArray:responses];
                
                if([responses count] != 0)
                {
                    int responseCounter = 1;
                    for(PFObject* response in responses)
                    {
                    
                    if(responseCounter > 5)
                        break;
                    
                    PFUser* user = (PFUser*)[[[response relationForKey:@"user"] query] getFirstObject];
                    //NSLog(@"response user looppppp   %@", user);
                    //post.profilePicture.image = [UIImage imageWithData: profilePictureData];
                    [newMyPost.lenders addObject:user];
                    PFFile* profilePictureFile = [user valueForKey:@"profilePicture"];
                    NSData* profilePictureData = [profilePictureFile getData];
                    if(responseCounter == 1)
                    newMyPost.lender1Picture = [UIImage imageWithData: profilePictureData];
                    else if(responseCounter == 2)
                    newMyPost.lender2Picture = [UIImage imageWithData: profilePictureData];
                    if(responseCounter == 3)
                        newMyPost.lender3Picture = [UIImage imageWithData: profilePictureData];
                    else if(responseCounter == 4)
                        newMyPost.lender4Picture = [UIImage imageWithData: profilePictureData];
                    
                    responseCounter++;

                    }
                    
                    int additionalLendersCount = [responses count] - (responseCounter - 1);
                    newMyPost.additionalLendersCount = [NSString stringWithFormat:@"%d", additionalLendersCount];
                
                }
                
                
                NSDate* currentDate = [NSDate date];
                //NSLog(@"current date = %@", currentDate);
                NSTimeZone* currentTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
                NSTimeZone* nowTimeZone = [NSTimeZone systemTimeZone];
                
                NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:currentDate];
                NSInteger nowGMTOffset = [nowTimeZone secondsFromGMTForDate:currentDate];
                NSTimeInterval interval = nowGMTOffset - currentGMTOffset;
                currentDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:currentDate];
                
                NSInteger currentGMTOffset2 = [currentTimeZone secondsFromGMTForDate:myPost[@"deadline"]];
                NSInteger nowGMTOffset2 = [nowTimeZone secondsFromGMTForDate:myPost[@"deadline"]];
                NSTimeInterval interval2 = nowGMTOffset2 - currentGMTOffset2;
                NSDate* borrowDate = [[NSDate alloc] initWithTimeInterval:interval2 sinceDate:myPost[@"deadline"]];
                
                
                NSLog(@"current date after = %@", currentDate);
                
                NSLog(@"current borrow  date fter = %@", borrowDate);
                //NSDate* borrowDate;
                
                NSTimeInterval secondsBetween = [borrowDate timeIntervalSinceDate:currentDate];
                NSLog(@"seconds difference %f", secondsBetween);
                
                if(secondsBetween <= 0)
                {
   
                    newMyPost.deadline = @"expired";
                    newMyPost.urgency = @"expired";
                    
                }
                else
                {
                
                int numberOfWeeksElapsed;
                int numberOfDaysElapsed;
                int numberOfHoursElapsed;
                int numberOfMinutesElapsed;
                    
                NSString* timeDifferenceInString;
                
            
                numberOfWeeksElapsed = secondsBetween / 604800;
                if(numberOfWeeksElapsed >= 1)
                {
                    
                    timeDifferenceInString = [NSString stringWithFormat:@"%dw", numberOfWeeksElapsed];
                    newMyPost.deadline = timeDifferenceInString;
                    newMyPost.urgency = @"not urgent";
                    
                }
                else
                {
                    
                    numberOfDaysElapsed = secondsBetween / 86400;
                    NSLog(@"number of days %d", numberOfDaysElapsed);
                    if(numberOfDaysElapsed >= 1)
                    {
                        
                        if(numberOfDaysElapsed == 1)
                        {
                            newMyPost.urgency = @"urgent";
                        }
                        
                        newMyPost.urgency = @"not urgent";
                        timeDifferenceInString = [NSString stringWithFormat:@"%dd", numberOfDaysElapsed];
                        newMyPost.deadline = timeDifferenceInString;
                        
                    }
                    else
                    {
                        
                        newMyPost.urgency = @"urgent";
                        
                        numberOfHoursElapsed = secondsBetween / 3600;
                        if(numberOfHoursElapsed >= 1)
                        {
                            
                            timeDifferenceInString = [NSString stringWithFormat:@"%dh", numberOfHoursElapsed];
                            newMyPost.deadline = timeDifferenceInString;
                            
                        }
                        else
                        {
                            numberOfMinutesElapsed = secondsBetween / 60;
                            if(numberOfMinutesElapsed >= 1)
                            {
                                timeDifferenceInString = [NSString stringWithFormat:@"%dm", numberOfMinutesElapsed];
                                //postObject.deadline = timeDifferenceInString;
                                newMyPost.deadline = timeDifferenceInString;
                                
                            }
                            else
                            {

                            //timeDifferenceInString = [NSString stringWithFormat:@"%fs", secondsBetween];
                                newMyPost.deadline = @"Now";
                            }


                        }
                        
                        
                    }
                    
                }
                }
                
                [self.myPosts addObject:newMyPost];
  
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                self.tableView.scrollEnabled = YES;
            });
            
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.myPosts count];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MyPost *)myPost forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([[[self.myPosts objectAtIndex:indexPath.row] lenders] count] > 0)
    {
        
        CALayer * myPostItemLayer = [myPost.item layer];
        [myPostItemLayer setMasksToBounds:YES];
        [myPostItemLayer setCornerRadius:5.0];
        
        CGPoint saveCenter = myPost.lenderPicture1.center;
        CGRect newFrame = CGRectMake(myPost.lenderPicture1.frame.origin.x, myPost.lenderPicture1.frame.origin.y, 40, 40);
        
        myPost.lenderPicture1.frame = newFrame;
        myPost.lenderPicture1.layer.cornerRadius = 40 / 2.0;
        myPost.lenderPicture1.center = saveCenter;
        myPost.lenderPicture1.clipsToBounds = YES;
        
        CGPoint saveCenter2 = myPost.lenderPicture2.center;
        CGRect newFrame2 = CGRectMake(myPost.lenderPicture2.frame.origin.x, myPost.lenderPicture2.frame.origin.y, 40, 40);

        myPost.lenderPicture2.frame = newFrame2;
        myPost.lenderPicture2.layer.cornerRadius = 40 / 2.0;
        myPost.lenderPicture2.center = saveCenter2;
        myPost.lenderPicture2.clipsToBounds = YES;
        
        CGPoint saveCenter3 = myPost.lenderPicture3.center;
        CGRect newFrame3 = CGRectMake(myPost.lenderPicture3.frame.origin.x, myPost.lenderPicture3.frame.origin.y, 40, 40);
        
        myPost.lenderPicture3.frame = newFrame3;
        myPost.lenderPicture3.layer.cornerRadius = 40 / 2.0;
        myPost.lenderPicture3.center = saveCenter3;
        myPost.lenderPicture3.clipsToBounds = YES;
    
        CGPoint saveCenter4 = myPost.lenderPicture4.center;
        CGRect newFrame4 = CGRectMake(myPost.lenderPicture4.frame.origin.x, myPost.lenderPicture4.frame.origin.y, 40, 40);
        
        myPost.lenderPicture4.frame = newFrame4;
        myPost.lenderPicture4.layer.cornerRadius = 40 / 2.0;
        myPost.lenderPicture4.center = saveCenter4;
        myPost.lenderPicture4.clipsToBounds = YES;
        
    }
    
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyPostObject* myPostObject = [self.myPosts objectAtIndex:indexPath.row];
    if(myPostObject.myPostPFObject == NULL)
    {
        LoadingCell* loadingCell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
        loadingCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
        rotation.duration = 0.8f; // Speed
        rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
        [loadingCell.loadingImage.layer removeAllAnimations];
        [loadingCell.loadingImage.layer addAnimation:rotation forKey:@"Spin"];
        
        CALayer* loadingBoxLayer = [loadingCell.loadingBox layer];
        [loadingBoxLayer setMasksToBounds:YES];
        [loadingBoxLayer setCornerRadius:10.0];
        
        return loadingCell;
        
    }
    
    if([[[self.myPosts objectAtIndex:indexPath.row] lenders] count] > 0)
    {
    
    MyPost* myPost = [tableView dequeueReusableCellWithIdentifier:@"MyPost" forIndexPath:indexPath];
    MyPostObject* myPostObject = [self.myPosts objectAtIndex:indexPath.row];
        
    if([myPostObject.urgency isEqualToString: @"expired"])
    {
        
        myPost.item.backgroundColor = [UIColor colorWithRed: 153.0/255.0 green: 153.0/255.0 blue:153.0/255.0 alpha: 1.0];

    }
    else if([myPostObject.urgency isEqualToString: @"urgent"])
    {
        
        myPost.item.backgroundColor = [UIColor colorWithRed: 255.0/255.0 green: 102.0/255.0 blue:102.0/255.0 alpha: 1.0];

    }
    else if([myPostObject.urgency isEqualToString: @"not urgent"])
    {
        
        //myPost.item.backgroundColor = [UIColor colorWithRed: 255.0/255.0 green: 102.0/255.0 blue:102.0/255.0 alpha: 1.0];
        
    }
        
        myPost.item.text = myPostObject.item;
        myPost.deadline.text = myPostObject.deadline;
        
        
        NSLog(@"lender 1! %@", myPostObject.lender1Picture);
        NSLog(@"lender 2! %@", myPostObject.lender2Picture);
        NSLog(@"lender 3! %@", myPostObject.lender3Picture);
        NSLog(@"lender 4! %@", myPostObject.lender4Picture);
    
        if(myPostObject.lender1Picture)
        {
            myPost.lenderPicture1.image = myPostObject.lender1Picture;
        }
        if(myPostObject.lender2Picture)
        {
            myPost.lenderPicture2.image = myPostObject.lender2Picture;
        }
        if(myPostObject.lender3Picture)
        {
            myPost.lenderPicture3.image = myPostObject.lender3Picture;
        }
        if(myPostObject.lender4Picture)
        {
            myPost.lenderPicture4.image = myPostObject.lender4Picture;
        }
        
        if(![myPostObject.additionalLendersCount isEqualToString: @""] && ![myPostObject.additionalLendersCount isEqualToString: @"0"] )
        {
            myPost.addtionalLenders.hidden = NO;
            myPost.addtionalLenders.text = [NSString stringWithFormat:@"+%@", myPostObject.additionalLendersCount];
        }
        else
        {
            
            myPost.addtionalLenders.hidden = YES;
            
        }

        
    return myPost;
        
        
    }
    else if([[[self.myPosts objectAtIndex:indexPath.row] lenders] count] == 0)
    {
        
        MyPostNoLenders* myPostNoLenders = [tableView dequeueReusableCellWithIdentifier:@"MyPostNoLenders" forIndexPath:indexPath];
        myPostNoLenders.selectionStyle = UITableViewCellSelectionStyleNone;

        CALayer * myPostItemLayer = [myPostNoLenders.item layer];
        [myPostItemLayer setMasksToBounds:YES];
        [myPostItemLayer setCornerRadius:5.0];
        
        MyPostObject* myPostObject = [self.myPosts objectAtIndex:indexPath.row];
        myPostNoLenders.item.text = myPostObject.item;
        myPostNoLenders.deadline.text = myPostObject.deadline;

        if([myPostObject.urgency isEqualToString: @"expired"])
        {
            
            myPostNoLenders.item.backgroundColor = [UIColor colorWithRed: 153.0/255.0 green: 153.0/255.0 blue:153.0/255.0 alpha: 1.0];
            
        }
        else if([myPostObject.urgency isEqualToString: @"urgent"])
        {
            
            myPostNoLenders.item.backgroundColor = [UIColor colorWithRed: 255.0/255.0 green: 102.0/255.0 blue:102.0/255.0 alpha: 1.0];
            
        }
        
        return myPostNoLenders;
        
    }
    else
    {
        
        return NULL;
        
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    MyPostObject* myPostObject = [self.myPosts objectAtIndex:indexPath.row];
    if(myPostObject.myPostPFObject == NULL)
    {
        
        return 568;
        
    }
    
    if([[[self.myPosts objectAtIndex:indexPath.row] lenders] count] > 0)
    {
    
        return 92;
        
    }
    else if([[[self.myPosts objectAtIndex:indexPath.row] lenders] count] == 0)
    {
        
        return 58;
        
    }
    else
    {
        
        return 0;
    
    }
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    [super setEditing:editing animated:animated];
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[[self.myPosts objectAtIndex:indexPath.row ] myPostPFObject] deleteInBackground];
        [self.myPosts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"GoToMyPostLenders"])
    {
        
        /*
        MyPostLenders* linkedInMyPostLendersViewController = (MyPostLenders *)segue.destinationViewController;
        
        MyPostObject* passMyPostObject = [self.myPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        linkedInMyPostLendersViewController.receivedMyPostObject = passMyPostObject;
         */
        MyPostObject* passMyPostObject = [self.myPosts objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        MyPostLenders* tableView = [[(UINavigationController*)segue.destinationViewController viewControllers]lastObject];
        
       // MyPostLenders* tableView = (MyPostLenders*)[self.navigationController.viewControllers objectAtIndex:0];
        tableView.receivedMyPostObject = passMyPostObject;
        
        
    }
    
}

- (IBAction)backButtonPressed:(id)sender {
    
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}


@end

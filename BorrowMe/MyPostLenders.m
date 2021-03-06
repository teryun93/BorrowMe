//
//  MyPostLenders.m
//  BorrowMe
//
//  Created by Tom Lee on 3/9/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import "MyPostLenders.h"
#import "MyPostLender.h"
#import "MyPostItem.h"
#import "Response.h"
#import "UserProfile.h"
#import "LoadingCell.h"
#import <MessageUI/MessageUI.h>

@implementation MyPostLenders


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
    
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.currentUser = [PFUser currentUser];
    self.responses = [[NSMutableArray alloc] init];
    
    
    NSLog(@"received my post object %@", self.receivedMyPostObject);
    
    //[self.responses addObject:self.receivedMyPostObject.item];
    
    Response* loadingCell = [[Response alloc] init];
    [self.responses addObject:loadingCell];
    
    [self pullFromDatabase];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init]; [refreshControl addTarget:self action:@selector(pullFromDatabase) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    /*
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [gestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.view addGestureRecognizer:gestureRecognizer];
    */
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTextDialog:) name:@"RespondToLender" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directToUserProfile:) name:@"DisplayUserProfile" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteResponse:) name:@"DeleteResponse" object:nil];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
}

- (void) pullFromDatabase
{
    
    self.tableView.scrollEnabled = NO;
    PFQuery* queryResponses = [[self.receivedMyPostObject.myPostPFObject relationForKey:@"responses"] query];
    [queryResponses orderByDescending:@"createdAt"];
    //NSLog(@"responses %@", queryResponses);
    [queryResponses findObjectsInBackgroundWithBlock:^(NSArray *responses, NSError *error) {
        
        //NSLog(@"%@", error);
        
        if (!error) {
            
            [self.responses removeAllObjects];
            
            for (PFObject *response in responses) {
                
                //[self.receivedMyPostObject.responses addObject:response];
                Response* newResponse = [[Response alloc] init];
                
                newResponse.responsePFObject = response;
                //PFUser* user = (PFUser*)[[[response relationForKey:@"user"] query] getFirstObject];
                PFUser* user = response[@"referenceToUser"];
                newResponse.user = user;
                PFFile* profilePictureFile = [user valueForKey:@"profilePicture"];
                NSData* profilePictureData = [profilePictureFile getData];
                newResponse.userProfile = [UIImage imageWithData: profilePictureData];
                
                PFFile* itemImageFile = [response valueForKey:@"itemImage"];
                NSData* itemImageData = [itemImageFile getData];
                //newResponse.itemImageData = itemImageData;
                newResponse.itemImage = [UIImage imageWithData: itemImageData];
                
                
                //NSLog(@"%@",response[@"description"]);
                newResponse.itemDescription = response[@"description"];
                //newResponse.note = response[@"note"];
                newResponse.price = response[@"cost"];
                newResponse.responsePFObject = response;
                
                
                [self.responses addObject:newResponse];
                
            }
            
            
            NSLog(@"responses after pull from database  %@", self.responses);
            
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                self.tableView.scrollEnabled = YES;
            });
            
        }
        else
        {
            
            self.tableView.scrollEnabled = YES;
            
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
    
    return [self.responses count];
    
}

- (void)singleTapOnTableViewCell:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"single tap!");
    
}

- (void)doubleTapOnTableViewCell:(UITapGestureRecognizer *) recognizer
{
    NSLog(@"double tap");
    /*
    [[self.responses objectAtIndex: indexPath.row ] deleteInBackground];
    [self.responses removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    */
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 /*
    if(indexPath.row == 0) {
        
        MyPostItem* myPostItem = [tableView dequeueReusableCellWithIdentifier:@"MyPostItem" forIndexPath:indexPath];
        CALayer * myPostItemLayer = [myPostItem.item layer];
        [myPostItemLayer setMasksToBounds:YES];
        [myPostItemLayer setCornerRadius:5.0];
        
        myPostItem.item.text = [self.responses objectAtIndex:indexPath.row];
        
        return myPostItem;
        
    }
    else {
 */
        Response* response = [self.responses objectAtIndex:indexPath.row];
    
        if(response.user == NULL)
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
            
            CALayer * loadingBoxLayer = [loadingCell.loadingBox layer];
            [loadingBoxLayer setMasksToBounds:YES];
            [loadingBoxLayer setCornerRadius:10.0];
            
            return loadingCell;
            
        }
        else
        {
    
        MyPostLender* myPostLender = [tableView dequeueReusableCellWithIdentifier:@"MyPostLender" forIndexPath:indexPath];
        myPostLender.selectionStyle = UITableViewCellSelectionStyleNone;


    
        myPostLender.profileImage.image = response.userProfile;
        myPostLender.itemImage.image = response.itemImage;
        myPostLender.username.text = [response.user valueForKey:@"username"];
        if(response.price == NULL)
        {
            myPostLender.price.text = @"$0";
            
        }
        else
        {
            
            myPostLender.price.text = [NSString stringWithFormat:@"$%@", response.price];
            
        }
            
        myPostLender.index = indexPath.row;
    
    
        [myPostLender.usernameButton setTitle:[response.user valueForKey:@"username"] forState:UIControlStateNormal];
        [myPostLender.userProfileButton setBackgroundImage:myPostLender.profileImage.image
                        forState:UIControlStateNormal];
        if(response.itemDescription != NULL)
        {
            myPostLender.itemDescription.text = [NSString stringWithFormat:@"\"%@\"",response.itemDescription];
        }
        else
        {
            myPostLender.itemDescription.text = [NSString stringWithFormat:@"\"No Description :(\""];
        }
            
        return myPostLender;
    
        }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(MyPostLender *)myPostLender forRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    Response* response = [self.responses objectAtIndex:indexPath.row];
    
    if(response.user != NULL)
    {
    
    CALayer * borderLayer = [myPostLender.border layer];
    [borderLayer setMasksToBounds:YES];
    [borderLayer setCornerRadius:10.0];
    
    CALayer * messageButtonLayer = [myPostLender.messageButton layer];
    [messageButtonLayer setMasksToBounds:YES];
    [messageButtonLayer setCornerRadius:5.0];
    
    CGPoint saveCenter = myPostLender.userProfileButton.center;
    CGRect newFrame = CGRectMake(myPostLender.userProfileButton.frame.origin.x, myPostLender.userProfileButton.frame.origin.y, 50, 50);
    
    myPostLender.userProfileButton.frame = newFrame;
    myPostLender.userProfileButton.layer.cornerRadius = 50 / 2.0;
    myPostLender.userProfileButton.center = saveCenter;
    myPostLender.userProfileButton.clipsToBounds = YES;
        
        CGPoint saveCenter2 = myPostLender.messageButtonContainer.center;
        CGRect newFrame2 = CGRectMake(myPostLender.messageButtonContainer.frame.origin.x, myPostLender.messageButtonContainer.frame.origin.y, 50, 50);
        
        myPostLender.messageButtonContainer.frame = newFrame2;
        myPostLender.messageButtonContainer.layer.cornerRadius = 50 / 2.0;
        myPostLender.messageButtonContainer.center = saveCenter2;
        myPostLender.messageButtonContainer.clipsToBounds = YES;
        
        CGPoint saveCenter3 = myPostLender.xButtonContainer.center;
        CGRect newFrame3 = CGRectMake(myPostLender.xButtonContainer.frame.origin.x, myPostLender.xButtonContainer.frame.origin.y, 50, 50);
        
        myPostLender.xButtonContainer.frame = newFrame3;
        myPostLender.xButtonContainer.layer.cornerRadius = 50 / 2.0;
        myPostLender.xButtonContainer.center = saveCenter3;
        myPostLender.xButtonContainer.clipsToBounds = YES;
        
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    Response* response = [self.responses objectAtIndex:indexPath.row];
    
    if(response.user == NULL)
    {
        
        return 568;
    
    }
    else
    {
    
        return 450;
        
    }
    
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    self.tableView.allowsMultipleSelectionDuringEditing = editing;
    [super setEditing:editing animated:animated];
    
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES if you want the specified item to be editable.
    return YES;
    
}

- (void)showTextDialog: (NSNotification*) notification
{
    
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    
    Response* response = [self.responses objectAtIndex:index];
    PFUser* user = response.user;
    
    NSString* recipientPhoneNumber = user[@"phone"];
    NSString* item = self.receivedMyPostObject.item;
    
    
    NSString* textMessageContent = [NSString stringWithFormat:@"Hello from Neighbors! %@ would like to borrow your %@", user[@"username"], item];
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = textMessageContent;
        controller.recipients = [NSArray arrayWithObjects:recipientPhoneNumber, nil];
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
    }
    
    
}

- (void)directToUserProfile: (NSNotification*) notification
{

    NSInteger index = [notification.userInfo[@"index"] integerValue];
    Response* response = [self.responses objectAtIndex:index];
    self.viewUser = response.user;
    
    [self performSegueWithIdentifier:@"View-User-Profile" sender:self];
    
}

- (void)deleteResponse: (NSNotification*) notification
{
    
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    Response* response = [self.responses objectAtIndex:index];
    [self.responses removeObjectAtIndex:index];
    NSLog(@"pfrepsonse %@", response.responsePFObject);
    [response.responsePFObject deleteInBackground];
    NSLog(@"%@", response);
    [self.tableView reloadData];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}




/*
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Cancelled");
            break;
        case MessageComposeResultFailed:
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"Unknown Error"
                                                           delegate:self cancelButtonTitle:@”OK” otherButtonTitles: nil];
            [alert show];
            [alert release];
            break;
        case MessageComposeResultSent:
            
            break;
        default:
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}
*/

/*
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[[self.myPosts objectAtIndex:indexPath.row ] myPostPFObject] deleteInBackground];
        [self.myPosts removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}
*/
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
 
     if([segue.identifier isEqualToString:@"View-User-Profile"])
     {
 

         //UserProfile* tableView = [[(UINavigationController*)segue.destinationViewController viewControllers]lastObject];
         //PFUser* passUser = self.viewUser;
         //UserProfile* tableView = (UserProfile*)[self.navigationController.viewControllers objectAtIndex:0];
         UserProfile* tableView = (UserProfile*)segue.destinationViewController;
         PFUser* passUser = self.viewUser;
         tableView.user = passUser;
         
         /*
         UserProfile* linkedInUserProfileTableViewController = (UserProfile *)segue.destinationViewController;
         PFUser* passUser = self.viewUser;
         linkedInUserProfileTableViewController.user = passUser;
        */
     
         NSLog(@"I'm in the prepare for segue!");
 
     }
 
 }

- (IBAction)backButtonPressed:(id)sender {
    
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}

@end

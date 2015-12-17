//
//  GameMatchingViewController.m
//  battleship
//
//  Created by Matthew Weintrub on 12/16/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "GameMatchingViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "GameViewController.h"

@interface GameMatchingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (strong, nonatomic) PFObject *battle;

@end

@implementation GameMatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self startMatching];
}

-(void)checkHeartbeat:(NSTimer *)timer
{
	[self.battle fetchInBackgroundWithBlock:
	^(PFObject *object, NSError *error){
		if (error != nil)
		{
			//TODO: handle error
		}
		else
		{
			self.battle = object;
			
			if ([object valueForKey:@"SecondUser"] != nil)
			{
				[timer invalidate];
				//TODO: segue to game view
			}
		}
	}];
}

-(void)startMatching
{
	if ([PFUser currentUser] != nil)
	{
		self.waitingLabel.text = [NSString stringWithFormat:@"Hi %@ your game will be starting soon", [[PFUser currentUser] username]];
		
		__weak typeof(self) weakSelf = self;
		
		PFQuery *query = [PFQuery queryWithClassName:@"Game"];
		[query whereKeyDoesNotExist:@"SecondUser"];
		[query getFirstObjectInBackgroundWithBlock:
		^(PFObject *object, NSError *error){
			if (error != nil)
			{
				//TODO: make a match
				PFObject *battle = [PFObject objectWithClassName:@"Game"];
				battle[@"FirstUser"] = [PFUser currentUser].objectId;
				battle[@"MoveNumber"] = @(0);
				[battle saveInBackgroundWithBlock:
				 ^(BOOL succeeded, NSError *error)
				 {
					 if (succeeded)
					 {
						 NSLog(@"Game created!");
					 }
					 else
					 {
						 NSLog(@"Game not created for some reason!");
					 }
				 }];
				weakSelf.battle = battle;
				
				[NSTimer scheduledTimerWithTimeInterval:PARSE_HEARTBEAT target:weakSelf selector:@selector(checkHeartbeat:) userInfo:nil repeats:YES];
			}
			else if (object != nil)
			{
				//join a match
				object[@"SeconUser"] = [PFUser currentUser].objectId;
				[object saveInBackgroundWithBlock:
				^(BOOL succeeded, NSError *error){
					if (error != nil)
					{
						//TODO: deal with error
					}
					else
					{
						weakSelf.battle = object;
                        [self performSegueWithIdentifier:@"startGameSegue" sender:self];

					}
				}];
			}
		}];
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	GameViewController *gvc = segue.destinationViewController;
	gvc.battleObject = self.battle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser] != nil) {
        NSLog(@"good to go %@", [PFUser currentUser]);
    } else {
        [self login];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Parse

- (void)login {
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.delegate = self;
    [self presentViewController:logInViewController animated:YES completion:nil];
    
}

// Delegate

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
	[self startMatching];
}



@end

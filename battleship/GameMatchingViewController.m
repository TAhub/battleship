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
#import "StarfieldView.h"
#import "Constants.h"

@interface GameMatchingViewController () <PFLogInViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet StarfieldView *starfieldView;
@property (strong, nonatomic) PFObject *battle;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSTimer *updateHeartbeat;

@end

@implementation GameMatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self startMatching];
    [self setupCancelButton];
    [self setupStarfield];
    [self setupSpinner];
}

- (void)setupStarfield {
    self.starfieldView.layer.borderWidth = BOARD_BORDER;
    self.starfieldView.layer.borderColor = [[UIColor cyanColor] CGColor];
}

- (void)setupCancelButton {
    NSString *string = @"CANCEL";
    UIFont *font = [UIFont fontWithName:@"Avenir" size:18];
    NSAttributedString *cancelButton = [[NSAttributedString alloc] initWithString:string attributes:@{ NSKernAttributeName: @(1.5f), NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor cyanColor] }];
    [self.cancelButton setAttributedTitle:cancelButton forState: UIControlStateNormal];
}

- (void)setupSpinner {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    spinner.tag = 12;
    [self.view addSubview:spinner];
    [spinner startAnimating];
}



-(void)checkHeartbeat:(NSTimer *)timer
{
	NSLog(@"Check user heartbeat");
	
	__weak typeof(self) weakSelf = self;
	
	[self.battle fetchInBackgroundWithBlock:
	^(PFObject *object, NSError *error){
		if (error != nil)
		{
			[weakSelf cancelMatching];
		}
		else
		{
			weakSelf.battle = object;
			
			if ([object valueForKey:@"SecondUser"] != nil)
			{
				[timer invalidate];
				[weakSelf performSegueWithIdentifier:@"startGameSegue" sender:weakSelf];
			}
			else
			{
				//update the updatedAt
				object[@"random"] = @(arc4random_uniform(9999));
				[object saveInBackground];
			}
		}
	}];
}

-(IBAction)cancelMatching
{
	if (self.battle != nil)
	{
		[self.battle deleteInBackground];
		[self.navigationController popViewControllerAnimated:YES];
		[self.updateHeartbeat invalidate];
        NSLog(@"game canceled");
	}
}

-(void)startMatching
{
	if ([PFUser currentUser] != nil)
	{
		self.waitingLabel.text = [[NSString stringWithFormat: STRING_GAME_WAIT, [[PFUser currentUser] username]] uppercaseString];
    
		__weak typeof(self) weakSelf = self;
		
		//get current date in PST
		NSCalendar *cal = [NSCalendar currentCalendar];
		NSDate *now = [NSDate date];
		NSDateComponents *pstComponents = [cal components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:now];
		pstComponents.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
		NSDate *pstDate = [cal dateFromComponents:pstComponents];
		NSDate *thirtySecondsAgo = [pstDate dateByAddingTimeInterval:-30];
		
		NSLog(@"Looking for games made after %@.", thirtySecondsAgo);
		
		PFQuery *query = [PFQuery queryWithClassName:@"Game"];
		[query whereKeyDoesNotExist:@"SecondUser"];
		[query whereKey:@"FirstUser" notEqualTo:[PFUser currentUser].objectId];
		[query whereKey:@"updatedAt" greaterThanOrEqualTo:thirtySecondsAgo];
		
		[query getFirstObjectInBackgroundWithBlock:
		^(PFObject *object, NSError *error){
			if (error != nil)
			{
				//make a match
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
				
				self.updateHeartbeat = [NSTimer scheduledTimerWithTimeInterval:PARSE_HEARTBEAT target:weakSelf selector:@selector(checkHeartbeat:) userInfo:nil repeats:YES];
			}
			else if (object != nil)
			{
				//join a match
				object[@"SecondUser"] = [PFUser currentUser].objectId;
				object[@"LastMover"] = [PFUser currentUser].objectId;
				[object saveInBackgroundWithBlock:
				^(BOOL succeeded, NSError *error){
					if (error != nil)
					{
						[weakSelf cancelMatching];
						[self.updateHeartbeat invalidate];
					}
					else if (succeeded)
					{
						weakSelf.battle = object;
                        [weakSelf performSegueWithIdentifier:@"startGameSegue" sender:weakSelf];
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
    
    [self.starfieldView setupStarfieldWithFineness:0.5f];

    
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

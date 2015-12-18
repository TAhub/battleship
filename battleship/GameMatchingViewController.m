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

@interface GameMatchingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;
@property (weak, nonatomic) IBOutlet StarfieldView *starfieldView;
@property (strong, nonatomic) PFObject *battle;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation GameMatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self startMatching];
    
    NSString *string = @"CANCEL";
    UIFont *font = [UIFont fontWithName:@"Avenir" size:18];
    NSAttributedString *cancelButton = [[NSAttributedString alloc] initWithString:string attributes:@{ NSKernAttributeName: @(1.5f), NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor cyanColor] }];
    [self.cancelButton setAttributedTitle:cancelButton forState: UIControlStateNormal];
    
    self.starfieldView.layer.borderWidth = BOARD_BORDER;
    self.starfieldView.layer.borderColor = [[UIColor cyanColor] CGColor];

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
			//TODO: handle error
		}
		else
		{
			weakSelf.battle = object;
			
			if ([object valueForKey:@"SecondUser"] != nil)
			{
				[timer invalidate];
				[weakSelf performSegueWithIdentifier:@"startGameSegue" sender:weakSelf];
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
	}
}

-(void)startMatching
{
	if ([PFUser currentUser] != nil)
	{
		self.waitingLabel.text = [[NSString stringWithFormat:@"Hi %@ your game will be starting soon", [[PFUser currentUser] username]] uppercaseString];
    
		__weak typeof(self) weakSelf = self;
		
		PFQuery *query = [PFQuery queryWithClassName:@"Game"];
		[query whereKeyDoesNotExist:@"SecondUser"];
		[query whereKey:@"FirstUser" notEqualTo:[PFUser currentUser].objectId];
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
				object[@"SecondUser"] = [PFUser currentUser].objectId;
				object[@"LastMover"] = [PFUser currentUser].objectId;
				[object saveInBackgroundWithBlock:
				^(BOOL succeeded, NSError *error){
					if (error != nil)
					{
						//TODO: deal with error
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

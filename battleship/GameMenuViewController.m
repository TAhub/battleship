//
//  GameMenuViewController.m
//  battleship
//
//  Created by Matthew Weintrub on 12/16/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "GameMenuViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "StarfieldView.h"
#import "Constants.h"

@interface GameMenuViewController () <PFLogInViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *yuhButton;
@property (weak, nonatomic) IBOutlet StarfieldView *gameView;

@end

@implementation GameMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *string = @"NEW GAME";
    UIFont *font = [UIFont fontWithName:@"Avenir" size:18];
    NSAttributedString *yuhButton = [[NSAttributedString alloc] initWithString:string attributes:@{ NSKernAttributeName: @(1.5f), NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor cyanColor] }];
    [self.yuhButton setAttributedTitle:yuhButton forState: UIControlStateNormal];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//add letterbox views
	UIView *l1 = [[UIView alloc] initWithFrame:CGRectMake(self.gameView.frame.origin.x - 10, self.gameView.frame.origin.y - 10, 10, self.gameView.frame.size.height + 20)];
	l1.backgroundColor = [UIColor blackColor];
	[self.view addSubview:l1];
	UIView *l2 = [[UIView alloc] initWithFrame:CGRectMake(self.gameView.frame.origin.x + self.gameView.frame.size.width, self.gameView.frame.origin.y - 10, 10, self.gameView.frame.size.height + 20)];
	l2.backgroundColor = [UIColor blackColor];
	[self.view addSubview:l2];
	
	//setup starfield border effect
	UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(self.gameView.frame.origin.x - BOARD_BORDER, self.gameView.frame.origin.y - BOARD_BORDER, self.gameView.frame.size.width + 2 * BOARD_BORDER, self.gameView.frame.size.height + 2 * BOARD_BORDER)];
	borderView.layer.borderWidth = BOARD_BORDER;
	borderView.layer.borderColor = [[UIColor cyanColor] CGColor];
	[self.view addSubview:borderView];
	
	[self.gameView setupStarfieldWithFineness:0.5f];
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

    
- (void)signout {
    [PFUser logOut];
    [self login];
}

// Delegate

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {    
        [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)startGameButtonPressed:(id)sender {
    NSLog(@"okie doke");
    
}


@end

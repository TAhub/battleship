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


@interface GameMenuViewController ()

@property (weak, nonatomic) IBOutlet UIButton *yuhButton;
@property (weak, nonatomic) IBOutlet StarfieldView *gameView;

@end

@implementation GameMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *string = @"NEW GAME";
    UIFont *font = [UIFont fontWithName:@"Avenir" size:16];
    UIColor *blue = [UIColor colorWithRed:123/255 green:236/255 blue:252/255 alpha:1.0];
    NSAttributedString *yuhButton = [[NSAttributedString alloc] initWithString:string attributes:@{ NSKernAttributeName: @(1.5f), NSFontAttributeName: font, NSForegroundColorAttributeName: blue }];
    [self.yuhButton setAttributedTitle:yuhButton forState: UIControlStateNormal];
    
    self.gameView.layer.borderWidth = BOARD_BORDER;
    self.gameView.layer.borderColor = [[UIColor blueColor] CGColor];
	

}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
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

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

@interface GameMenuViewController () <PFLogInViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *yuhButton;

@end

@implementation GameMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    NSString *string = @"NEW GAME";
    UIFont *font = [UIFont fontWithName:@"Avenir" size:16];
    UIColor *blue = [UIColor colorWithRed:123/255 green:236/255 blue:252/255 alpha:1.0];
    NSAttributedString *yuhButton = [[NSAttributedString alloc] initWithString:string attributes:@{ NSKernAttributeName: @(1.5f), NSFontAttributeName: font, NSForegroundColorAttributeName: blue }];
    [self.yuhButton setAttributedTitle:yuhButton forState: UIControlStateNormal];
    
  
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

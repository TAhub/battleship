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

@interface GameMatchingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *waitingLabel;

@end

@implementation GameMatchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.waitingLabel.text = [NSString stringWithFormat:@"Hi %@ your game will be starting soon", [[PFUser currentUser] username]];
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
}



@end

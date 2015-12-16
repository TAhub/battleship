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

@end

@implementation GameMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //add parse login
    [self login];
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


@end

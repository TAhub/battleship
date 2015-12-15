//
//  OAuthGameCenterController.m
//  battleship
//
//  Created by Matthew Weintrub on 12/15/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "OAuthGameCenterController.h"

@interface OAuthGameCenterController ()
@property (weak, nonatomic) IBOutlet UILabel *playerNameLabel;

@end

@implementation OAuthGameCenterController


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set GameCenter Manager Delegate
    [[GameCenterManager sharedManager] setDelegate:self];
    NSLog(@"show loginVC");
    

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    BOOL available = [[GameCenterManager sharedManager] checkGameCenterAvailability:YES];
    if (available) {
        NSLog(@"GameCenter is available");
    } else {
        NSLog(@"Error: GameCenter is NOT available");
    }
    
    GKLocalPlayer *player = [[GameCenterManager sharedManager] localPlayerData];
    if (player) {
        self.playerNameLabel.text = [NSString stringWithFormat:@"Welcome %@", player.displayName];
        NSLog(@"%@ is signed in", player.displayName);
    } else {
        NSLog(@"%@ is signed in", player.displayName);
        self.playerNameLabel.text = @"No GameCenter player found";

    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------- GameCenter Manager Delegate ------------------------------------------------------------------------//
#pragma mark - GameCenter Manager Delegate

- (void)gameCenterManager:(GameCenterManager *)manager authenticateUser:(UIViewController *)gameCenterLoginController {
    [self presentViewController:gameCenterLoginController animated:YES completion:^{
        NSLog(@"Finished Presenting Authentication Controller");
    }];
}


- (void)gameCenterManager:(GameCenterManager *)manager availabilityChanged:(NSDictionary *)availabilityInformation {
    NSLog(@"GC Availabilty: %@", availabilityInformation);

}

- (void)gameCenterManager:(GameCenterManager *)manager error:(NSError *)error {
    NSLog(@"GCM Error: %@", error);
}



@end

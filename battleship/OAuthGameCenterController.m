//
//  OAuthGameCenterController.m
//  battleship
//
//  Created by Matthew Weintrub on 12/15/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "OAuthGameCenterController.h"

@interface OAuthGameCenterController ()

@end

@implementation OAuthGameCenterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Set GameCenter Manager Delegate
    [[GameCenterManager sharedManager] setDelegate:self];
    NSLog(@"show loginVC");

    
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




@end

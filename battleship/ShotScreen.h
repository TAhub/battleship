//
//  ShotScreen.h
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface ShotScreen: NSObject

//this array contains every position that has been shot
@property (strong, nonatomic) NSArray *shots;

//this array contains every position that has been shot... and was a hit
@property (strong, nonatomic) NSArray *hits;


@end
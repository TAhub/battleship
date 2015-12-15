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

//positions are returned as strings, of the format
//"A1" or whatever
//where the row is A-J
//and the column is 1-8

//this set contains every position that has been shot
@property (strong, nonatomic) NSMutableSet *shots;

//this set contains every position that has been shot... and was a hit
@property (strong, nonatomic) NSMutableSet *hits;


-(id)init;


@end
//
//  ShipScreen.h
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "ShotScreen.h"

@interface ShipScreen: ShotScreen

//tries to place a ship at a given position
//returns true if placing it there did not break any rules
-(BOOL) placeShipAtPosition:(NSString *)position withRotation:(BOOL)rotation andType:(ShipType)type;

//tries to attack a position
//returns true if the shot was a hit
-(BOOL) attackPosition:(NSString *)position;

//this is all the ships the ship screen contains
@property (strong, nonatomic) NSArray *ships;

//this returns true if you have lost, according to the rules of the game (ie all ships sunk)
-(BOOL) defeated;

@end
//
//  ShipScreen.h
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "ShotScreen.h"
#import "Ship.h"

@interface ShipScreen: ShotScreen

#pragma mark - setup

//this initializer initializes the ship screen with no ships in it
//so it starts out in ship placement mode
-(id)initEmpty;

//this initializer initializes the ship screen with ships to start in it
//for if you want to reload the ship screen, or show the player what the other person's ships were like
//TODO: we should talk later to figure out what format to transfer the ships in
-(id)initWithShips:(NSArray *)ships;


//this is the part of the game you are in
@property GamePhase phase;

#pragma mark - play phase interface

//tries to attack a position
//returns true if the shot was a hit
-(BOOL) attackPosition:(NSString *)position;

//this is all the ships the ship screen contains
@property (strong, nonatomic) NSMutableArray *ships;

//this returns true if you have lost, according to the rules of the game (ie all ships sunk)
-(BOOL) defeated;

//this sets the labels as appropriate for the phase
-(void)reloadLabels;

#pragma mark - placement phase interface

//tries to place a ship at a given position
//returns true if placing it there did not break any rules
-(BOOL) placeShipAtPosition:(NSString *)position withRotation:(BOOL)rotation andType:(ShipType)type;

//this removes the ship of a given type, and returns the old one for storage
-(Ship *) removeShipOfType:(ShipType)type;

//this gives you the ship at a given position
-(Ship *) shipAtPosition:(NSString *)position;

//these properties store the labels for the rows and the columns
//this is so, when they are being shuffled, you know what to label to the boxes
//these will start out scrambled, and will be automatically re-scrambled with every ship placed
//and un-scrambled once all the ships are placed
@property (strong, nonatomic) NSArray *rowLabels;
@property (strong, nonatomic) NSArray *columnLabels;

@end
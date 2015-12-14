//
//  Constants.h
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#pragma mark - localization
//TODO: put constants for localized lines here


#pragma mark - enums
typedef enum
{
	kAircraftCarrier,
	kBattleship,
	kSubmarine,
	kDestroyer,
	kPatrolBoat
} ShipType;

typedef enum
{
	kPhasePlace,
	kPhaseShoot,
	kPhaseWait
} GamePhase;


#pragma mark - constants

#define BOARD_WIDTH 8
#define BOARD_HEIGHT 10
#define SHIP_TYPES 5
#define SHIP_ANIM_LENGTH 0.15f

#pragma mark - global functions

NSString *columnFromPosition(NSString *position);
NSString *rowFromPosition(NSString *position);
NSString *positionFrom(NSString *row, NSString *column);
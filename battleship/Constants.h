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
	kPhaseWaitForOpponent,
	kPhasePlace,
	kPhaseShoot,
	kPhaseWait
} GamePhase;


#pragma mark - constants

#define BOARD_WIDTH 8
#define BOARD_HEIGHT 10
#define SHIP_TYPES 5
#define SHIP_ANIM_LENGTH 0.15f
#define SHOTS_ANIM_LENGTH 0.5f
#define SHOTS_SIZE_START 20
#define SHOTS_SIZE 12
#define EXPLODE_ANIM_LENGTH 0.55f
#define EXPLODE_FLARES 50
#define EXPLODE_FLARE_SIZE 25
#define EXPLODE_FLARE_SIZE_END 10
#define EXPLODE_SIZE_VARIATION 6
#define EXPLODE_FLARE_DISTANCE 70
#define STARFIELD_NUMBER_STARS 60
#define STARFIELD_STAR_LENGTH 60.0f
#define STARFIELD_STAR_SIZE 8
#define FADETEXT_FADE_LENGTH_PER_CHARACTER 0.04f
#define TIMER_WARNINGLENGTH 15
#define TIMER_TIMEOUTLENGTH 15
#define TIMER_INTERVAL 5
#define BOARD_BORDER 5

#pragma mark - global functions

NSString *columnFromPosition(NSString *position);
NSString *rowFromPosition(NSString *position);
NSString *positionFrom(NSString *row, NSString *column);
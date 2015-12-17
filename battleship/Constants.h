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
	kPhaseWait,
	kPhaseOver
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
#define EXPLODE_MAG_SMALL 0.65f
#define EXPLODE_MAG_MEGA 2.1f
#define EXPLODE_DELAY_MEGA 0.3f
#define STARFIELD_NUMBER_STARS 60
#define STARFIELD_STAR_LENGTH 60.0f
#define STARFIELD_STAR_SIZE 8
#define FADETEXT_FADE_LENGTH_PER_CHARACTER 0.04f
#define TIMER_WARNINGLENGTH 15
#define TIMER_TIMEOUTLENGTH 15
#define TIMER_INTERVAL 5
#define BOARD_BORDER 5
#define PARSE_HEARTBEAT 4
#define MARKER_HIT_FOCUS [UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0]
#define MARKER_HIT [UIColor colorWithRed:0.5 green:0.25 blue:0.25 alpha:1.0]
#define MARKER_MISS_FOCUS [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]
#define MARKER_MISS [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]

#pragma mark - global functions

NSString *columnFromPosition(NSString *position);
NSString *rowFromPosition(NSString *position);
NSString *positionFrom(NSString *row, NSString *column);
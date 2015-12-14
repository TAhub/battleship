//
//  Ship.m
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "Ship.h"

@implementation Ship

-(id)initWithRotation:(BOOL)rotation andX:(NSUInteger)x andY:(NSUInteger)y andType:(ShipType)type
{
	if (self = [super init])
	{
		self.x = x;
		self.y = y;
		self.rotation = rotation;
		self.type = type;
	}
	return self;
}

-(NSArray *)positionsWithRowLabels:(NSArray *)rows andColumnlabels:(NSArray *)columns allowOverflow:(BOOL)overflow
{
	int size;
	switch(self.type)
	{
		case kAircraftCarrier: size = 5; break;
		case kBattleship: size = 4; break;
		case kSubmarine: size = 3; break;
		case kDestroyer: size = 3; break;
		case kPatrolBoat: size = 2; break;
	}
	
	NSMutableArray *positions = [NSMutableArray new];
	if (self.rotation)
	{
		for (NSUInteger x = self.x; x < self.x + size; x++)
		{
			if (x >= BOARD_WIDTH && !overflow)
				return nil;
			[positions addObject:positionFrom(rows[self.y], columns[x])];
		}
	}
	else
	{
		for (NSUInteger y = self.y; y < self.y + size; y++)
		{
			if (y >= BOARD_HEIGHT && !overflow)
				return nil;
			[positions addObject:positionFrom(rows[y], columns[self.x])];
		}
	}
	
	return positions;
}


@end
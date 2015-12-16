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

-(id)initWithShipJSON:(NSDictionary *)json
{
	if (self = [super init])
	{
		self.x = [(NSString *)json[@"x"] intValue];
		self.y = [(NSString *)json[@"y"] intValue];
		self.rotation = [(NSString *)json[@"rotation"] boolValue];
		self.type = [(NSString *)json[@"type"] intValue];
		
	}
	return self;
}

-(NSDictionary *)shipJSON
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@(self.x), @"x", @(self.y), @"y", @(self.rotation), @"rotation", @(self.type), @"type", nil];
}

-(NSArray *)shipBits
{
	NSString *base;
	switch(self.type)
	{
		case kAircraftCarrier: base = @"aircraftcarrier"; break;
		case kBattleship: base = @"battleship"; break;
		case kSubmarine: base = @"submarine"; break;
		case kDestroyer: base = @"destroyer"; break;
		case kPatrolBoat: base = @"patrolBoat"; break;
	}
	
	NSMutableArray *bits = [NSMutableArray new];
	for (int i = 0; i < [self size]; i++)
		[bits addObject:[NSString stringWithFormat:@"%i-%@", i, base]];
	return bits;
}

-(int)size
{
	switch(self.type)
	{
		case kAircraftCarrier: return 5;
		case kBattleship: return 4;
		case kSubmarine: return 3;
		case kDestroyer: return 3;
		case kPatrolBoat: return 2;
	}
}

-(NSArray *)positionsWithRowLabels:(NSArray *)rows andColumnlabels:(NSArray *)columns allowOverflow:(BOOL)overflow
{
	int size = [self size];
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
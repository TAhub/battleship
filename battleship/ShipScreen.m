//
//  ShipScreen.m
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "ShipScreen.h"

@implementation ShipScreen

-(id)initEmpty
{
	if (self = [super init])
	{
		self.phase = kPhasePlace;
		self.ships = [NSMutableArray new];
		[self.ships addObject:[[Ship alloc] initWithRotation:true andX:0 andY:0 andType:kAircraftCarrier]];
		[self.ships addObject:[[Ship alloc] initWithRotation:true andX:0 andY:1 andType:kBattleship]];
		[self.ships addObject:[[Ship alloc] initWithRotation:true andX:0 andY:2 andType:kSubmarine]];
		[self.ships addObject:[[Ship alloc] initWithRotation:true andX:0 andY:3 andType:kDestroyer]];
		[self.ships addObject:[[Ship alloc] initWithRotation:true andX:0 andY:4 andType:kPatrolBoat]];
		
		[self reloadLabels];
	}
	return self;
}

-(id)initWithShips:(NSArray *)ships
{
	if (self = [super init])
	{
		//TODO: init
		[self reloadLabels];
	}
	return self;
}

-(BOOL)attackPosition:(NSString *)position
{
	//TODO: implement
	return YES;
}

-(Ship *)removeShipOfType:(ShipType)type
{
	for (int i = 0; i < self.ships.count; i++)
	{
		Ship *shipAt = self.ships[i];
		if (shipAt.type == type)
		{
			[self.ships removeObjectAtIndex:i];
			return shipAt;
		}
	}
	return nil;
}

-(Ship *) shipAtPosition:(NSString *)position
{
	for (Ship *ship in self.ships)
	{
		NSSet *positions = [ship positionsWithRowLabels:[self rowLabels] andColumnlabels:[self columnLabels]];
		if ([positions containsObject:position])
			return ship;
	}
	return nil;
}

-(BOOL)placeShipAtPosition:(NSString *)position withRotation:(BOOL)rotation andType:(ShipType)type
{
	NSUInteger x = [[self columnLabels] indexOfObject:columnFromPosition(position)];
	NSUInteger y = [[self rowLabels] indexOfObject:rowFromPosition(position)];
	Ship *newShip = [[Ship alloc] initWithRotation:rotation andX:x andY:y andType:type];
	NSSet *positions = [newShip positionsWithRowLabels:[self rowLabels] andColumnlabels:[self columnLabels]];
	if (positions == nil)
		return NO; //it didn't fit
	
	for (Ship *ship in self.ships)
	{
		NSSet *compPositions = [ship positionsWithRowLabels:[self rowLabels] andColumnlabels:[self columnLabels]];
		if ([compPositions intersectsSet:positions])
			return NO; //there was an intersection
	}
	
	//add it!
	[self.ships addObject:newShip];
	
	//and shuffle
	[self reloadLabels];
	
	return YES;
}

-(void)reloadLabels
{
	self.rowLabels = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", nil];
	self.columnLabels = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
	
	if (self.phase == kPhasePlace)
	{
		self.rowLabels = [self shuffle:self.rowLabels];
		self.columnLabels = [self shuffle:self.columnLabels];
	}
}

-(NSArray *)shuffle:(NSArray *)array
{
	NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
	for (NSUInteger i = 0; i < array.count; i++)
	{
		[mArray exchangeObjectAtIndex:i withObjectAtIndex:((NSUInteger)arc4random_uniform((u_int32_t)(array.count - i)) + i)];
	}
	return mArray;
}

-(BOOL)defeated
{
	for (NSUInteger y = 0; y < BOARD_HEIGHT; y++)
	{
		for (NSUInteger x = 0; x < BOARD_WIDTH; x++)
		{
			NSString *row = self.rowLabels[y];
			NSString *column = self.columnLabels[x];
			NSString *position = positionFrom(row, column);
			
			if (![self.hits containsObject:position])
			{
				//TODO: return NO if there is a ship here
			}
		}
	}
	return YES;
}

@end
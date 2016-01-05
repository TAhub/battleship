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

-(id)initWithFleet:(NSString *)fleet
{
	if (self = [super init])
	{
		NSError *error;
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[fleet dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
		
		self.ships = [NSMutableArray new];
		for (NSDictionary *ship in [json allValues])
			[self.ships addObject:[[Ship alloc] initWithShipJSON:ship]];
		
		self.phase = kPhaseWait;
		[self reloadLabels];
	}
	return self;
}

-(NSString *)fleet
{
	NSError *error;
	NSMutableDictionary *dict = [NSMutableDictionary new];
	for (Ship *ship in self.ships)
		dict[[NSString stringWithFormat:@"ship%i", ship.type]] = [ship shipJSON];
	NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
	NSString *f = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return f;
}

-(BOOL)attackPosition:(NSString *)position
{
	[self.shots addObject:position];
	for (Ship *ship in self.ships)
	{
		NSArray *positions = [ship positionsWithRowLabels:self.rowLabels andColumnlabels:self.columnLabels allowOverflow:NO];
		if ([positions containsObject:position])
		{
			//it was a hit!
			[self.hits addObject:position];
//			NSLog(@"Direct hit!");
			return YES;
		}
	}
//	NSLog(@"Miss!");
	return NO;
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
		NSArray *positions = [ship positionsWithRowLabels:self.rowLabels andColumnlabels:self.columnLabels allowOverflow:NO];
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
	NSArray *positions = [newShip positionsWithRowLabels:self.rowLabels andColumnlabels:self.columnLabels allowOverflow:NO];
	if (positions == nil)
		return NO; //it didn't fit
	
	for (Ship *ship in self.ships)
	{
		NSArray *compPositions = [ship positionsWithRowLabels:self.rowLabels andColumnlabels:self.columnLabels allowOverflow:NO];
		if ([[NSSet setWithArray:positions] intersectsSet:[NSSet setWithArray:compPositions]])
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
	NSMutableArray *rowLabels = [NSMutableArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", nil];
	NSMutableArray *columnLabels = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
	
	if (self.phase == kPhasePlace)
	{
		[self shuffle:rowLabels];
		[self shuffle:columnLabels];
	}
	
	//add invisible extra stuff
	[rowLabels addObjectsFromArray:[NSArray arrayWithObjects:@"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", nil]];
	[columnLabels addObjectsFromArray:[NSArray arrayWithObjects:@"9", @"10", @"11", @"12", @"13", @"14", @"15", nil]];
	
	self.rowLabels = rowLabels;
	self.columnLabels = columnLabels;
}

-(void)shuffle:(NSMutableArray *)array
{
	for (NSUInteger i = 0; i < array.count; i++)
		[array exchangeObjectAtIndex:i withObjectAtIndex:((NSUInteger)arc4random_uniform((u_int32_t)(array.count - i)) + i)];
}

-(int)shipAlive:(Ship *)ship
{
	NSArray *positions = [ship positionsWithRowLabels:self.rowLabels andColumnlabels:self.columnLabels allowOverflow:NO];
	for (NSString *position in positions)
		if (![self.hits containsObject:position])
			return YES;
	return NO;
}

-(BOOL)defeated
{
	for (Ship *ship in self.ships)
		if ([self shipAlive:ship])
			return NO;
	return YES;
}

@end
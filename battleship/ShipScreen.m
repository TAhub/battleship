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

-(BOOL)placeShipAtPosition:(NSString *)position withRotation:(BOOL)rotation andType:(ShipType)type
{
	//TODO: implement
	return YES;
}

-(void)reloadLabels
{
	self.columnLabels = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", nil];
	self.rowLabels = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", nil];
	
	
	if (![self allShipsPlaced])
	{
		//TODO: shuffle row and column labels randomly
	}
}

-(BOOL)defeated
{
	//TODO: implement
	return NO;
}

-(BOOL)allShipsPlaced
{
	//TODO: implement
	return YES;
}

-(ShipType)nextShipType
{
	//TODO: implement
	return kPatrolBoat;
}

@end
//
//  ShotScreen.m
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "ShotScreen.h"

@implementation ShotScreen

-(id)init
{
	if (self = [super init])
	{
		self.shots = [NSMutableSet new];
		self.hits = [NSMutableSet new];
	}
	return self;
}


@end
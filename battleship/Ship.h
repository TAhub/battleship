//
//  Ship.h
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Ship: NSObject

@property NSUInteger x;
@property NSUInteger y;
@property BOOL rotation;
@property ShipType type;

-(id)initWithRotation:(BOOL)rotation andX:(NSUInteger)x andY:(NSUInteger)y andType:(ShipType)type;


//this returns a list of all the spots the ship covers
-(NSSet *)positionsWithRowLabels:(NSArray *)rows andColumnlabels:(NSArray *)columns;

@end
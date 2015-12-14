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

@property (strong, nonatomic) NSString *position;
@property BOOL rotation;
@property ShipType type;

@end
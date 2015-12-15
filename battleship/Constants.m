//
//  Constants.m
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

NSString *columnFromPosition(NSString *position)
{
	return [position substringFromIndex:1];
}

NSString *rowFromPosition(NSString *position)
{
	return [position substringToIndex:1];
}

NSString *positionFrom(NSString *row, NSString *column)
{
	return [NSString stringWithFormat:@"%@%@", row, column];
}
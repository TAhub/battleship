//
//  StarfieldView.m
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "StarfieldView.h"
#import "Constants.h"

@implementation StarfieldView

-(void)setupStarfield
{
	self.backgroundColor = [UIColor blackColor];
	
	//make stars
	for (int i = 0; i < STARFIELD_NUMBER_STARS; i++)
	{
		CGFloat x = (CGFloat)arc4random_uniform((u_int32_t)self.frame.size.width);
		CGFloat y = (CGFloat)arc4random_uniform((u_int32_t)self.frame.size.height);
		
		CGRect frame = CGRectMake(x - STARFIELD_STAR_SIZE / 2, y - STARFIELD_STAR_SIZE / 2, STARFIELD_STAR_SIZE, STARFIELD_STAR_SIZE);
		UIView *view = [[UIView alloc] initWithFrame:frame];
		
		
		switch(arc4random_uniform(6))
		{
			case 0:
			case 1:
			case 2: view.backgroundColor = [UIColor whiteColor]; break;
			case 3: view.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:1.0 alpha:1.0]; break;
			default: view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.4 alpha:1.0]; break;
		}
		
		
		[self insertSubview:view atIndex:0];
		
		CGFloat distance = (self.frame.size.width - x) / self.frame.size.width;
		
		__weak typeof(self) weakSelf = self;
		
		[UIView animateWithDuration:distance * STARFIELD_STAR_LENGTH delay:0 options:UIViewAnimationOptionCurveLinear  animations:
		^(){
			view.frame = CGRectMake(weakSelf.frame.size.width + STARFIELD_STAR_SIZE / 2, view.frame.origin.y, STARFIELD_STAR_SIZE, STARFIELD_STAR_SIZE);
		} completion:
		^(BOOL success){
			//send back to the beginning
			[weakSelf moveStar:view];
		}];
	}
}

-(void)moveStar:(UIView *)view
{
	CGFloat y = (CGFloat)arc4random_uniform((u_int32_t)self.frame.size.height);
	
	view.frame = CGRectMake(-STARFIELD_STAR_SIZE / 2, y - STARFIELD_STAR_SIZE / 2, STARFIELD_STAR_SIZE, STARFIELD_STAR_SIZE);
	
	__weak typeof(self) weakSelf = self;
	
	[UIView animateWithDuration:STARFIELD_STAR_LENGTH delay:0 options:UIViewAnimationOptionCurveLinear  animations:
	^(){
		view.frame = CGRectMake(weakSelf.frame.size.width + STARFIELD_STAR_SIZE / 2, view.frame.origin.y, STARFIELD_STAR_SIZE, STARFIELD_STAR_SIZE);
	} completion:
	^(BOOL success){
		[weakSelf moveStar:view];
	}];
}

@end

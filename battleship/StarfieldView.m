//
//  StarfieldView.m
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "StarfieldView.h"
#import "Constants.h"

@interface StarfieldView()

@property (strong, nonatomic) NSMutableArray *stars;
@property CGFloat fineness;

@end

@implementation StarfieldView

-(void)setupStarfieldWithFineness:(CGFloat)fineness
{
	self.stars = [NSMutableArray new];
	
	self.fineness = fineness;
	self.backgroundColor = [UIColor blackColor];
	[self makeStars];
	
	//setup listeners so the stars don't line up
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadStars:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadStars:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)unloadStars:(id)sender
{
	for (UIView *star in self.stars)
		[star removeFromSuperview];
	[self.stars removeAllObjects];
}

-(void)reloadStars:(id)sender
{
	[self makeStars];
}

-(void)makeStars
{
	CGFloat size = STARFIELD_STAR_SIZE * self.fineness;
	
	//make stars
	for (int i = 0; i < STARFIELD_NUMBER_STARS / self.fineness; i++)
	{
		CGFloat x = (CGFloat)arc4random_uniform((u_int32_t)self.bounds.size.width);
		CGFloat y = (CGFloat)arc4random_uniform((u_int32_t)self.bounds.size.height);
		
		CGRect frame = CGRectMake(x - size / 2, y - size / 2, size, size);
		UIView *view = [[UIView alloc] initWithFrame:frame];
		
		[self.stars addObject:view];
		
		switch(arc4random_uniform(6))
		{
			case 0:
			case 1:
			case 2: view.backgroundColor = [UIColor whiteColor]; break;
			case 3: view.backgroundColor = [UIColor colorWithRed:0.4 green:0.4 blue:1.0 alpha:1.0]; break;
			default: view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.4 alpha:1.0]; break;
		}
		
		
		[self insertSubview:view atIndex:0];
		
		CGFloat distance = (self.bounds.size.width - x) / self.bounds.size.width;
		
		__weak typeof(self) weakSelf = self;
		
		[UIView animateWithDuration:distance * STARFIELD_STAR_LENGTH delay:0 options:UIViewAnimationOptionCurveLinear  animations:
		^(){
			view.frame = CGRectMake(weakSelf.bounds.size.width + size / 2, y - size / 2, size, size);
		} completion:
		^(BOOL success){
			//send back to the beginning
			[weakSelf moveStar:view];
		}];
	}
}

-(void)moveStar:(UIView *)view
{
	CGFloat size = STARFIELD_STAR_SIZE * self.fineness;
	CGFloat y = (CGFloat)arc4random_uniform((u_int32_t)self.bounds.size.height);
	
	view.frame = CGRectMake(-size / 2, y - size / 2, size, size);
	
	__weak typeof(self) weakSelf = self;
	
	[UIView animateWithDuration:STARFIELD_STAR_LENGTH delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat animations:
	^(){
		view.frame = CGRectMake(weakSelf.bounds.size.width + size / 2, y - size / 2, size, size);
	} completion:
	^(BOOL success){
		CGFloat y = (CGFloat)arc4random_uniform((u_int32_t)weakSelf.bounds.size.height);
		view.frame = CGRectMake(-size / 2, y - size / 2, size, size);
	}];
}

@end

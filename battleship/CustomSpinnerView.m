//
//  CustomSpinnerView.m
//  battleship
//
//  Created by Theodore Abshire on 12/21/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "CustomSpinnerView.h"
#import "Constants.h"

@implementation CustomSpinnerView

-(CGFloat)squareWidth
{
	return self.superview.frame.size.width / (SPINNER_COLUMNS * 2);
}

-(CGFloat)squareHeight
{
	return [self squareWidth];
}

-(void)startAnimatingWithMessage:(NSString *)message
{
	CGFloat width = [self squareWidth];
	CGFloat height = [self squareHeight];
	for (int y = 0; y < SPINNER_ROWS; y++)
		for (int x = 0; x < SPINNER_COLUMNS; x++)
		{
			int i = y + (SPINNER_COLUMNS - x) * SPINNER_ROWS;
			
			//make the squares
			CGRect frame = CGRectMake(width * x - width * SPINNER_COLUMNS, self.frame.origin.y - (height * SPINNER_ROWS / 2) + y * height, width, height);
			UIView *view = [[UIView alloc] initWithFrame:frame];
			view.backgroundColor = MARKER_HIT_FOCUS;
			[self.superview addSubview:view];
			
			//repeat
			[self animateViewInner:view startDelay:i*SPINNER_OFFSET];
		}
	
	//make the fading label
	UIFont *font = [UIFont fontWithName:@"Avenir" size:24];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.center.y, self.superview.frame.size.width, 100)];
	label.font = font;
	label.textAlignment = NSTextAlignmentCenter;
	label.text = message;
	label.center = self.center;
	[self.superview addSubview:label];
	
}

-(void)animateViewInner:(UIView *)view startDelay:(CGFloat)delay
{
	CGFloat width = [self squareWidth];
	CGFloat height = [self squareHeight];
	__weak typeof(self) weakSelf = self;
	
	[UIView animateWithDuration:SPINNER_LENGTH delay:SPINNER_HOLD+delay options:UIViewAnimationOptionCurveEaseInOut animations:
	^(){
		view.frame = CGRectMake(view.frame.origin.x + weakSelf.frame.origin.x + (width * SPINNER_COLUMNS / 2), view.frame.origin.y, width, height);
	} completion:
	^(BOOL success){
		[UIView animateWithDuration:SPINNER_LENGTH delay:SPINNER_HOLD options:UIViewAnimationOptionCurveEaseInOut animations:
		^(){
			view.frame = CGRectMake(view.frame.origin.x + weakSelf.frame.origin.x + (width * SPINNER_COLUMNS / 2), view.frame.origin.y, width, height);
		} completion:
		^(BOOL success){
			view.frame = CGRectMake(view.frame.origin.x - (weakSelf.frame.origin.x * 2) - (width * SPINNER_COLUMNS), view.frame.origin.y, width, height);
			[weakSelf animateViewInner:view startDelay:0];
		}];
	}];
}

@end

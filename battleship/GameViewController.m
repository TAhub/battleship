//
//  GameViewController.m
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "GameViewController.h"

#pragma mark - global functions

NSString *columnFromPosition(NSString *position)
{
	return [position substringToIndex:1];
}

NSString *rowFromPosition(NSString *position)
{
	return [position substringFromIndex:1];
}

#pragma mark - implementation of class

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UIView *shipScreenView;

@property (weak, nonatomic) IBOutlet UIView *shotScreenView;


@end

@implementation GameViewController

#pragma mark - view controller stuff

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.ships = [[ShipScreen alloc] initEmpty];
	self.shots = [ShotScreen new];
	[self reloadShipScreen];
	[self reloadShotScreen];
}


#pragma mark - helper functions

-(NSUInteger)xFrom:(NSString *)position
{
	return [self.ships.columnLabels indexOfObject:columnFromPosition(position)];
}

-(NSUInteger)yFrom:(NSString *)position
{
	return [self.ships.rowLabels indexOfObject:rowFromPosition(position)];
}

-(void)reloadScreenInitial:(UIView *)screen
{
	for (UIView *subview in screen.subviews)
		[subview removeFromSuperview];
	
	//place labels
	CGFloat squareWidth = screen.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = screen.frame.size.height / BOARD_HEIGHT;
	for (NSUInteger y = 0; y < BOARD_HEIGHT; y++)
		for (NSUInteger x = 0; x < BOARD_WIDTH; x++)
		{
			//make the frame view for the label
			CGRect frame = CGRectMake(squareWidth * x, squareHeight * y, squareWidth, squareHeight);
			UIView *frameView = [[UIView alloc] initWithFrame:frame];
			[screen addSubview:frameView];
			
			//make the label itself
			UILabel *label = [UILabel new];
			NSString *columnLabel = self.ships.columnLabels[x];
			NSString *rowLabel =  self.ships.rowLabels[y];
			label.text = [NSString stringWithFormat:@"%@%@", columnLabel, rowLabel];
			label.textColor = [UIColor grayColor];
			[label setTranslatesAutoresizingMaskIntoConstraints:NO];
			
			//put the label inside the frame view
			[frameView addSubview:label];
			[frameView addConstraint:[NSLayoutConstraint constraintWithItem:frameView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
			[frameView addConstraint:[NSLayoutConstraint constraintWithItem:frameView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
		}
}

-(void)reloadShipScreen
{
	[self reloadScreenInitial:self.shipScreenView];
}

-(void)reloadShotScreen
{
	[self reloadScreenInitial:self.shotScreenView];
}


@end

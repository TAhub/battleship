//
//  GameViewController.m
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "GameViewController.h"
#import "Ship.h"

#pragma mark - implementation of class

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UIView *bigView;
@property (weak, nonatomic) IBOutlet UIView *smallView;

@property (strong, nonatomic) Ship *pickedUpShip;
@property (strong, nonatomic) Ship *pickedUpShipRestore;

@property BOOL animating;

@end

@implementation GameViewController

#pragma mark - view controller stuff

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.ships = [[ShipScreen alloc] initEmpty];
	self.shots = [ShotScreen new];
	[self reloadSmallScreen];
	[self reloadBigScreen];
	
	UITapGestureRecognizer *bigTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigTapSelector:)];
	[self.bigView addGestureRecognizer:bigTap];
	
	self.pickedUpShip = nil;
	self.pickedUpShipRestore = nil;
	
	self.animating = false;
}

-(void)bigTapSelector:(UITapGestureRecognizer *)sender
{
	NSString *position = [self positionFromGestureRecognizer:sender inView:self.bigView];
	
	NSLog(@"big screen: %@", position);
	
	if (self.animating) { return; }
	
	switch(self.ships.phase)
	{
		case kPhaseShoot:
			//TODO: shoot there
			//this will be heavily dependent on network calls
			
			
			break;
		case kPhasePlace:
			{
				Ship *atPos = [self.ships shipAtPosition:position];
				
				if (atPos != nil)
				{
					if (self.pickedUpShip != nil) //return the ship you have picked up already
						[self.ships.ships addObject:self.pickedUpShipRestore];
					
					
					//pick up a ship
					self.pickedUpShipRestore = [self.ships removeShipOfType:atPos.type];
					self.pickedUpShip = [[Ship alloc] initWithRotation:atPos.rotation andX:0 andY:0 andType:atPos.type];
					
					[self reloadBigScreen];
					[self reloadSmallScreen];
				}
				else if (self.pickedUpShip != nil)
				{
					NSArray *fromShipViews = [self shipViews:self.smallView ship:self.pickedUpShip];
					NSArray *toShipViews = [self shipViews:self.bigView ship:[[Ship alloc] initWithRotation:self.pickedUpShip.rotation andX:[[self.ships columnLabels] indexOfObject:columnFromPosition(position)] andY:[[self.ships rowLabels] indexOfObject:rowFromPosition(position)] andType:self.pickedUpShip.type]];
					
					//try to place the ship there
					if ([self.ships placeShipAtPosition:position withRotation:self.pickedUpShip.rotation andType:self.pickedUpShip.type])
					{
						//do an animation
						
						
						[self reloadBigScreen];
						[self reloadSmallScreen];
						
						//it's done
						self.pickedUpShipRestore = nil;
						self.pickedUpShip = nil;
					}
				}
			}
			break;
		case kPhaseWait: break;
	}
}

//-(void)shipPartTranslateFrom:(NSArray *)from to:(NSArray *)to completion:^()completion
//{
//	[UIView animateWithDuration:<#(NSTimeInterval)#> animations:<#^(void)animations#> completion:<#^(BOOL finished)completion#>]
//	
//	[UIView animateWithDuration:SHIP_ANIM_LENGTH animations:
//	 ^(){
//		 for
//			 } completion:
//	 ^(BOOL success){
//		 
//	 }];
//}

- (IBAction)rotate
{
	if (self.animating) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip != nil)
	{
		self.pickedUpShip.rotation = !self.pickedUpShip.rotation;
		[self reloadSmallScreen];
	}
}

- (IBAction)done
{
	if (self.animating) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip == nil)
	{
		//TODO: start the match
	}
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

-(void)reloadScreenInitial:(UIView *)screen placeLabels:(BOOL)labels
{
	for (UIView *subview in screen.subviews)
		[subview removeFromSuperview];
	
	if (!labels)
		return;
		
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
			label.text = positionFrom(rowLabel, columnLabel);
			label.textColor = [UIColor grayColor];
			[label setTranslatesAutoresizingMaskIntoConstraints:NO];
			
			//put the label inside the frame view
			[frameView addSubview:label];
			[frameView addConstraint:[NSLayoutConstraint constraintWithItem:frameView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
			[frameView addConstraint:[NSLayoutConstraint constraintWithItem:frameView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
		}
}

-(NSArray *)shipViews:(UIView *)screen ship:(Ship *)ship
{
	CGFloat squareWidth = screen.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = screen.frame.size.height / BOARD_HEIGHT;
	
	NSMutableArray *array = [NSMutableArray new];
	NSSet *positions = [ship positionsWithRowLabels:[self.ships rowLabels] andColumnlabels:[self.ships columnLabels]];
	for (NSString *position in positions)
	{
		NSUInteger x = [self xFrom:position];
		NSUInteger y = [self yFrom:position];
		
		CGRect frame = CGRectMake(x * squareWidth, y * squareHeight, squareWidth, squareHeight);
		UIView *shipSquare = [[UIView alloc] initWithFrame:frame];
		shipSquare.backgroundColor = [UIColor yellowColor];
		[array addObject:shipSquare];
	}
	return array;
}

-(void)drawShip:(UIView *)screen ship:(Ship *)ship
{
	NSArray *shipViews = [self shipViews:screen ship:ship];
	for (UIView *view in shipViews)
		[screen addSubview:shipViews];
}

-(void)drawShips:(UIView *)screen
{
	for (Ship *ship in self.ships)
		[self drawShip:screen ship:ship];
}

-(void)drawShots:(UIView *)screen
{
	
}

-(void)reloadBigScreen
{
	[self reloadScreenInitial:self.bigView placeLabels:YES];
	
	if (self.ships.phase != kPhasePlace)
		[self drawShots:self.bigView];
	else
		[self drawShips:self.bigView];
}

-(void)reloadSmallScreen
{
	[self reloadScreenInitial:self.smallView placeLabels:NO];
	
	if (self.ships.phase != kPhasePlace)
		[self drawShips:self.smallView];
	else if (self.pickedUpShip != nil)
		[self drawShip:self.smallView ship:self.pickedUpShip];
}

-(NSString *)positionFromGestureRecognizer:(UITapGestureRecognizer *)recognizer inView:(UIView *)view
{
	CGPoint point = [recognizer locationInView:view];
	point.x = point.x * BOARD_WIDTH / view.frame.size.width;
	point.y = point.y * BOARD_HEIGHT / view.frame.size.height;
	
	NSString *row = [self.ships rowLabels][(NSUInteger)(point.y)];
	NSString *column = [self.ships columnLabels][(NSUInteger)(point.x)];
	return positionFrom(row, column);
}


@end

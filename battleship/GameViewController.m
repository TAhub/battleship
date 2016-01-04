//
//  GameViewController.m
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "GameViewController.h"
#import "Ship.h"
#import "StarfieldView.h"
#import "FadeText.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark - implementation of class
@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UIView *bigView;
@property (weak, nonatomic) IBOutlet UIView *smallView;

@property (strong, nonatomic) UIView *bigViewInner;
@property (strong, nonatomic) UIView *smallViewInner;

@property (strong, nonatomic) Ship *pickedUpShip;
@property (strong, nonatomic) Ship *pickedUpShipRestore;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *rotButton;
@property (weak, nonatomic) IBOutlet UIButton *randButton;


@property (strong, nonatomic) NSDate *beginTime;
@property int beginPhase;

@property (strong, nonatomic) UIView *timerView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *tickTimer;

@property (strong, nonatomic) AVAudioPlayer *_largeExplosion;
@property (strong, nonatomic) AVAudioPlayer *faildExplosion;
@property (strong, nonatomic) AVAudioPlayer *smallExplosion;

@property int animating;

@end

@implementation GameViewController

//SystemSoundID _threeExplosionsID;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[NSTimer scheduledTimerWithTimeInterval:PARSE_HEARTBEAT target:self selector:@selector(parseHeartbeat:) userInfo:nil repeats:YES];
	
	self.beginTime = [NSDate date];
	self.beginPhase = 0;
	
	[self resetTimer];
	
	//set borders
//	self.doneButton.layer.cornerRadius = 6;
//	self.rotButton.layer.cornerRadius = 6;
//	self.randButton.layer.cornerRadius = 6;
	
	self.smallView.layer.cornerRadius = 10;
	self.smallView.layer.borderWidth = BOARD_BORDER;
	self.smallView.layer.borderColor = [[UIColor cyanColor] CGColor];
	self.bigView.layer.borderWidth = BOARD_BORDER;
	self.bigView.layer.borderColor = [[UIColor cyanColor] CGColor];
	self.bigView.layer.cornerRadius = 10;
	
	NSString *path = [NSString stringWithFormat:@"%@/3Explosions.mp3", [[NSBundle mainBundle] resourcePath]];
	NSURL *soundURL = [NSURL fileURLWithPath:path];
	__largeExplosion = [[AVAudioPlayer alloc]initWithContentsOfURL:soundURL error:nil];
	__largeExplosion.volume = 0.7;
	
	NSString *smallPath = [NSString stringWithFormat:@"%@/smallExplosion.mp3", [[NSBundle mainBundle] resourcePath]];
	NSURL *soundUrl = [NSURL fileURLWithPath:smallPath];
	_smallExplosion = [[AVAudioPlayer alloc]initWithContentsOfURL:soundUrl error:nil];
	_smallExplosion.volume = 0.7;
	
	NSString *failedpath = [NSString stringWithFormat:@"%@/failedExplosion.mp3", [[NSBundle mainBundle] resourcePath]];
	NSURL *soundURl = [NSURL fileURLWithPath:failedpath];
	_faildExplosion = [[AVAudioPlayer alloc]initWithContentsOfURL:soundURl error:nil];
	_faildExplosion.volume = 0.7;
	
}

#pragma mark - view controller stuff

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	
	//tint color the buttons
	[self.doneButton setImage: [self.doneButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[self.rotButton setImage: [self.rotButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[self.randButton setImage: [self.randButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	self.doneButton.tintColor = [UIColor cyanColor];
	self.rotButton.tintColor = [UIColor cyanColor];
	self.randButton.tintColor = [UIColor cyanColor];
	
	
	[(StarfieldView *)(self.view) setupStarfieldWithFineness:1];
	
	self.ships = [[ShipScreen alloc] initEmpty];
	
	self.bigViewInner = [[UIView alloc] initWithFrame:CGRectMake(BOARD_BORDER - 1, BOARD_BORDER - 1, self.bigView.frame.size.width - 2 * BOARD_BORDER + 2, self.bigView.frame.size.height - 2 * BOARD_BORDER + 2)];
	self.smallViewInner = [[UIView alloc] initWithFrame:CGRectMake(BOARD_BORDER - 1, BOARD_BORDER - 1, self.smallView.frame.size.width - 2 * BOARD_BORDER + 2, self.smallView.frame.size.height - 2 * BOARD_BORDER + 2)];
	[self reloadSmallScreen];
	[self reloadBigScreen];
	
	UITapGestureRecognizer *bigTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigTapSelector:)];
	[self.bigView addGestureRecognizer:bigTap];
	
	self.pickedUpShip = nil;
	self.pickedUpShipRestore = nil;
	
	self.animating = 0;
}

-(BOOL)victoryOrDefeatFromModel
{
	if (self.ships.defeated)
	{
		[self.timer invalidate];
		[self.tickTimer invalidate];
		return true;
	}
	if (self.shots.defeated)
	{
		[self.timer invalidate];
		[self.tickTimer invalidate];
		return true;
	}
	return false;
}

-(void)bigTapSelector:(UITapGestureRecognizer *)sender
{
	NSString *position = [self positionFromGestureRecognizer:sender inView:self.bigViewInner];
	[self pressPosition:position];
}

-(void)pressPosition:(NSString *)position
{
	NSLog(@"big screen: %@", position);
	
	if (self.animating > 0) { return; }
	
	switch(self.ships.phase)
	{
		case kPhaseShoot:
			//don't shoot a spot you have already shot
			if (![self.shots.shots containsObject:position])
			{
				BOOL hit = [self.shots attackPosition:position];
				[self stopTimer];
				
				__weak typeof(self) weakSelf = self;
				[self shotAnimFromY:-SHOTS_SIZE_START / 2 toPosition:position isHit:hit inView:self.bigView inScreen:self.shots withCallback:
				^(){
					//send a message to the opponent that you shot that position
					weakSelf.battleObject[@"LastMove"] = position;
					weakSelf.battleObject[@"LastMover"] = [PFUser currentUser].objectId;
					int moveNumber = ((NSNumber *)[weakSelf.battleObject valueForKey:@"MoveNumber"]).intValue;
					weakSelf.battleObject[@"MoveNumber"] = @(moveNumber + 1);
					[weakSelf.battleObject saveInBackground];
					
					NSLog(@"Entered turn %@ through own action.", [weakSelf.battleObject valueForKey:@"MoveNumber"]);
					
					if ([weakSelf victoryOrDefeatFromModel])
						weakSelf.ships.phase = kPhaseOver;
					else //and wait for their move
						weakSelf.ships.phase = kPhaseWait;
					[weakSelf reloadBigScreen];
				}];
			}
			break;
		case kPhasePlace:
			{
				Ship *atPos = [self.ships shipAtPosition:position];
				
				if (atPos != nil)
				{
					NSArray *fromShipViewsBefore = nil;
					NSArray *toShipViewsBefore = nil;
					NSArray *fromShipViews = [self shipViews:self.bigViewInner withShipScreen:self.ships ship:atPos];
					NSArray *toShipViews = nil;
					
					if (self.pickedUpShip != nil) //return the ship you have picked up already
					{
						fromShipViewsBefore = [self shipViews:self.smallViewInner withShipScreen:self.ships ship:self.pickedUpShip];
						[self.ships.ships addObject:self.pickedUpShipRestore];
						toShipViewsBefore = [self shipViews:self.bigViewInner withShipScreen:self.ships ship:self.pickedUpShipRestore];
					}
					
					
					//pick up a ship
					self.pickedUpShipRestore = [self.ships removeShipOfType:atPos.type];
					self.pickedUpShip = [[Ship alloc] initWithRotation:atPos.rotation andX:0 andY:0 andType:atPos.type];
					toShipViews = [self shipViews:self.smallViewInner withShipScreen:self.ships ship:self.pickedUpShip];
					
					//do an animation
					__weak typeof(self) weakSelf = self;
					if (fromShipViewsBefore == nil)
					{
						[self reloadBigScreen];
						[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigViewInner toScreen:self.smallViewInner completion:
						^(){
							[weakSelf reloadSmallScreen];
						}];
					}
					else
					{
						for (UIView *view in self.smallViewInner.subviews)
							[view removeFromSuperview];
						[self shipPartTranslateFrom:fromShipViewsBefore to:toShipViewsBefore fromScreen:self.smallViewInner toScreen:self.bigViewInner completion:
						^(){
							[weakSelf reloadBigScreen];
							[weakSelf shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigViewInner toScreen:self.smallViewInner completion:
							^(){
								[weakSelf reloadSmallScreen];
							}];
						}];
					}
				}
				else if (self.pickedUpShip != nil)
				{
					NSArray *fromShipViews = [self shipViews:self.smallViewInner withShipScreen:self.ships ship:self.pickedUpShip];
					NSArray *toShipViews = [self shipViews:self.bigViewInner withShipScreen:self.ships ship:[[Ship alloc] initWithRotation:self.pickedUpShip.rotation andX:[[self.ships columnLabels] indexOfObject:columnFromPosition(position)] andY:[[self.ships rowLabels] indexOfObject:rowFromPosition(position)] andType:self.pickedUpShip.type]];
					
					//try to place the ship there
					if ([self.ships placeShipAtPosition:position withRotation:self.pickedUpShip.rotation andType:self.pickedUpShip.type])
					{
						//it's done
						self.pickedUpShipRestore = nil;
						self.pickedUpShip = nil;
						
						//do an animation
						[self reloadSmallScreen];
						__weak typeof(self) weakSelf = self;
						[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.smallViewInner toScreen:self.bigViewInner completion:
						^(){
							[weakSelf reloadBigScreen];
						}];
					}
					else
					{
						//there's a collision, so you can't
						//however, to make this clear, a short animation is played
						
						NSArray *fromShipViewsTwo = [self shipViews:self.smallViewInner withShipScreen:self.ships ship:self.pickedUpShip];
						__weak typeof(self) weakSelf = self;
						Ship *storedShip = self.pickedUpShip;
						self.pickedUpShip = nil;
						[self reloadSmallScreen];
						
						[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.smallViewInner toScreen:self.bigViewInner completion:
						^(){
							[weakSelf shipPartTranslateFrom:toShipViews to:fromShipViewsTwo fromScreen:self.bigViewInner toScreen:self.smallViewInner completion:
							^(){
								weakSelf.pickedUpShip = storedShip;
								[weakSelf reloadSmallScreen];
							}];
						}];
					}
				}
			}
			break;
		case kPhaseWait:
			break;
		case kPhaseWaitForOpponent:
			break;
		case kPhaseOver:
			break;
	}
}

- (IBAction)rotate
{
	if (self.animating > 0) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip != nil)
	{
		self.pickedUpShip.rotation = !self.pickedUpShip.rotation;
		[self reloadSmallScreen];
	}
}

- (IBAction)randShips
{
	if (self.animating > 0) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip == nil)
	{
		//get ship images of every ship
		NSMutableArray *images = [NSMutableArray new];
		for (Ship *ship in self.ships.ships)
			[images addObject: [self shipViews:self.bigViewInner withShipScreen:self.ships ship:ship]];
		
		//remove all ships from the ships screen
		[self.ships.ships removeAllObjects];
		
		//keep trying to randomize the layout until it works
		while (![self randomizeShipLayoutInner])
			[self.ships.ships removeAllObjects];
		
		//everything snaps into position, because I can't easily handle rotation here
		[self reloadBigScreen];
	}
}

-(BOOL)randomizeShipLayoutInner
{
	//place the ships at random, one-by-one
	for (int i = 0; i < SHIP_TYPES; i++)
	{
		for (int j = 0;; j++)
		{
			if (j == RANDOM_TRIES)
				return false;
			
			//pick a random position
			int x = arc4random_uniform(BOARD_WIDTH);
			int y = arc4random_uniform(BOARD_HEIGHT);
			
			//pick a random rotation
			BOOL rotation = arc4random_uniform(2) == 0;
			
			//try to place a ship there
			if ([self.ships placeShipAtPosition:positionFrom([self.ships rowLabels][y], [self.ships columnLabels][x]) withRotation:rotation andType:i])
				break;
		}
	}
	return true;
}


-(void)setupMatch
{
	NSString *firstUser = [self.battleObject valueForKey:@"FirstUser"];
	if ([firstUser isEqualToString:[PFUser currentUser].objectId])
	{
		//you go first!
		self.ships.phase = kPhaseShoot;
		
		//since you're in the shooting phase now, turn on the timer
		[self resetTimer];
		
		//get the user's ship state
		NSString *secondFleet = [self.battleObject valueForKey:@"SecondFleet"];
		self.shots = [[ShipScreen alloc] initWithFleet:secondFleet];
	}
	else
	{
		//you go second
		self.ships.phase = kPhaseWait;
		
		NSString *firstFleet = [self.battleObject valueForKey:@"FirstFleet"];
		self.shots = [[ShipScreen alloc] initWithFleet:firstFleet];
	}
	
	[self reloadBigScreen];
	[self reloadSmallScreen];
}

- (IBAction)done
{
	
	if (self.animating > 0) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip == nil)
	{
		[self stopTimer];
		
		self.ships.phase = kPhaseWaitForOpponent;
		[self.ships reloadLabels];
		self.rotButton.hidden = true;
		self.randButton.hidden = true;
		self.doneButton.hidden = true;
		[self reloadBigScreen];
		
		NSString *firstUser = [self.battleObject valueForKey:@"FirstUser"];
		if ([firstUser isEqualToString:[PFUser currentUser].objectId])
			self.battleObject[@"FirstFleet"] = [self.ships fleet];
		else
			self.battleObject[@"SecondFleet"] = [self.ships fleet];
		[self.battleObject saveInBackground];
		
		//start the match anim
		__weak typeof(self) weakSelf = self;
		for (Ship *ship in self.ships.ships)
		{
			NSArray *fromShipViews = [self shipViews:self.bigViewInner withShipScreen:self.ships ship:ship];
			NSArray *toShipViews = [self shipViews:self.smallViewInner withShipScreen:self.ships ship:ship];
			[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigViewInner toScreen:self.smallViewInner completion:
			 ^(){
				 [weakSelf reloadSmallScreen];
			 }];
			
		}
	}
}

#pragma mark - EXPLOSIONS

//- (void)multipleExplosions
//{
////	NSString *path = [NSString stringWithFormat:@"%@/3Explosions.mp3", [[NSBundle mainBundle] resourcePath]];
////	NSURL *soundURL = [NSURL fileURLWithPath:path];
////	__largeExplosion = [[AVAudioPlayer alloc]initWithContentsOfURL:soundURL error:nil];
////	__largeExplosion.volume = 0.7;
//}
//
//- (void)singleExplosion
//{
////	NSString *path = [NSString stringWithFormat:@"%@/smallExplosion.mp3", [[NSBundle mainBundle] resourcePath]];
////	NSURL *soundURL = [NSURL fileURLWithPath:path];
////	_smallExplosion = [[AVAudioPlayer alloc]initWithContentsOfURL:soundURL error:nil];
////	_smallExplosion.volume = 0.6;
//}
//
//- (void)missiedShot
//{
//	NSString *path = [NSString stringWithFormat:@"%@/failedExplosion.mp3", [[NSBundle mainBundle] resourcePath]];
//	NSURL *soundURL = [NSURL fileURLWithPath:path];
//	_faildExplosion = [[AVAudioPlayer alloc]initWithContentsOfURL:soundURL error:nil];
//	_faildExplosion.volume = 0.6;
//}

#pragma mark - parse heartbeat

-(void)returnTimer:(NSTimer *)timer
{
	//pop back to root
	[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)parseHeartbeat:(NSTimer *)timer
{
	if (self.ships.phase == kPhaseOver)
	{
		[NSTimer scheduledTimerWithTimeInterval:PARSE_HEARTBEAT target:self selector:@selector(returnTimer:) userInfo:nil repeats:NO];
		[timer invalidate];
		return;
	}
	
	NSLog(@"Parse heartbeat turn %@!", [self.battleObject valueForKey:@"MoveNumber"]);
	
	if (self.animating > 1) { return; }
	
	int oldMoveNumber = ((NSNumber *)[self.battleObject valueForKey:@"MoveNumber"]).intValue;
	__weak typeof(self) weakSelf = self;
	
	
	//check for opponent crash
	NSTimeInterval timeSinceBeginning = [[NSDate date] timeIntervalSinceDate:self.beginTime];
	int expectedSeconds = (1 + oldMoveNumber - self.beginPhase) * (TIMER_WARNINGLENGTH + TIMER_TIMEOUTLENGTH + 3 * PARSE_HEARTBEAT);
	NSLog(@"Current time is %f seconds. Expected time is %i seconds.", timeSinceBeginning, expectedSeconds);
	
	if (timeSinceBeginning > expectedSeconds)
	{
		//your opponent timed out
		self.ships.phase = kPhaseOver;
		[self reloadBigScreen];
		[self reloadSmallScreen];
		
		[NSTimer scheduledTimerWithTimeInterval:PARSE_HEARTBEAT target:self selector:@selector(returnTimer:) userInfo:nil repeats:NO];
		[timer invalidate];
		return;
	}
	
	
	[self.battleObject fetchInBackgroundWithBlock:
	^(PFObject *object, NSError *error)
	{
		if (error != nil)
		{
			//TODO: handle error
		}
		else if (object != nil)
		{
			weakSelf.battleObject = object;
			
			//based on the phase, take action
			switch(weakSelf.ships.phase)
			{
				case kPhaseWaitForOpponent:
					
					if ([object valueForKey:@"FirstFleet"] != nil && [object valueForKey:@"SecondFleet"] != nil)
					{
						//you're done waiting
						[weakSelf setupMatch];
					}
					
					break;
				case kPhaseWait:
					{
						int newMoveNumber = ((NSNumber *)[object valueForKey:@"MoveNumber"]).intValue;
						NSString *lastMover = [object valueForKey:@"LastMover"];
						if (newMoveNumber > oldMoveNumber && ![lastMover isEqualToString:[PFUser currentUser].objectId])
						{
							//update begin phase and begin move
							weakSelf.beginPhase = newMoveNumber;
							weakSelf.beginTime = [NSDate date];
							
							//they made their move
							NSString *shotAt = [object valueForKey:@"LastMove"];
							
							NSLog(@"Entered turn %@ through opponent action.", [object valueForKey:@"MoveNumber"]);
							
							BOOL hit = [weakSelf.ships attackPosition:shotAt];
							[self shotAnimFromY:weakSelf.view.frame.size.height + SHOTS_SIZE_START / 2 toPosition:shotAt isHit:hit inView:self.smallView inScreen:self.ships withCallback:
							^(){
								if ([weakSelf victoryOrDefeatFromModel])
									weakSelf.ships.phase = kPhaseOver;
								else
								{
									weakSelf.ships.phase = kPhaseShoot;
									
									//set up the timer
									[weakSelf resetTimer];
								}
								[weakSelf reloadBigScreen];
								[weakSelf reloadSmallScreen];
							}];
						}
					}
					break;
				default: break;
			}
		}
	}];
}


#pragma mark - animations

-(void)shuffle:(NSMutableArray *)array
{
	for (NSUInteger i = 0; i < array.count; i++)
		[array exchangeObjectAtIndex:i withObjectAtIndex:((NSUInteger)arc4random_uniform((u_int32_t)(array.count - i)) + i)];
}

-(void)megaExplodeShipInner:(Ship *)ship inView:(UIView *)view inScreen:(ShipScreen *)screen withMagnifier:(CGFloat)magnifier withXs:(NSArray *)xs withYs:(NSArray *)ys andCallback:(void (^)())completion
{
	[__largeExplosion play];

	CGFloat squareWidth = view.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = view.frame.size.height / BOARD_HEIGHT;
	__weak typeof(self) weakSelf = self;
	CGFloat x = ((NSNumber *)xs[0]).floatValue;
	CGFloat y = ((NSNumber *)ys[0]).floatValue;
	[self explosionAnimAround:CGPointMake(x, y) withRadius:(squareWidth + squareHeight) / 4 andMagnifier:magnifier andDurationMod:1 andCallback:
	^(){
		if (xs.count > 1)
		{
			NSMutableArray *newXs = [NSMutableArray arrayWithArray:xs];
			NSMutableArray *newYs = [NSMutableArray arrayWithArray:ys];
			[newXs removeObjectAtIndex:0];
			[newYs removeObjectAtIndex:0];
			[weakSelf megaExplodeShipInner:ship inView:view inScreen:screen withMagnifier:magnifier withXs:newXs withYs:newYs andCallback:completion];
		}
		else
			completion();
	}];
}

#pragma MARK - MegaExplosion

-(void)megaExplodeShip:(Ship *)ship inView:(UIView *)view inScreen:(ShipScreen *)screen withMagnifier:(CGFloat)magnifier withDelayPosition:(NSString *)delayPosition andCallback:(void (^)())completion
{
	CGFloat squareWidth = view.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = view.frame.size.height / BOARD_HEIGHT;
	NSMutableArray *positions = [NSMutableArray arrayWithArray:[ship positionsWithRowLabels:screen.rowLabels andColumnlabels:screen.columnLabels allowOverflow:NO]];
	[positions removeObject:delayPosition];
	[self shuffle:positions];
	[positions addObject:delayPosition];
	NSMutableArray *xs = [NSMutableArray new];
	NSMutableArray *ys = [NSMutableArray new];
	CGFloat xCenter = 0;
	CGFloat yCenter = 0;
	for (NSString *position in positions)
	{
		CGFloat x = [self xFrom:position];
		CGFloat y = [self yFrom:position];
		x = ((x + 0.5) * squareWidth) + view.frame.origin.x;
		y = ((y + 0.5) * squareHeight) + view.frame.origin.y;
		[xs addObject:@(x)];
		[ys addObject:@(y)];
		xCenter += x;
		yCenter += y;
	}
	xCenter /= positions.count;
	yCenter /= positions.count;
	
	self.animating += 1;
	
	__weak typeof(self) weakSelf = self;
	[UIView animateWithDuration:EXPLODE_DELAY_MEGA animations:^(){} completion:
	^(BOOL success){
		[weakSelf megaExplodeShipInner:ship inView:view inScreen:screen withMagnifier:magnifier withXs:xs withYs:ys andCallback:
		^(){
			//do the mega explosion
			[weakSelf explosionAnimAround:CGPointMake(xCenter, yCenter) withRadius:(squareHeight + squareWidth) / 4 andMagnifier:EXPLODE_MAG_MEGA andDurationMod:1 + positions.count / 5 andCallback:
			^(){
				weakSelf.animating -= 1;
				completion();
			}];
		}];
	}];
}

-(void)explosionAnimAround:(CGPoint)center withRadius:(CGFloat)radius andMagnifier:(CGFloat)magnifier andDurationMod:(CGFloat)durationMod andCallback:(void (^)())completion
{
	[_smallExplosion play];
	
	self.animating += 1;
	
	NSMutableArray *flares = [NSMutableArray new];
	for (int i = 0; i < EXPLODE_FLARES; i++)
	{
		CGFloat x = center.x + arc4random_uniform((u_int32_t)radius * 2) - radius;
		CGFloat y = center.y + arc4random_uniform((u_int32_t)radius * 2) - radius;
		CGFloat size = EXPLODE_FLARE_SIZE - EXPLODE_SIZE_VARIATION + arc4random_uniform(EXPLODE_SIZE_VARIATION * 2);
		size *= magnifier;
		CGRect frame = CGRectMake(x - size / 2, y - size / 2, size, size);
		UIView *flare = [[UIView alloc] initWithFrame:frame];
		flare.backgroundColor = [UIColor redColor];
		[self.view addSubview:flare];
		[flares addObject:flare];
	}
	
	__weak typeof(self) weakSelf = self;
	
	[UIView animateWithDuration:EXPLODE_ANIM_LENGTH * durationMod delay:0 options:UIViewAnimationOptionCurveEaseIn animations:
	 ^(){
		 for (UIView *flare in flares)
		 {
			 CGFloat angle = arc4random_uniform(200) * M_PI / 100;
			 CGFloat distance = (arc4random_uniform(70) + 30) * EXPLODE_FLARE_DISTANCE / 100;
			 distance *= magnifier;
			 CGFloat x = center.x + cos(angle) * distance;
			 CGFloat y = center.y + sin(angle) * distance;
			 CGFloat size = EXPLODE_FLARE_SIZE_END - EXPLODE_SIZE_VARIATION + arc4random_uniform(EXPLODE_SIZE_VARIATION * 2);
			 size *= magnifier;
			 CGRect frame = CGRectMake(x - size / 2, y - size / 2, size, size);
			 flare.frame = frame;
			 flare.alpha = 0.12;
			 flare.layer.backgroundColor = [[UIColor colorWithRed:0.8 green:0.65 blue:0.65 alpha:1] CGColor];
		 }
	 } completion:
	 ^(BOOL success){
		 for (UIView *flare in flares)
			 [flare removeFromSuperview];
		 
		 completion();
		 weakSelf.animating -= 1;
	 }];
}


-(void)shotAnimFromY:(CGFloat)y toPosition:(NSString *)position isHit:(BOOL)hit inView:(UIView *)view inScreen:(ShipScreen *)screen withCallback:(void (^)())completion
{
	[_faildExplosion play];

	__weak typeof(self) weakSelf = self;
	
	CGFloat magnifier = 1;
	if (view != self.bigViewInner)
		magnifier = EXPLODE_MAG_SMALL;
	
	CGFloat x = (CGFloat)arc4random_uniform((u_int32_t)(self.view.frame.size.width));
	CGRect frame = CGRectMake(x - SHOTS_SIZE_START / 2, y, SHOTS_SIZE_START, SHOTS_SIZE_START);
	UIView *shotView = [[UIView alloc] initWithFrame:frame];
	shotView.backgroundColor = [UIColor yellowColor];
	[self.view addSubview:shotView];
	
	//animate shooting that position
	self.animating += 1;
	CGFloat squareWidth = view.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = view.frame.size.height / BOARD_HEIGHT;
	CGRect toRect = CGRectMake([self xFrom:position] * squareWidth + squareWidth / 2 + view.frame.origin.x - SHOTS_SIZE / 2, [self yFrom:position] * squareHeight + squareHeight / 2 + view.frame.origin.y - SHOTS_SIZE / 2, SHOTS_SIZE, SHOTS_SIZE);
	[UIView animateWithDuration:SHOTS_ANIM_LENGTH animations:
	 ^(){
		 shotView.frame = toRect;
	 } completion:
	 ^(BOOL success){
		 [shotView removeFromSuperview];
		 
		 if (hit)
			 [weakSelf explosionAnimAround:CGPointMake(toRect.origin.x + toRect.size.width / 2, toRect.origin.y + toRect.size.height / 2) withRadius:(squareWidth + squareHeight) / 4 andMagnifier:magnifier andDurationMod:1 andCallback:
			  ^(){
				  weakSelf.animating -= 1;
				  Ship *hitShip = [screen shipAtPosition:position];
				  if ([screen shipAlive:hitShip])
				  {
					  [weakSelf reloadBigScreen];
					  completion();
				  }
				  else
				  {
					  [weakSelf reloadBigScreen];
					  
					  //temporarily un-set the hit, so that the ship won't show up as dead
					  [screen.hits removeObject:position];
					  NSArray *bits = [weakSelf shipViews:view withShipScreen:screen ship:hitShip];
					  [screen.hits addObject:position];
					  for (UIView *shipBit in bits)
						  [view addSubview:shipBit];
					  
					  //that ship should explode
					  [weakSelf megaExplodeShip:hitShip inView:view inScreen:screen withMagnifier:magnifier withDelayPosition:position andCallback:
					   ^(){
						   [weakSelf reloadBigScreen];
						   completion();
					   }];
				  }
			  }];
		 else
		 {
			 [weakSelf reloadBigScreen];
			 completion();
			 weakSelf.animating -= 1;
		 }
	 }];
}

-(void)shipPartTranslateFrom:(NSArray *)from to:(NSArray *)to fromScreen:(UIView *)fromScreen toScreen:(UIView *)toScreen completion:(void (^)())completion
{	
	self.animating += 1;
	__weak typeof(self) weakSelf = self;
	for (UIView *view in from)
	{
		view.frame = [self.view convertRect:view.frame fromCoordinateSpace:fromScreen];
		[self.view addSubview:view];
	}
	[UIView animateWithDuration:SHIP_ANIM_LENGTH animations:
	 ^(){
		 for (NSUInteger i = 0; i < from.count; i++)
		 {
			 UIView *fromV = from[i];
			 UIView *toV = to[i];
			 fromV.frame = [self.view convertRect:toV.frame fromCoordinateSpace:toScreen];
		 }
	 } completion:
	 ^(BOOL success){
		 for (UIView *view in from)
			 [view removeFromSuperview];
		 weakSelf.animating -= 1;
		 completion();
	 }];
}


#pragma mark - timer functions


-(void)stopTimer
{
	if (self.timerView != nil)
	{
		[self.timerView removeFromSuperview];
		self.timerView = nil;
	}
	
	if (self.timer != nil)
	{
		[self.timer invalidate];
		self.timer = nil;
	}
	
	if (self.tickTimer != nil)
	{
		[self.tickTimer invalidate];
		self.tickTimer = nil;
	}
}

-(void)resetTimer
{
	[self stopTimer];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_WARNINGLENGTH target:self selector:@selector(timerWarning:) userInfo:nil repeats:NO];
}

-(void)timerWarning:(NSTimer *)timer
{
	[self makeTimerView:timer];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TIMEOUTLENGTH target:self selector:@selector(timerForefeit:) userInfo:nil repeats:NO];
	self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(makeTimerView:) userInfo:nil repeats:YES];
}

-(void)makeTimerView:(NSTimer *)timer
{
	if (self.timerView != nil)
	{
		FadeText *ft = (FadeText *)self.timerView;
		int oldTimer = ft.text.intValue;
		[ft fadeInText:[NSString stringWithFormat:STRING_TIME_LEFT, oldTimer - TIMER_INTERVAL]];
	}
	else
	{
		self.timerView = [self addFadeTextToScreen:self.view saying:[NSString stringWithFormat:STRING_TIME_LEFT, TIMER_TIMEOUTLENGTH]];
		((FadeText *)(self.timerView)).textColor = [UIColor whiteColor];
	}
}

-(void)timerForefeit:(NSTimer *)timer
{
	[self resetTimer];
	
	NSLog(@"Oops, you ran out of time!");
	self.ships.phase = kPhaseOver;
	[self reloadSmallScreen];
	[self reloadBigScreen];
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

-(void)reloadScreenInitial:(UIView *)screen placeLabels:(BOOL)labels focusTint:(BOOL)focus
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
			label.textColor = (focus ? [UIColor grayColor] : [UIColor darkGrayColor]);
			[label setTranslatesAutoresizingMaskIntoConstraints:NO];
			
			//put the label inside the frame view
			[frameView addSubview:label];
			[frameView addConstraint:[NSLayoutConstraint constraintWithItem:frameView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
			[frameView addConstraint:[NSLayoutConstraint constraintWithItem:frameView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
		}
}

-(NSArray *)shipViews:(UIView *)screen withShipScreen:(ShipScreen *)ships ship:(Ship *)ship
{
	CGFloat squareWidth = screen.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = screen.frame.size.height / BOARD_HEIGHT;
	
	NSMutableArray *array = [NSMutableArray new];
	NSArray *positions = [ship positionsWithRowLabels:[self.ships rowLabels] andColumnlabels:[self.ships columnLabels] allowOverflow:YES];
	NSArray *bits = [ship shipBits];
	
	for (int i = 0; i < positions.count; i++)
	{
		NSString *position = positions[i];
		NSString *bit = bits[i];
		
		if (![bit isEqualToString:@"hi"])
		{
			NSUInteger x = [self xFrom:position];
			NSUInteger y = [self yFrom:position];
			
			CGRect frame = CGRectMake(x * squareWidth, y * squareHeight, squareWidth, squareHeight);
			UIImageView *shipSquare = [[UIImageView alloc] initWithFrame:frame];
			shipSquare.layer.anchorPoint = CGPointMake(0.5, 0.5);
			if (!ship.rotation)
				shipSquare.transform = CGAffineTransformMakeRotation(M_PI_2);
			
			//make a mask subimage
			int bitA = bit.intValue;
			NSString *bitB = [bit substringFromIndex:2];
			if ([ships.hits containsObject:position])
			{
				if (![ships shipAlive:ship])
					bitB = [NSString stringWithFormat:@"dead_%@", bitB];
				else
					bitB = [NSString stringWithFormat:@"broken_%@", bitB];
			}
			UIImage *baseImage = [UIImage imageNamed:bitB];
			
			CGImageRef ref = CGImageCreateWithImageInRect([baseImage CGImage], CGRectMake(baseImage.size.width / [ship size] * bitA, 0, baseImage.size.height, baseImage.size.width / [ship size]));
			shipSquare.image = [UIImage imageWithCGImage:ref];
			CGImageRelease(ref);
			
			[array addObject:shipSquare];
		}
	}
	return array;
}

-(void)drawShip:(UIView *)screen ship:(Ship *)ship
{
	NSArray *shipViews = [self shipViews:screen withShipScreen:self.ships ship:ship];
	for (UIView *view in shipViews)
		[screen addSubview:view];
}

-(void)drawShips:(UIView *)screen focusTint:(BOOL)focus
{
	[self drawShots:screen fromScreen:self.ships missesOnly:YES focusTint:NO];
	for (Ship *ship in self.ships.ships)
		[self drawShip:screen ship:ship];
}

-(void)drawShots:(UIView *)screen fromScreen:(ShotScreen *)shotScreen missesOnly:(BOOL)missesOnly focusTint:(BOOL)focus
{
	CGFloat squareWidth = screen.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = screen.frame.size.height / BOARD_HEIGHT;
	for (NSString *shot in shotScreen.shots)
	{
		NSUInteger x = [self xFrom:shot];
		NSUInteger y = [self yFrom:shot];
		
		UIImage *hitMarker = [[UIImage imageNamed:@"hitMark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		
		CGRect frame = CGRectMake(x * squareWidth, y * squareHeight, squareWidth, squareHeight);
		if ([shotScreen.hits containsObject:shot])
		{
			if (!missesOnly)
			{
				[_faildExplosion play];

				Ship *shipAt = [self.shots shipAtPosition:shot];
				if ([self.shots shipAlive:shipAt])
				{
					//draw a red rectangle
					UIImageView *shotView = [[UIImageView alloc] initWithFrame:frame];
					shotView.image = hitMarker;
					shotView.tintColor = (focus ? MARKER_HIT_FOCUS : MARKER_HIT);
					[screen addSubview:shotView];
				}
			}
		}
		else
		{
			UIImageView *shotView = [[UIImageView alloc] initWithFrame:frame];
			shotView.image = hitMarker;
			shotView.tintColor = (focus ? MARKER_MISS : MARKER_MISS_FOCUS);
			[screen addSubview:shotView];
		}
	}
	
	if (missesOnly)
		return;
	
	//add broken ships
	for (Ship *ship in self.shots.ships)
		if (![self.shots shipAlive:ship])
		{
			NSArray *bits = [self shipViews:screen withShipScreen:self.shots ship:ship];
			for (UIView *bit in bits)
				[screen addSubview:bit];
		}
}

-(FadeText *)addFadeTextToScreen:(UIView *)screen saying:(NSString *)text
{
	FadeText *t = [FadeText new];
	[t setTranslatesAutoresizingMaskIntoConstraints:NO];
	t.textColor = [UIColor whiteColor];
	t.numberOfLines = 0;
	t.font = [UIFont boldSystemFontOfSize:20];
	[t fadeInText:text];
	[t setTextAlignment:NSTextAlignmentCenter];
	[screen addSubview:t];
	
	NSDictionary *d = [NSDictionary dictionaryWithObject:t forKey:@"t"];
	[screen addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[t]-|" options:0 metrics:nil views:d]];
	[screen addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[t]" options:0 metrics:nil views:d]];
	return t;
}

-(void)reloadBigScreen
{
	[self reloadScreenInitial:self.bigView placeLabels:NO focusTint:NO];
	
	[self.bigView addSubview:self.bigViewInner];
	
	switch(self.ships.phase)
	{
		case kPhasePlace:
			[self reloadScreenInitial:self.bigViewInner placeLabels:YES focusTint:YES];
			[self drawShips:self.bigViewInner focusTint:YES];
			break;
		case kPhaseShoot:
			[self reloadScreenInitial:self.bigViewInner placeLabels:YES focusTint:YES];
			[self drawShots:self.bigViewInner fromScreen:self.shots missesOnly:NO focusTint:YES];
			break;
		case kPhaseWait:
			[self reloadScreenInitial:self.bigViewInner placeLabels:YES focusTint:NO];
			[self drawShots:self.bigViewInner fromScreen:self.shots missesOnly:NO focusTint:NO];
			[self addFadeTextToScreen:self.bigViewInner saying:STRING_WAIT_MOVE];
			break;
		case kPhaseWaitForOpponent:
			[self reloadScreenInitial:self.bigViewInner placeLabels:NO focusTint:NO];
			[self addFadeTextToScreen:self.bigViewInner saying:STRING_WAIT_PLACE];
			break;
		case kPhaseOver:
			[self reloadScreenInitial:self.bigViewInner placeLabels:YES focusTint:NO];
			[self drawShots:self.bigViewInner fromScreen:self.shots missesOnly:NO focusTint:NO];
			if ([self.ships defeated])
				[self addFadeTextToScreen:self.bigViewInner saying:STRING_WIN];
			else if ([self.shots defeated])
				[self addFadeTextToScreen:self.bigViewInner saying:STRING_LOSE];
			else
				[self addFadeTextToScreen:self.bigViewInner saying:STRING_TIMEOUT];
			break;
	}
}

-(void)reloadSmallScreen
{
	[self reloadScreenInitial:self.smallView placeLabels:NO focusTint:NO];
	
	[self.smallView addSubview:self.smallViewInner];
	
	[self reloadScreenInitial:self.smallViewInner placeLabels:NO focusTint:NO];
	
	if (self.ships.phase != kPhasePlace)
		[self drawShips:self.smallViewInner focusTint:YES];
	else if (self.pickedUpShip != nil)
		[self drawShip:self.smallViewInner ship:self.pickedUpShip];
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

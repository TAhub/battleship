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
@import Parse;


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
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;


@property (strong, nonatomic) UIView *timerView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *tickTimer;

@property int animating;

@end

@implementation GameViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    
}

#pragma mark - view controller stuff

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.doneButton.layer.cornerRadius = 6;
	self.rotButton.layer.cornerRadius = 6;
	self.voiceButton.layer.cornerRadius = 6;
	self.smallView.layer.cornerRadius = 10;
	self.smallView.layer.borderWidth = BOARD_BORDER;
	self.smallView.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.bigView.layer.borderWidth = BOARD_BORDER;
	self.bigView.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.bigView.layer.cornerRadius = 10;
	
	[(StarfieldView *)(self.view) setupStarfield];
	
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

-(void)explosionAnimAround:(CGPoint)center withRadius:(CGFloat)radius andCallback:(void (^)())completion
{
	self.animating += 1;
	
	NSMutableArray *flares = [NSMutableArray new];
	for (int i = 0; i < EXPLODE_FLARES; i++)
	{
		CGFloat x = center.x + arc4random_uniform((u_int32_t)radius * 2) - radius;
		CGFloat y = center.y + arc4random_uniform((u_int32_t)radius * 2) - radius;
		CGFloat size = EXPLODE_FLARE_SIZE - EXPLODE_SIZE_VARIATION + arc4random_uniform(EXPLODE_SIZE_VARIATION * 2);
		CGRect frame = CGRectMake(x - size / 2, y - size / 2, size, size);
		UIView *flare = [[UIView alloc] initWithFrame:frame];
		flare.backgroundColor = [UIColor redColor];
		[self.view addSubview:flare];
		[flares addObject:flare];
	}
	
	__weak typeof(self) weakSelf = self;
	
	[UIView animateWithDuration:EXPLODE_ANIM_LENGTH delay:0 options:UIViewAnimationOptionCurveEaseIn animations:
	^(){
		for (UIView *flare in flares)
		{
			CGFloat angle = arc4random_uniform(200) * M_PI / 100;
			CGFloat distance = (arc4random_uniform(70) + 30) * EXPLODE_FLARE_DISTANCE / 100;
			CGFloat x = center.x + cos(angle) * distance;
			CGFloat y = center.y + sin(angle) * distance;
			CGFloat size = EXPLODE_FLARE_SIZE_END - EXPLODE_SIZE_VARIATION + arc4random_uniform(EXPLODE_SIZE_VARIATION * 2);
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

-(void)shotAnimFromY:(CGFloat)y toPosition:(NSString *)position isHit:(BOOL)hit inView:(UIView *)view withCallback:(void (^)())completion
{
	__weak typeof(self) weakSelf = self;
	
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
			[weakSelf explosionAnimAround:CGPointMake(toRect.origin.x + toRect.size.width / 2, toRect.origin.y + toRect.size.height / 2) withRadius:(squareWidth + squareHeight) / 4 andCallback:
			^(){
				[weakSelf reloadBigScreen];
				completion();
				weakSelf.animating -= 1;
			}];
		else
		{
			[weakSelf reloadBigScreen];
			completion();
			weakSelf.animating -= 1;
		}
	}];
}

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
		[ft fadeInText:[NSString stringWithFormat:@"%i seconds left!", oldTimer - TIMER_INTERVAL]];
	}
	else
	{
		self.timerView = [self addFadeTextToScreen:self.view saying:[NSString stringWithFormat:@"%i seconds left!", TIMER_TIMEOUTLENGTH]];
		((FadeText *)(self.timerView)).textColor = [UIColor whiteColor];
	}
}

-(void)timerForefeit:(NSTimer *)timer
{
	[self resetTimer];
	
	//TODO: forefeit
	NSLog(@"Oops, you ran out of time!");
}

-(void)bigTapSelector:(UITapGestureRecognizer *)sender
{
	NSString *position = [self positionFromGestureRecognizer:sender inView:self.bigViewInner];
	[self pressPosition:position];
}

-(void)pressPosition:(NSString *)position
{
	//result of speech here, if you are doing this with speech
	
	
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
				[self shotAnimFromY:-SHOTS_SIZE_START / 2 toPosition:position isHit:hit inView:self.bigView withCallback:
				^(){
					//TODO: send a message to the opponent that you shot that position
			  
					//and wait for their move
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
					NSArray *fromShipViews = [self shipViews:self.bigViewInner ship:atPos];
					NSArray *toShipViews = nil;
					
					if (self.pickedUpShip != nil) //return the ship you have picked up already
					{
						fromShipViewsBefore = [self shipViews:self.smallViewInner ship:self.pickedUpShip];
						[self.ships.ships addObject:self.pickedUpShipRestore];
						toShipViewsBefore = [self shipViews:self.bigViewInner ship:self.pickedUpShipRestore];
					}
					
					
					//pick up a ship
					self.pickedUpShipRestore = [self.ships removeShipOfType:atPos.type];
					self.pickedUpShip = [[Ship alloc] initWithRotation:atPos.rotation andX:0 andY:0 andType:atPos.type];
					toShipViews = [self shipViews:self.smallViewInner ship:self.pickedUpShip];
					
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
					NSArray *fromShipViews = [self shipViews:self.smallViewInner ship:self.pickedUpShip];
					NSArray *toShipViews = [self shipViews:self.bigViewInner ship:[[Ship alloc] initWithRotation:self.pickedUpShip.rotation andX:[[self.ships columnLabels] indexOfObject:columnFromPosition(position)] andY:[[self.ships rowLabels] indexOfObject:rowFromPosition(position)] andType:self.pickedUpShip.type]];
					
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
						
						NSArray *fromShipViewsTwo = [self shipViews:self.smallViewInner ship:self.pickedUpShip];
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
			//TODO: wait for the opponent to make a shot, then display that
			
			break;
		case kPhaseWaitForOpponent:
			//TODO: wait for opponent's "I'm ready" message
			//and when you get it, set your shots screen with their ships state
			
			break;
	}
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

- (IBAction)rotate
{
	if (self.animating > 0) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip != nil)
	{
		self.pickedUpShip.rotation = !self.pickedUpShip.rotation;
		[self reloadSmallScreen];
	}
}

- (IBAction)toggleVoice
{
}


- (IBAction)done
{
	if (self.animating > 0) { return; }
	
	if (self.ships.phase == kPhasePlace && self.pickedUpShip == nil)
	{
		//TODO: start the match
		//you should set the state to kStateWaitForOpponent
		//if they haven't sent a match-start message to you
		//for now though, we're just going directly to shoot phase
		self.ships.phase = kPhaseShoot;
		[self.ships reloadLabels];
		
		//since you're in the shooting phase now, turn on the timer
		[self resetTimer];
		
		//TODO: get the opponent's ship state once the match begins
		self.shots = [[ShipScreen alloc] initEmpty];
		self.shots.phase = kPhaseWait;
		[self.shots reloadLabels];
		self.rotButton.hidden = true;
		[self reloadBigScreen];
		
		//start the match anim
		__weak typeof(self) weakSelf = self;
		for (Ship *ship in self.ships.ships)
		{
			NSArray *fromShipViews = [self shipViews:self.bigViewInner ship:ship];
			NSArray *toShipViews = [self shipViews:self.smallViewInner ship:ship];
			
			[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigViewInner toScreen:self.smallViewInner completion:
			^(){
				[weakSelf reloadSmallScreen];
			}];
		}
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
	NSArray *shipViews = [self shipViews:screen ship:ship];
	for (UIView *view in shipViews)
		[screen addSubview:view];
}

-(void)drawShips:(UIView *)screen
{
	[self drawShots:screen fromScreen:self.ships];
	for (Ship *ship in self.ships.ships)
		[self drawShip:screen ship:ship];
}

-(void)drawShots:(UIView *)screen fromScreen:(ShotScreen *)shotScreen
{
	CGFloat squareWidth = screen.frame.size.width / BOARD_WIDTH;
	CGFloat squareHeight = screen.frame.size.height / BOARD_HEIGHT;
	for (NSString *shot in shotScreen.shots)
	{
		NSUInteger x = [self xFrom:shot];
		NSUInteger y = [self yFrom:shot];
		
		CGRect frame = CGRectMake(x * squareWidth, y * squareHeight, squareWidth, squareHeight);
		UIView *shotView = [[UIView alloc] initWithFrame:frame];
		
		if ([shotScreen.hits containsObject:shot])
			shotView.backgroundColor = [UIColor redColor];
		else
			shotView.backgroundColor = [UIColor whiteColor];
		
		[screen addSubview:shotView];
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
	[self reloadScreenInitial:self.bigView placeLabels:NO];
	
	//TODO: add effects views as appropriate
	//ie starfield, etc
	
	[self.bigView addSubview:self.bigViewInner];
	
	[self reloadScreenInitial:self.bigViewInner placeLabels:(self.ships.phase == kPhasePlace || self.ships.phase == kPhaseShoot)];
	
	switch(self.ships.phase)
	{
		case kPhasePlace:
			[self drawShips:self.bigViewInner];
			break;
		case kPhaseShoot:
			[self drawShots:self.bigViewInner fromScreen:self.shots];
			break;
		case kPhaseWait:
			[self addFadeTextToScreen:self.bigViewInner saying:@"Waiting for\nopponent's move..."];
			break;
		case kPhaseWaitForOpponent:
			[self addFadeTextToScreen:self.bigViewInner saying:@"Waiting for\nopponent to\nplace their ships..."];
			break;
	}
}

-(void)reloadSmallScreen
{
	[self reloadScreenInitial:self.smallView placeLabels:NO];
	
	//TODO: add effects views as appropriate
	//ie starfield, etc
	
	[self.smallView addSubview:self.smallViewInner];
	
	[self reloadScreenInitial:self.smallViewInner placeLabels:NO];
	
	if (self.ships.phase != kPhasePlace)
		[self drawShips:self.smallViewInner];
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

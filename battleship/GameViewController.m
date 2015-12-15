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
#import "OpenEarsService.h"
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>



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


@property BOOL animating;

@end

@implementation GameViewController

#pragma mark - view controller stuff

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	self.doneButton.layer.cornerRadius = 6;
	self.rotButton.layer.cornerRadius = 6;
	self.smallView.layer.cornerRadius = 10;
	self.smallView.layer.borderWidth = 5;
	self.smallView.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.bigView.layer.borderWidth = 5;
	self.bigView.layer.borderColor = [[UIColor whiteColor] CGColor];
	self.bigView.layer.cornerRadius = 10;
	
	[(StarfieldView *)(self.view) setupStarfield];
	
	self.ships = [[ShipScreen alloc] initEmpty];
	
	self.bigViewInner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bigView.frame.size.width, self.bigView.frame.size.height)];
	self.smallViewInner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.smallView.frame.size.width, self.smallView.frame.size.height)];
	[self reloadSmallScreen];
	[self reloadBigScreen];
	
	UITapGestureRecognizer *bigTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bigTapSelector:)];
	[self.bigView addGestureRecognizer:bigTap];
	
	self.pickedUpShip = nil;
	self.pickedUpShipRestore = nil;
	
	self.animating = false;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupOpenEars];
	[self setupOEPocketsphinxController];
	[self setupOELanguageModelGenerator];
}

-(void)bigTapSelector:(UITapGestureRecognizer *)sender
{
	NSString *position = [self positionFromGestureRecognizer:sender inView:self.bigView];
	
	//result of speech here, if you are doing this with speech
	
	
	NSLog(@"big screen: %@", position);
	
	if (self.animating) { return; }
	
	switch(self.ships.phase)
	{
		case kPhaseShoot:
			//don't shoot a spot you have already shot
			if (![self.shots.shots containsObject:position])
			{
				
				[self.shots attackPosition:position];
				[self reloadBigScreen];
				
				self.ships.phase = kPhaseWait;
				
				//TODO: send a message to the opponent that you shot that position
			}
			break;
		case kPhasePlace:
			{
				Ship *atPos = [self.ships shipAtPosition:position];
				
				if (atPos != nil)
				{
					NSArray *fromShipViewsBefore = nil;
					NSArray *toShipViewsBefore = nil;
					NSArray *fromShipViews = [self shipViews:self.bigView ship:atPos];
					NSArray *toShipViews = nil;
					
					if (self.pickedUpShip != nil) //return the ship you have picked up already
					{
						fromShipViewsBefore = [self shipViews:self.smallView ship:self.pickedUpShip];
						[self.ships.ships addObject:self.pickedUpShipRestore];
						toShipViewsBefore = [self shipViews:self.bigView ship:self.pickedUpShipRestore];
					}
					
					
					//pick up a ship
					self.pickedUpShipRestore = [self.ships removeShipOfType:atPos.type];
					self.pickedUpShip = [[Ship alloc] initWithRotation:atPos.rotation andX:0 andY:0 andType:atPos.type];
					toShipViews = [self shipViews:self.smallView ship:self.pickedUpShip];
					
					//do an animation
					__weak typeof(self) weakSelf = self;
					if (fromShipViewsBefore == nil)
					{
						[self reloadBigScreen];
						[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigView toScreen:self.smallView completion:
						^(){
							[weakSelf reloadSmallScreen];
						}];
					}
					else
					{
						for (UIView *view in self.smallView.subviews)
							[view removeFromSuperview];
						[self shipPartTranslateFrom:fromShipViewsBefore to:toShipViewsBefore fromScreen:self.smallView toScreen:self.bigView completion:
						^(){
							[weakSelf reloadBigScreen];
							[weakSelf shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigView toScreen:self.smallView completion:
							^(){
								[weakSelf reloadSmallScreen];
							}];
						}];
					}
				}
				else if (self.pickedUpShip != nil)
				{
					NSArray *fromShipViews = [self shipViews:self.smallView ship:self.pickedUpShip];
					NSArray *toShipViews = [self shipViews:self.bigView ship:[[Ship alloc] initWithRotation:self.pickedUpShip.rotation andX:[[self.ships columnLabels] indexOfObject:columnFromPosition(position)] andY:[[self.ships rowLabels] indexOfObject:rowFromPosition(position)] andType:self.pickedUpShip.type]];
					
					//try to place the ship there
					if ([self.ships placeShipAtPosition:position withRotation:self.pickedUpShip.rotation andType:self.pickedUpShip.type])
					{
						//it's done
						self.pickedUpShipRestore = nil;
						self.pickedUpShip = nil;
						
						//do an animation
						[self reloadSmallScreen];
						__weak typeof(self) weakSelf = self;
						[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.smallView toScreen:self.bigView completion:
						^(){
							[weakSelf reloadBigScreen];
						}];
					}
					else
					{
						//there's a collision, so you can't
						//however, to make this clear, a short animation is played
						
						NSArray *fromShipViewsTwo = [self shipViews:self.smallView ship:self.pickedUpShip];
						__weak typeof(self) weakSelf = self;
						Ship *storedShip = self.pickedUpShip;
						self.pickedUpShip = nil;
						[self reloadSmallScreen];
						
						[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.smallView toScreen:self.bigView completion:
						^(){
							[weakSelf shipPartTranslateFrom:toShipViews to:fromShipViewsTwo fromScreen:self.bigView toScreen:self.smallView completion:
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
	self.animating = true;
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
		weakSelf.animating = false;
		completion();
	}];
}

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
		//you should set the state to kStateWaitForOpponent
		//if they haven't sent a match-start message to you
		//for now though, we're just going directly to shoot phase
		self.ships.phase = kPhaseShoot;
		[self.ships reloadLabels];
		
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
			NSArray *fromShipViews = [self shipViews:self.bigView ship:ship];
			NSArray *toShipViews = [self shipViews:self.smallView ship:ship];
			
			[self shipPartTranslateFrom:fromShipViews to:toShipViews fromScreen:self.bigView toScreen:self.smallView completion:
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

-(void)reloadBigScreen
{
	[self reloadScreenInitial:self.bigView placeLabels:NO];
	
	//TODO: add effects views as appropriate
	//ie starfield, etc
	
	[self.bigView addSubview:self.bigViewInner];
	
	[self reloadScreenInitial:self.bigViewInner placeLabels:YES];
	
	if (self.ships.phase != kPhasePlace)
		[self drawShots:self.bigViewInner fromScreen:self.shots];
	else
		[self drawShips:self.bigViewInner];
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

# pragma Mark - OpenEars Implementacion 
- (void)setupOpenEars
{
	self.openEarsEventObserver = [[OEEventsObserver alloc]init];
	[self.openEarsEventObserver setDelegate:self];
}

// offline speech recognition, you define the vocabulary.
- (void)setupOELanguageModelGenerator
{
	// Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
	OELanguageModelGenerator *lmGenerator  = [[OELanguageModelGenerator alloc]init];
	
//	NSArray *voiceCommands = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"F", @"G", @"H", @"I", @"J", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
	
	NSArray *voiceCommands = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"F", @"G", @"H", @"I", @"J", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
	NSString *englishCommands = @"NameIWantForMyLanguageModelFiles";
	NSError *error = [lmGenerator generateLanguageModelFromArray:voiceCommands withFilesNamed:englishCommands forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
	NSString *lmPath = nil;
	NSString *dicPath = nil;
	
	if (error == nil) {
		lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
		dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLenguageModelFiles"];
	} else {
		NSLog(@"Error: %@", [error localizedDescription]);
	}
}

// Speech Recognition.
- (void)setupOEPocketsphinxController
{
	// Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
	[[OEPocketsphinxController sharedInstance] setActive:true error:nil];
	[[OEPocketsphinxController sharedInstance]startListeningWithLanguageModelAtPath:@"lmPath" dictionaryAtPath:@"dicPath" acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
}

// Call this before setting any OEPocketsphinxController characteristics
//- (void)setupOEPocketsphinxController
//{
//	[[OEPocketsphinxController sharedInstance]setActive:true error:nil];
//	NSArray *voiceCommands = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"F", @"G", @"H", @"I", @"J", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
//}

// OEEventObserver Delegate
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) audioSessionInterruptionDidBegin
{
	//
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
	NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
	NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}


@end

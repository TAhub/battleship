//
//  GameViewController.m
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "GameViewController.h"
#import "OpenEarsService.h"
#import <OpenEars/OEPocketsphinxController.h>


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
	
	UITapGestureRecognizer *shipTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shipTapSelector:)];
	[self.shipScreenView addGestureRecognizer:shipTap];
	
	UITapGestureRecognizer *shotTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shotTapSelector:)];
	[self.shotScreenView addGestureRecognizer:shotTap];
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setupOpenEars];
}

-(void)shipTapSelector:(UITapGestureRecognizer *)sender
{
	NSString *position = [self positionFromGestureRecognizer:sender inView:self.shipScreenView];
	
	NSLog(@"ship screen: %@", position);
	
	if (![self.ships allShipsPlaced])
	{
		//try to place a ship there
		if ([self.ships placeShipAtPosition:position withRotation:true andType:[self.ships nextShipType]])
		{
			[self reloadShipScreen];
			
			if ([self.ships allShipsPlaced])
			{
				//TODO: do a network call to notify the other player you are ready to start, if necessary
			}
		}
	}
}

-(void)shotTapSelector:(UITapGestureRecognizer *)sender
{
	NSString *position = [self positionFromGestureRecognizer:sender inView:self.shotScreenView];
	
	NSLog(@"shot screen: %@", position);
	
	if ([self.ships allShipsPlaced])
	{
		//TODO: shoot there
		//this will be heavily dependent on network calls
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

-(NSString *)positionFromGestureRecognizer:(UITapGestureRecognizer *)recognizer inView:(UIView *)view
{
	CGPoint point = [recognizer locationInView:view];
	point.x = point.x * BOARD_WIDTH / view.frame.size.width;
	point.y = point.y * BOARD_HEIGHT / view.frame.size.height;
	
	NSString *row = [self.ships rowLabels][(NSUInteger)(point.y)];
	NSString *column = [self.ships columnLabels][(NSUInteger)(point.x)];
	return [NSString stringWithFormat:@"%@%@", column, row];
}

-(void)reloadShipScreen
{
	[self reloadScreenInitial:self.shipScreenView];
}

-(void)reloadShotScreen
{
	[self reloadScreenInitial:self.shotScreenView];
}

# pragma Mark - OpenEars Implementacion 
- (void)setupOpenEars
{
	self.openEarsEventObserver = [[OEEventsObserver alloc]init];
	[self.openEarsEventObserver setDelegate:self];
}
// Call this before setting any OEPocketsphinxController characteristics
- (void)setupOEPocketsphinxController
{
	[[OEPocketsphinxController sharedInstance]setActive:true error:nil];
//	NSArray *voiceCommands = @[@"A1", "A2", "A3", "A4", "A5, "A6", "A7", "A8", "A9", "A10","B1", "B2", "B3", "B4", "B5","B6", "B7", "B8", "B9", "B10"];
}

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

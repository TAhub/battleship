//
//  GameViewController.h
//  battleship
//
//  Created by Theodore Abshire on 12/13/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipScreen.h"
#import <OpenEars/OEEventsObserver.h>

// EventsObserver delegate inheritance.
@interface GameViewController : UIViewController <OEEventsObserverDelegate>

//this is the current players ships
@property (strong, nonatomic) ShipScreen *ships;

//this is the spots that the current player has shot at
//it's not a ship screen because you don't know where their ships are
@property (strong, nonatomic) ShipScreen *shots;

@property (strong, nonatomic) OEEventsObserver *openEarsEventObserver;

@end

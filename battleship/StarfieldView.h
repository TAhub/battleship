//
//  StarfieldView.h
//  battleship
//
//  Created by Theodore Abshire on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarfieldView : UIView

-(void)unloadStars:(id)sender;
-(void)setupStarfieldWithFineness:(CGFloat)fineness;

@end

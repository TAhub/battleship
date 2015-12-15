//
//  textAppearLabel.m
//  battleship
//
//  Created by Theodore Abshire on 12/15/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "FadeText.h"
#import "Constants.h"

@interface FadeText()

@property (strong, nonatomic) NSString *fullText;

@end

@implementation FadeText

-(void)fadeInText:(NSString *)text
{
	self.text = @"";
	self.fullText = text;
	
	[NSTimer scheduledTimerWithTimeInterval:FADETEXT_FADE_LENGTH_PER_CHARACTER target:self selector:@selector(fadeInTimer:) userInfo:nil repeats:YES];
}

-(void)fadeInTimer:(NSTimer *)timer
{
	self.text = [self.fullText substringToIndex:self.text.length+1];
	if (self.text == self.fullText)
		[timer invalidate];
}

@end

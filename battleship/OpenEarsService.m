//
//  OpenEarsService.m
//  battleship
//
//  Created by Roman Salazar Lopez on 12/14/15.
//  Copyright © 2015 Roman, Theodore, and Trub. All rights reserved.
//

#import "OpenEarsService.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>

@implementation OpenEarsService

// offline speech recognition, you define the vocabulary.
- (void)setupOELanguageModelGenerator
{
	// Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
	
	OELanguageModelGenerator *lmGenerator  = [[OELanguageModelGenerator alloc]init];
	
	NSArray *words = [NSArray arrayWithObjects:@"words", @"Statements", @"Other Words", @"A prashe", nil];
	NSString *name = @"NameIWantForMyLanguageModelFiles";
	NSError *error = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
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


@end

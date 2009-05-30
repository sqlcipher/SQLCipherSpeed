//
//  TestResultCell.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "TestResultCell.h"

@implementation TestResultCell
@synthesize nameLabel, sqlLabel, normalTimeLabel, encryptedTimeLabel, slowDownLabel;

-(void) dealloc {
	[nameLabel release];
	[sqlLabel release];
	[normalTimeLabel release];
	[encryptedTimeLabel release];
	[slowDownLabel release];
	[super dealloc];
}

@end

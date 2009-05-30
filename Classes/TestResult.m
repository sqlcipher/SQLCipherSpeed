//
//  SpeedTest.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "TestResult.h"


@implementation TestResult
@synthesize name, sql, normalNs, encryptedNs;

-(void) dealloc {
	[name release];
	[sql release];
	[super dealloc];
}

@end

//
//  SpeedTest.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "SqlTest.h"
#include <mach/mach.h>
#include <mach/mach_time.h>

@implementation SqlTest
@synthesize name, sql, normalNs, encryptedNs;

-(void) dealloc {
	[name release];
	[sql release];
	[super dealloc];
}

-(void) setup {
	NSLog(@"placeholder to implement in subclass");
}

-(id) initWithDb:(sqlite3 *)normal encrypted:(sqlite3 *)encrypted {
	[super init];
	normalDb = normal;
	encryptedDb = encrypted;
	return self;
}

-(void) runTests {
	uint64_t        start;
	static mach_timebase_info_data_t    stInfo;
	mach_timebase_info(&stInfo); // initialize time base for timer calculations
	
	[self setup];
	
	start = mach_absolute_time();
	[self runTest:normalDb];
	normalNs = (mach_absolute_time() - start) * stInfo.numer / stInfo.denom;
	
	start = mach_absolute_time();
	[self runTest:encryptedDb];
	encryptedNs = (mach_absolute_time() - start) * stInfo.numer / stInfo.denom;
}

-(void) runTest:(sqlite3 *)db {
	NSLog(@"placeholder to implement in subclass");
}

@end

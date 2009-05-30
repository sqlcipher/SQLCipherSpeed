//
//  TestSuite.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "TestSuite.h"
#import "TestResult.h"
#include <mach/mach.h>
#include <mach/mach_time.h>


@implementation TestSuite
@synthesize results;

- (void) dealloc {
	[results release];
	[super dealloc];
}

- (id) init {
	[super init];
	results = [NSMutableArray arrayWithCapacity:10];
	return self;
}

/* 
 Measures performance, see http://developer.apple.com/qa/qa2004/qa1398.html
*/
- (void) executeTest {
    uint64_t        start;
	static mach_timebase_info_data_t    stInfo;
	sqlite3 *normalDb;
	sqlite3 *encryptedDb;
	
	TestResult *result;
	
	mach_timebase_info(&stInfo); // initialize time base for timer calculations

	sqlite3_open([[TestSuite pathToDatabase:@"normal.db"] UTF8String], &normalDb);
	
	sqlite3_open([[TestSuite pathToDatabase:@"encrypted.db"] UTF8String], &encryptedDb);
	sqlite3_exec(encryptedDb, "PRAGMA key = 'my cool key';", NULL, NULL, NULL);
	
	[self startUp:normalDb];
	[self startUp:encryptedDb];
	
	/* testInserts */
	result = [[TestResult alloc] init];
	result.name = @"1000 inserts w/o transaction";
	start = mach_absolute_time();
	[self testInserts:normalDb];
	result.normalNs = (mach_absolute_time() - start) * stInfo.numer / stInfo.denom;
	
	start = mach_absolute_time();
	[self testInserts:encryptedDb];
	result.encryptedNs = (mach_absolute_time() - start) * stInfo.numer / stInfo.denom;
	
	[results addObject:result];
	[result release];
	
	/* testInsertsInTransaction */
	result = [[TestResult alloc] init];
	result.name = @"25000 inserts in transaction";
	start = mach_absolute_time();
	[self testInsertsInTransaction:normalDb];
	result.normalNs = (mach_absolute_time() - start) * stInfo.numer / stInfo.denom;
	

	start = mach_absolute_time();
	[self testInsertsInTransaction:encryptedDb];
	result.encryptedNs = (mach_absolute_time() - start) * stInfo.numer / stInfo.denom;
	
	[results addObject:result];
	[result release];
	
	[self tearDown:normalDb];
	[self tearDown:encryptedDb];
}

-(void) startUp:(sqlite3 *)db {
	sqlite3_exec(db, "CREATE TABLE t1(a INTEGER, b INTEGER, c VARCHAR(100));", NULL, NULL, NULL);
	sqlite3_exec(db, "CREATE TABLE t2(a INTEGER, b INTEGER, c VARCHAR(100));", NULL, NULL, NULL);
}

-(void) tearDown:(sqlite3 *)db {
	
	
}

-(void) testInserts:(sqlite3 *)db {
	for(int i = 0; i < 1000; i++) {
		int random = rand() * 100000;
		sqlite3_exec(db, [[NSString stringWithFormat:@"INSERT INTO t1 VALUES (%d, %d, '%d');", i, random, random] UTF8String], NULL, NULL, NULL);
	}
}


-(void) testInsertsInTransaction:(sqlite3 *)db {
	sqlite3_exec(db, "BEGIN;", NULL, NULL, NULL);
	for(int i = 0; i < 25000; i++) {
		int random = rand() * 500000;
		
		sqlite3_exec(db, [[NSString stringWithFormat:@"INSERT INTO t2 VALUES (%d, %d, '%d');", i, random, random] UTF8String], NULL, NULL, NULL);
	}
	sqlite3_exec(db, "COMMIT;", NULL, NULL, NULL);
}

+ (NSString *)pathToDatabase:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}


@end

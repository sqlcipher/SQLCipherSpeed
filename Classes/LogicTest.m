//
//  LogicTest.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 2/18/11.
//  Copyright 2011 Zetetic LLC. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <objc/runtime.h>
#include <sqlite3.h>

@interface LogicTest : SenTestCase {
	
}
- (void)testWorking;
- (void)testSQLCipher;

@end
@implementation LogicTest


- (void)testWorking
{
	NSString *test = @"test";
	NSString *test2 = nil;
	
	STAssertEqualObjects(test, test, @"objects should be equal");
	STAssertNil(test2, @"object should be nil");
}

- (void)testSQLCipher
{
	sqlite3 *db;
	int rc, rows;
	sqlite3_stmt *stmt;
	const char* key = "test123";
	const char* file = "sqlciphertest.db";

	NSFileManager *fm = [NSFileManager defaultManager] ;
	
	[fm removeItemAtPath:[NSString stringWithUTF8String:file] error:NULL];
	
	rc = sqlite3_open(file, &db);
	STAssertTrue(rc == SQLITE_OK, @"sqlite3_open reported error");
	STAssertTrue(db != NULL, @"sqlite3_open reported OK, but db is null");
	
	rc = sqlite3_key(db, key, strlen(key));
	STAssertTrue(rc == SQLITE_OK , @"error setting key");	
	
	rc = sqlite3_prepare_v2(db, "SELECT count(*) FROM sqlite_master;", -1, &stmt, NULL);
	STAssertTrue(rc == SQLITE_OK , @"error preparing query");	
		
	rc = sqlite3_step(stmt);
	STAssertTrue(rc == SQLITE_ROW , @"error querying");
		
	rows = sqlite3_column_int(stmt, 0);
	STAssertTrue(rows == 0 , @"bad count");
	
	sqlite3_finalize(stmt);
	
	rc = sqlite3_exec(db, "CREATE TABLE t1(a,b);", NULL, NULL, NULL);
	STAssertTrue(rc == SQLITE_OK , @"error creating table");
	
	rc = sqlite3_exec(db, "INSERT INTO t1(a,b) VALUES (1,2);", NULL, NULL, NULL);
	STAssertTrue(rc == SQLITE_OK , @"error inserting data");
	
	sqlite3_close(db);
	
	STAssertTrue([fm fileExistsAtPath:[NSString stringWithUTF8String:file]], @"database file missing");
	
	rc = sqlite3_open(file, &db);
	
	STAssertTrue(rc == SQLITE_OK, @"sqlite3_open reported error while reopening existing db");
	STAssertTrue(db != NULL, @"sqlite3_open reported OK, but db is null");
	
	rc = sqlite3_key(db, key, strlen(key));
	STAssertTrue(rc == SQLITE_OK , @"error setting key");	
	
	rc = sqlite3_prepare_v2(db, "SELECT count(*) FROM sqlite_master;", -1, &stmt, NULL);
	STAssertTrue(rc == SQLITE_OK , @"error preparing query");	
	
	rc = sqlite3_step(stmt);
	STAssertTrue(rc == SQLITE_ROW , @"error querying");
	
	rows = sqlite3_column_int(stmt, 0);
	STAssertTrue(rows == 1 , @"bad row count from sqlite_master");
	
	sqlite3_finalize(stmt);
	
	rc = sqlite3_prepare_v2(db, "SELECT count(*) FROM t1;", -1, &stmt, NULL);
	STAssertTrue(rc == SQLITE_OK , @"error preparing query");	
	
	rc = sqlite3_step(stmt);
	STAssertTrue(rc == SQLITE_ROW , @"error querying");
	
	rows = sqlite3_column_int(stmt, 0);
	STAssertTrue(rows == 1 , @"bad row count from sqlite_master");
	
	sqlite3_finalize(stmt);
	sqlite3_close(db);
	
	
}

@end

//
//  InsertNoTransactionTest.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "TestDefinitions.h"

@implementation CreateTableTest

-(void) setup {
	self.name = @"Create 2 tables";
	self.sql = @"CREATE TABLE t1...; CREATE TABLE t2...";
}

-(void) runTest:(sqlite3 *)db {
	if(db == encryptedDb) {
		sqlite3_exec(encryptedDb, "PRAGMA key = 'my cool key';", NULL, NULL, NULL);
		//sqlite3_exec(encryptedDb, "PRAGMA key = \"x'98483C6EB40B6C31A448C22A66DED3B5E5E8D5119CAC8327B655C8B5C4836481'\";", NULL, NULL, NULL);
	}
	sqlite3_exec(db, "CREATE TABLE t1(a INTEGER, b INTEGER, c VARCHAR(100));", NULL, NULL, NULL);
	sqlite3_exec(db, "CREATE TABLE t2(a INTEGER, b INTEGER, c VARCHAR(100));", NULL, NULL, NULL);
}

@end

@implementation InsertNoTransactionTest

-(void) setup {
		self.name = @"1000 inserts without transaction";
		self.sql = @"INSERT INTO t1 VALUES (?,?,?);";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
		for(int i = 0; i < 1000; i++) {
			int random = rand() * 100000;
			sqlite3_bind_int(stmt, 1, i);
			sqlite3_bind_int(stmt, 1, random);
			sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%d", random] UTF8String], -1, SQLITE_TRANSIENT);
			if(sqlite3_step(stmt) != SQLITE_DONE) {
				NSAssert1(0, @"Error inserting record'%s'", sqlite3_errmsg(db));
			}
			sqlite3_reset(stmt);
		}
	} else {
		NSAssert1(0, @"Error preparing statement '%s'", sqlite3_errmsg(db));
	}
	sqlite3_finalize(stmt);
}

@end

@implementation InsertWithTransactionTest

-(void) setup {
	self.name = @"25000 inserts with a transaction";
	self.sql = @"INSERT INTO t2 VALUES (?,?,?);";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, "BEGIN;", NULL, NULL, NULL);
	sqlite3_stmt *stmt;
	if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
		for(int i = 0; i < 25000; i++) {
			int random = rand() * 500000;
			sqlite3_bind_int(stmt, 1, i);
			sqlite3_bind_int(stmt, 1, random);
			sqlite3_bind_text(stmt, 2, [[NSString stringWithFormat:@"%d", random] UTF8String], -1, SQLITE_TRANSIENT);
			if(sqlite3_step(stmt) != SQLITE_DONE) {
				NSAssert1(0, @"Error inserting record'%s'", sqlite3_errmsg(db));
			}
			sqlite3_reset(stmt);
			sqlite3_clear_bindings(stmt); 
		}
	} else {
		NSAssert1(0, @"Error preparing statement '%s'", sqlite3_errmsg(db));
	}
	sqlite3_finalize(stmt);
	sqlite3_exec(db, "COMMIT;", NULL, NULL, NULL);
}

@end


@implementation DropTableTest

-(void) setup {
	self.name = @"Drop 2 tables";
	self.sql = @"DROP TABLE t1; DROP TABLE t2;";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, "DROP TABLE t1;", NULL, NULL, NULL);
	sqlite3_exec(db, "DROP TABLE t2", NULL, NULL, NULL);
}

@end
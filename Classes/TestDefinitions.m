//
//  InsertNoTransactionTest.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "TestDefinitions.h"

@implementation PragmaKeyTest

-(void) setup {
	self.name = @"Set Encryption Key";
	self.sql = @"PRAGMA key = 'xyz'; SELECT count(*) FROM sqlite_master;";
}

-(void) runTest:(sqlite3 *)db {
	if(db == encryptedDb) {
		sqlite3_exec(encryptedDb, "PRAGMA key = 'my cool key';", NULL, NULL, NULL);
		//sqlite3_exec(encryptedDb, "PRAGMA key = \"x'98483C6EB40B6C31A448C22A66DED3B5E5E8D5119CAC8327B655C8B5C4836481'\";", NULL, NULL, NULL);
	}
	sqlite3_exec(db, "SELECT count(*) FROM sqlite_master;", NULL, NULL, NULL);
}

@end

@implementation CreateTableTest

-(void) setup {
	self.name = @"Create 2 tables";
	self.sql = @"CREATE TABLE t1...; CREATE TABLE t2...";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, "CREATE TABLE t1(a INTEGER, b INTEGER, c VARCHAR(100));", NULL, NULL, NULL);
	sqlite3_exec(db, "CREATE TABLE t2(a INTEGER, b INTEGER, c VARCHAR(100));", NULL, NULL, NULL);
}

@end

@implementation InsertNoTransactionTest

-(void) setup {
	self.name = @"500 inserts without transaction";
	self.sql = @"INSERT INTO t1 VALUES (?,?,?);";
	self.iterations = 500;
}

-(void) bind:(NSInteger)i {
	int random = rand() * 100000;
	sqlite3_bind_int(stmt, 1, i);
	sqlite3_bind_int(stmt, 2, random);
	sqlite3_bind_text(stmt, 3, [[NSString stringWithFormat:@"%d", random] UTF8String], -1, SQLITE_TRANSIENT);
}

@end

@implementation InsertWithTransactionTest

-(void) setup {
	self.name = @"15000 inserts with a transaction";
	self.sql = @"INSERT INTO t2 VALUES (?,?,?);";
	self.iterations = 15000;
	self.useTransaction = YES;
}

-(void) bind:(NSInteger)i {
	int random = rand() * 100000;
	sqlite3_bind_int(stmt, 1, i);
	sqlite3_bind_int(stmt, 2, random);
	sqlite3_bind_text(stmt, 3, [[NSString stringWithFormat:@"%d", random] UTF8String], -1, SQLITE_TRANSIENT);
}

@end

@implementation SelectWithoutIndexTest

-(void) setup {
	self.name = @"50 SELECTs without an index";
	self.sql = @"SELECT count(*), avg(b) FROM t2 WHERE b >= ? AND b < ?;";
	self.iterations = 50;
}

-(void) bind:(NSInteger)i {
	int lwr = i * 50;
	int upr = (i + 10) * 50;
	
	sqlite3_bind_int(stmt, 1, lwr);
	sqlite3_bind_int(stmt, 2, upr);
}

@end

@implementation SelectOnStringCompareTest

-(void) setup {
	self.name = @"50 SELECTs on string comparison";
	self.sql = @"SELECT count(*), avg(b) FROM t2 WHERE c LIKE '%' || ? || '%'";
	self.iterations = 50;
}

-(void) bind:(NSInteger)i {
	sqlite3_bind_text(stmt, 1, [[NSString stringWithFormat:@"%d", i] UTF8String], -1, SQLITE_TRANSIENT);
}

@end

@implementation CreateIndexTest

-(void) setup {
	self.name = @"Create 2 indexes";
	self.sql = @"CREATE INDEX i2a ON t2(a); CREATE INDEX i2b ON t2(b);";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, "CREATE INDEX i2a ON t2(a);", NULL, NULL, NULL);
	sqlite3_exec(db, "CREATE INDEX i2b ON t2(b);", NULL, NULL, NULL);
}

@end

@implementation SelectWithIndexTest

-(void) setup {
	self.name = @"2500 SELECTs with an index";
	self.sql = @"SELECT count(*), avg(b) FROM t2 WHERE b >= ? AND b < ?;";
	self.iterations = 2500;
}

-(void) bind:(NSInteger)i {
	int lwr = i * 100;
	int upr = (i + 10) * 100;
	
	sqlite3_bind_int(stmt, 1, lwr);
	sqlite3_bind_int(stmt, 2, upr);
}

@end


@implementation UpdateWithoutIndexTest

-(void) setup {
	self.name = @"500 UPDATEs without an index";
	self.sql = @"UPDATE t1 SET b=b*2 WHERE a>= ? AND a < ?;";
	self.iterations = 500;
}

-(void) bind:(NSInteger)i {
	int lwr = i * 5;
	int upr = (i + 1) * 5;
	
	sqlite3_bind_int(stmt, 1, lwr);
	sqlite3_bind_int(stmt, 2, upr);
}

@end

@implementation UpdateWithIndexTest

-(void) setup {
	self.name = @"2500 UPDATEs without an index";
	self.sql = @"UPDATE t2 SET b = ? WHERE a = ?;";
	self.iterations = 2500;
	self.useTransaction = YES;
}

-(void) bind:(NSInteger)i {
	int random = rand() * 100000;
	
	sqlite3_bind_int(stmt, 1, random);
	sqlite3_bind_int(stmt, 2, i);
}

@end

@implementation InsertFromSelectTest

-(void) setup {
	self.name = @"INSERT from SELECT";
	self.sql = @"INSERT INTO t1 SELECT * FROM t2; INSERT INTO t2 SELECT * FROM t1;";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, "INSERT INTO t1 SELECT * FROM t2;", NULL, NULL, NULL);
	sqlite3_exec(db, "INSERT INTO t2 SELECT * FROM t1;", NULL, NULL, NULL);
}

@end

@implementation DeleteWithoutIndexTest

-(void) setup {
	self.name = @"DELETE without an index";
	self.sql = @"DELETE FROM t2 WHERE c LIKE '%50%';";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, [self.sql UTF8String], NULL, NULL, NULL);
}

@end

@implementation DeleteWithIndexTest

-(void) setup {
	self.name = @"DELETE with an index";
	self.sql = @"DELETE FROM t2 WHERE a>10 AND a<10000;";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, [self.sql UTF8String], NULL, NULL, NULL);
}

@end

@implementation BigInsertAfterDeleteTest

-(void) setup {
	self.name = @"Big INSERT after a big DELETE";
	self.sql = @"INSERT INTO t2 SELECT * FROM t1;";
}

-(void) runTest:(sqlite3 *)db {
	sqlite3_exec(db, [self.sql UTF8String], NULL, NULL, NULL);
}

@end

@implementation ManyInsertsAfterDeleteTest

-(void) setup {
	self.name = @"3000 inserts after a delete";
	self.sql = @"INSERT INTO t1 VALUES (?,?,?);";
	self.iterations = 3000;
	self.useTransaction = YES;
}

-(void) bind:(NSInteger)i {
	int random = rand() * 100000;
	sqlite3_bind_int(stmt, 1, i);
	sqlite3_bind_int(stmt, 2, random);
	sqlite3_bind_text(stmt, 3, [[NSString stringWithFormat:@"%d", random] UTF8String], -1, SQLITE_TRANSIENT);
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
//
//  InteratedSqlTest.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/31/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "IteratedSqlTest.h"


@implementation IteratedSqlTest
@synthesize iterations, useTransaction;

-(id) init {
	[super init];
	useTransaction = NO;
	return self;
}

-(void) runTest:(sqlite3 *)db {
	if(useTransaction) {
		sqlite3_exec(db, "BEGIN;", NULL, NULL, NULL);
	}
	
	if(sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
		for(int i = 0; i < iterations; i++) {
			[self bind:i];
			while(sqlite3_step(stmt) != SQLITE_DONE) { 
				//NSLog(@"step");
			}
			sqlite3_reset(stmt);
			sqlite3_clear_bindings(stmt); 
		}
	} else {
		NSAssert1(0, @"Error preparing statement '%s'", sqlite3_errmsg(db));
	}
	
	sqlite3_finalize(stmt);
	
	if(useTransaction) {
		sqlite3_exec(db, "COMMIT;", NULL, NULL, NULL);
	}
}

-(void) bind:(NSInteger) i {
	NSLog(@"placeholder to implement in subclass");
}

@end

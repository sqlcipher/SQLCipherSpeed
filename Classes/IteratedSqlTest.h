//
//  InteratedSqlTest.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/31/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlTest.h"

@interface IteratedSqlTest : SqlTest {
	sqlite3_stmt *stmt;
	int iterations;
	BOOL useTransaction;
}

@property (assign, nonatomic) NSInteger iterations;
@property (assign, nonatomic) BOOL useTransaction;

-(void) bind:(NSInteger)i;

@end

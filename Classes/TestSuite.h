//
//  TestSuite.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface TestSuite : NSObject {
	NSMutableArray *results;
}

@property (nonatomic,retain) NSMutableArray *results;

-(void)executeTest;
-(void) startUp:(sqlite3 *)db;
-(void) tearDown:(sqlite3 *)db;
-(void) testInserts:(sqlite3 *)db;
-(void) testInsertsInTransaction:(sqlite3 *)db;

+ (NSString *)pathToDatabase:(NSString *)fileName;

@end

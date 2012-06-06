//
//  SpeedTest.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import <openssl/hmac.h>

@interface SqlTest : NSObject <NSCoding, NSCopying> {
	sqlite3 *normalDb;
	sqlite3 *encryptedDb;
	NSString *name;
	NSString *sql;
	uint64_t normalNs;
	uint64_t encryptedNs;
    NSString *nick;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *sql;
@property (nonatomic) uint64_t normalNs;
@property (nonatomic) uint64_t encryptedNs;
@property (nonatomic,retain) NSString *nick;
@property (nonatomic) int sqliteResult;
@property (nonatomic) int sqlcipherResult;
@property (nonatomic,readonly) double sqlcipherImpact;

-(id) initWithDb:(sqlite3 *)normal encrypted:(sqlite3 *)encrypted;
-(void) setup;
-(void) runTests;
-(void) runTest:(sqlite3 *)db;
- (double)sqlcipherImpact;

@end

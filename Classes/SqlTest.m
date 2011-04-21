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

@synthesize name, sql, normalNs, encryptedNs, nick;

@dynamic sqlcipherImpact, sqlcipherResult, sqliteResult;

-(id) initWithDb:(sqlite3 *)normal encrypted:(sqlite3 *)encrypted {
	if ((self = [super init]))
    {
        normalDb = normal;
        encryptedDb = encrypted;
    }
	return self;
}

-(void) dealloc {
    [nick release];
	[name release];
	[sql release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    SqlTest *newObject = [[[self class] alloc] init];
    newObject.name = self.name;
    newObject.sql = self.sql;
    newObject.normalNs = self.normalNs;
    newObject.encryptedNs = self.encryptedNs;
    newObject.nick = self.nick;
    return newObject;
}

- (void)encodeWithCoder: (NSCoder *)coder
{
	[coder encodeObject:[self name] forKey:@"name"];
    [coder encodeObject:[self sql] forKey:@"sql"];
    [coder encodeObject:[self nick] forKey:@"nick"];
    [coder encodeInt64:[self normalNs] forKey:@"normalNs"];
    [coder encodeInt64:[self encryptedNs] forKey:@"encryptedNs"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init])) // extra parens silences warning about evaling and assignment
    {
        name = [[decoder decodeObjectForKey:@"name"] retain];
        sql = [[decoder decodeObjectForKey:@"sql"] retain];
        nick = [[decoder decodeObjectForKey:@"nick"] retain];
        normalNs = [decoder decodeInt64ForKey:@"normalNs"];
        encryptedNs = [decoder decodeInt64ForKey:@"encryptedNs"];
    }
    return self;
}

-(void) setup {
	NSLog(@"placeholder to implement in subclass");
}

- (NSString *)nick
{
    if (nick) return nick;
    return [[self class] description];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ impact: %.1f%% sqlite: %dms sqlcipher: %d ms", 
            [self nick], [self sqlcipherImpact], [self sqliteResult], [self sqlcipherResult]];
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

- (int)sqliteResult
{
    return self.normalNs / 1000000;
}

- (int)sqlcipherResult
{
    return self.encryptedNs / 1000000;
}

- (float)sqlcipherImpact
{
    int normalMs = self.sqliteResult; 
	int encryptedMs = self.sqlcipherResult;
    return ((float) (encryptedMs - normalMs) / (float) normalMs) * 100.0f;
}

@end

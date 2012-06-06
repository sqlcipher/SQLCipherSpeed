//
//  IterationTest.m
//  SQLCipherSpeed
//
//  Created by Nick Parker on 6/6/12.
//  Copyright (c) 2012 Zetetic LLC. All rights reserved.
//

#import "IteratedTest.h"

@implementation IteratedTest
@synthesize iterations;

-(id) init {
	[super init];
	return self;
}

-(void) bind:(NSInteger) i {
	NSLog(@"placeholder to implement in subclass");
}

-(void) runTest:(sqlite3 *)db {
 
    for(int i = 0; i < iterations; i++) {
        [self bind:i];
    }
}

@end

//
//  IterationTest.h
//  SQLCipherSpeed
//
//  Created by Nick Parker on 6/6/12.
//  Copyright (c) 2012 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlTest.h"

@interface IteratedTest : SqlTest {
    	NSInteger iterations;
}

@property (assign, nonatomic) NSInteger iterations;

-(void) bind:(NSInteger)i;

@end

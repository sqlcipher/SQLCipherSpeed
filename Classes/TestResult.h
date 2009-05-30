//
//  SpeedTest.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TestResult : NSObject {
	NSString *name;
	NSString *sql;
	uint64_t normalNs;
	uint64_t encryptedNs;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *sql;
@property (nonatomic) uint64_t normalNs;
@property (nonatomic) uint64_t encryptedNs;

@end

//
//  ProgressViewController.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "ProgressViewController.h"
#import "ResultViewController.h"
#import "TestDefinitions.h"
#import "sqlite3.h"

@implementation ProgressViewController
@synthesize testButton, progressView, tests;

- (void)dealloc {
	[testButton release];
	[progressView release];
	[tests release];
    [super dealloc];
}

- (IBAction) runTest:(id) sender {
	testButton.enabled = NO;
	CFRunLoopRunInMode (kCFRunLoopDefaultMode, 0, true);
	
	sqlite3 *normalDb;
	sqlite3 *encryptedDb;
	
	sqlite3_open([[ProgressViewController pathToDatabase:@"normal.db"] UTF8String], &normalDb);
	sqlite3_open([[ProgressViewController pathToDatabase:@"encrypted.db"] UTF8String], &encryptedDb);
	
	self.tests = [NSArray arrayWithObjects: 
				  [[[CreateTableTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[InsertNoTransactionTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[InsertWithTransactionTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[DropTableTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  nil
				  ];
	
	float count = (float) [tests count];
	
	for(int i = 0; i < count; i++) {
		TestResult *test = [tests objectAtIndex:i];
		[test runTests];
		[progressView setProgress:(float) (i + 1) / count];
		CFRunLoopRunInMode (kCFRunLoopDefaultMode, 0, true);
	}
	
	// close database files cleanly and remove the database itself
	sqlite3_close(normalDb);
	sqlite3_close(encryptedDb);
	
	[[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"normal.db"] error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"encrypted.db"] error:NULL];
	
	
	testButton.enabled = YES;
	ResultViewController *rvc = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:[NSBundle mainBundle]];
	rvc.results = tests;
	[self.navigationController pushViewController:rvc animated:YES];
	[rvc release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

+ (NSString *)pathToDatabase:(NSString *)fileName {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:fileName];
}


@end

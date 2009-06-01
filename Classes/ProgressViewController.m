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
@synthesize testButton, progressView, testNumberLabel, testNameLabel, tests;

- (void)dealloc {
	[testButton release];
	[progressView release];
	[testNumberLabel release];
	[testNameLabel release];
	[tests release];
    [super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (IBAction) runTest:(id) sender {
	
	testButton.enabled = NO;
	[testButton setTitle:@"Running" forState:UIControlStateDisabled];
	testNameLabel.hidden = NO;
	
	CFRunLoopRunInMode (kCFRunLoopDefaultMode, 0, true);
	
	sqlite3 *normalDb;
	sqlite3 *encryptedDb;
	
	[[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"normal.db"] error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"encrypted.db"] error:NULL];
	
	sqlite3_open([[ProgressViewController pathToDatabase:@"normal.db"] UTF8String], &normalDb);
	sqlite3_open([[ProgressViewController pathToDatabase:@"encrypted.db"] UTF8String], &encryptedDb);
	
	self.tests = [NSArray arrayWithObjects: 
				  [[[PragmaKeyTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[CreateTableTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[InsertNoTransactionTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[InsertWithTransactionTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[SelectWithoutIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[SelectOnStringCompareTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[CreateIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[SelectWithIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[UpdateWithoutIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[UpdateWithIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[InsertFromSelectTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[DeleteWithoutIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[DeleteWithIndexTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[BigInsertAfterDeleteTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[ManyInsertsAfterDeleteTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  [[[DropTableTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
				  nil
				  ];
	
	int count = [tests count];
	
	for(int i = 0; i < count; i++) {
		SqlTest *test = (SqlTest *) [tests objectAtIndex:i];
		[test runTests];
		[progressView setProgress:(float) (i + 1) / (float) count];
		testNumberLabel.text = [NSString stringWithFormat:@"Test %d of %d...", i+1, count];
		testNameLabel.text = test.name;
		CFRunLoopRunInMode (kCFRunLoopDefaultMode, 0, true);
	}
	
	// close database files cleanly and remove the database itself
	sqlite3_close(normalDb);
	sqlite3_close(encryptedDb);
	
	[[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"normal.db"] error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"encrypted.db"] error:NULL];
	
	
	testButton.enabled = YES;
	[testButton setTitle:@"Start" forState:UIControlStateNormal];
	testNameLabel.hidden = YES;
	testNumberLabel.text = @"Test Complete!";
	
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

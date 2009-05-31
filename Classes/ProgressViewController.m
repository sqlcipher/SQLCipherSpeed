//
//  ProgressViewController.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import "ProgressViewController.h"
#import "ResultViewController.h"
#import "TestSuite.h"
#import "TestResult.h"

@implementation ProgressViewController
@synthesize testButton, progressView;

- (void)dealloc {
	[testButton release];
	[progressView release];
    [super dealloc];
}

- (IBAction) runTest {
	TestSuite *suite = [[TestSuite alloc] init];
	[suite executeTest];

	ResultViewController *rvc = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:[NSBundle mainBundle]];
	rvc.results = suite.results;
	[suite release];
	[self.navigationController pushViewController:rvc animated:YES];
	[rvc release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}




@end

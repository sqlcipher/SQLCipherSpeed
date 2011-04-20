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

#define RESULTSET_KEY_DATE @"date"
#define RESULTSET_KEY_TESTS @"tests"
#define RESULTS_FILE_NAME @"results.plist"

#define SECTION_AVG 0
#define SECTION_PREV 1

@interface ProgressViewController (Private)
- (NSString *)_documentsDirectoryString;
- (void)_saveResults;
- (void)_showResultSet:(NSDictionary *)dict;
- (void)_updateUIStartedTest:(SqlTest *)test;
- (void)_updateUIStoppedTest:(SqlTest *)test;
- (void)_finishRun;
- (void)_generateAverages;
- (void)_finishGeneratingAverages;
@end

@implementation ProgressViewController

@synthesize testButton, progressView, testNumberLabel, tests;
@synthesize resultSets;
@synthesize tableView;
@synthesize averageResultSet;
@synthesize calculatingAverages;

- (void)dealloc {
    [averageResultSet release];
    [resultSets release];
	[testButton release];
	[progressView release];
	[testNumberLabel release];
	[tests release];
    [super dealloc];
}

- (NSString *)_documentsDirectoryString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)awakeFromNib
{
    resultSets = [[NSMutableArray alloc] init];
    calculatingAverages = NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    NSString *resultsFilePath = [[self _documentsDirectoryString] stringByAppendingPathComponent: RESULTS_FILE_NAME];
    NSLog(@"looking for results file at %@...", resultsFilePath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:resultsFilePath])
    {
        NSLog(@"found results file, slurping it in...");
        NSArray *fileResults = [NSKeyedUnarchiver unarchiveObjectWithFile:resultsFilePath];
        if (fileResults) 
        {
            NSLog(@"sorting the results");
            NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:RESULTSET_KEY_DATE ascending:NO];
            self.resultSets = [[fileResults sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByDate]] mutableCopy];
            [sortByDate release];
        }
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Tests" style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)runTest:(id) sender {
	
	testButton.enabled = NO;
	[testButton setTitle:@"Running" forState:UIControlStateDisabled];
    
    // perform tests on a dispatch queue to avoid blocking main thread
	dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(defaultQueue, ^{
        
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
            [self performSelectorOnMainThread:@selector(_updateUIStartedTest:) withObject:test waitUntilDone:NO];
            [test runTests];
            [self performSelectorOnMainThread:@selector(_updateUIStoppedTest:) withObject:test waitUntilDone:NO];
        }
        
        // close database files cleanly and remove the database itself
        sqlite3_close(normalDb);
        sqlite3_close(encryptedDb);
        
        [[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"normal.db"] error:NULL];
        [[NSFileManager defaultManager] removeItemAtPath:[ProgressViewController pathToDatabase:@"encrypted.db"] error:NULL];
        
        // store the result set for later by adding it to our list...
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tests, RESULTSET_KEY_TESTS, 
                              [NSDate date], RESULTSET_KEY_DATE, nil];
        
        // insert at top of the list
        [resultSets insertObject:dict atIndex:0];
        
        // save to file
        [self _saveResults];
        
		[self performSelectorOnMainThread:@selector(_finishRun) withObject:nil waitUntilDone:NO];
	});
}

- (void)_finishRun
{
    NSDictionary *dict = [resultSets objectAtIndex:0];
    
    // update tableView to match results array
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    
    testButton.enabled = YES;
    [testButton setTitle:@"Start" forState:UIControlStateNormal];
    testNumberLabel.text = @"Test Complete!";
    
    if ([resultSets count] < 3)
    {
        [self _showResultSet:dict];
    }
    
    [self _generateAverages];
}

- (void)_generateAverages
{
    calculatingAverages = YES;
    //[tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_AVG] withRowAnimation:YES];
    
    // perform tests on a dispatch queue to avoid blocking main thread
	dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(defaultQueue, ^{
        sleep(5);
        [self performSelectorOnMainThread:@selector(_finishGeneratingAverages) withObject:nil waitUntilDone:NO];
    });
}

- (void)_finishGeneratingAverages
{
    calculatingAverages = NO;
    //[tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_AVG] withRowAnimation:YES];
}

- (void)_updateUIStartedTest:(SqlTest *)test
{
    NSUInteger i = [tests indexOfObject:test];
    testNumberLabel.text = [NSString stringWithFormat:@"Test %d of %d...", i, [tests count]];
}

- (void)_updateUIStoppedTest:(SqlTest *)test
{
    NSUInteger i = [tests indexOfObject:test];
    [progressView setProgress:(float) (i + 1) / (float) [tests count]];
}

- (void)_saveResults
{
    NSString *resultsFilePath = [[self _documentsDirectoryString] stringByAppendingPathComponent: RESULTS_FILE_NAME];
    
    NSLog(@"data to archive: %@", resultSets);
    BOOL result = [NSKeyedArchiver archiveRootObject:resultSets
                                              toFile:resultsFilePath];
    if (!result)
        NSLog(@"%s: Failed to archive data to %@", __func__, resultsFilePath);
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

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SECTION_PREV)
        return @"Previous Runs";
    
    return nil;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (section == SECTION_AVG)
        return 1;

    return [resultSets count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"fetching cellForRow %d", indexPath.row);
    
    static NSString *CellIdentifier = @"ResultSetCell";
    
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == SECTION_PREV)
    {
        NSDictionary *resultSet = (NSDictionary *)[resultSets objectAtIndex:indexPath.row];
        NSDate *date = [resultSet objectForKey:RESULTSET_KEY_DATE];
        cell.textLabel.text = [NSDate stringForDisplayFromDate:date];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.textLabel.text = @"Averaged Results";
        if (calculatingAverages)
        {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            cell.accessoryView = spinner;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    return cell;
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_PREV)
    {
        NSDictionary *dict = (NSDictionary *)[resultSets objectAtIndex:indexPath.row];
        [self _showResultSet:dict];
    }
    else
    {
        
    }
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)_showResultSet:(NSDictionary *)dict
{
    ResultViewController *rvc = [[ResultViewController alloc] initWithNibName:@"ResultViewController" bundle:[NSBundle mainBundle]];
    rvc.displayingAverages = NO;
	rvc.results = [dict objectForKey:RESULTSET_KEY_TESTS];
    rvc.testDate = [dict objectForKey:RESULTSET_KEY_DATE];
	[self.navigationController pushViewController:rvc animated:YES];
	[rvc release];
}

@end

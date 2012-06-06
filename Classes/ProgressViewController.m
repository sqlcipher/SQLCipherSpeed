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
#define RESULTSET_KEY_PAGESZ @"pagesz"
#define RESULTS_FILE_NAME @"results.plist"

#define SECTION_AVG 0
#define SECTION_PREV 1

@interface ProgressViewController (Private)
- (NSString *)_documentsDirectoryString;
- (void)_saveResults;
- (void)_showResultSet:(NSDictionary *)dict;
- (void)_updateUIStartedTest:(SqlTest *)test;
- (void)_updateUIStoppedTest:(SqlTest *)test;
- (void)_finishRun:(NSDictionary *)dict;
- (void)_generateAverages;
- (void)_finishGeneratingAverages;
@end

@implementation ProgressViewController

@synthesize testButton, progressView, testNumberLabel, tests;
@synthesize resultSets;
@synthesize tableView;
@synthesize averageResultSet;
@synthesize calculatingAverages;
@synthesize headerView;
@synthesize pageSizeField;

- (void)dealloc {
    [pageSizeField release];
    [headerView release];
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
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:resultsFilePath])
    {
        NSArray *fileResults = [NSKeyedUnarchiver unarchiveObjectWithFile:resultsFilePath];
        if (fileResults) 
        {
            NSSortDescriptor *sortByDate = [[NSSortDescriptor alloc] initWithKey:RESULTSET_KEY_DATE ascending:NO];
            self.resultSets = [[fileResults sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByDate]] mutableCopy];
            [sortByDate release];
        }
    }
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Tests" 
                                                                   style:UIBarButtonItemStyleBordered 
                                                                  target:nil 
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    // put an edit button on the right
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    // reset button on the left
    UIBarButtonItem *lbi = [[UIBarButtonItem alloc] initWithTitle:@"Reset" 
                                                            style:UIBarButtonItemStyleBordered 
                                                           target:self 
                                                           action:@selector(reset:)];
    self.navigationItem.leftBarButtonItem = lbi;
    [lbi release];
    // setup the table header view
    self.headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [tableView setEditing:editing animated:YES];
    if (editing) {
        self.navigationItem.leftBarButtonItem.enabled = NO;
        testButton.enabled = NO;
    } else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
        testButton.enabled = YES;
    }
}

- (IBAction)reset:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Confirm Reset" 
						  message:@"All result sets will be deleted, are you certain you want to reset SQLCipher Speed?" 
						  delegate:self 
						  cancelButtonTitle:@"Cancel" 
						  otherButtonTitles:@"Reset", nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // ditch the results we've got
        self.resultSets = [NSMutableArray array];
        [self _saveResults];
        [self.tableView reloadData];
        // reset the pageSize field so that it's nil
        self.pageSizeField.text = nil;
    }
}

- (IBAction)runTest:(id) sender {
    // make sure we dismiss this guy, first
    [pageSizeField resignFirstResponder];
	
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
        PragmaKeyTest *keyTest = [[[PragmaKeyTest alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease];
        NSString *str = [pageSizeField text];
        if (str)
        {
            // intValue returns zero if the user enters non-numeric text
            [keyTest setPageSize:[str intValue]];
        }        
        self.tests = [NSArray arrayWithObjects: 
                      keyTest,
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
                      [[[PBKDF2Test alloc] initWithDb:normalDb encrypted:encryptedDb] autorelease],
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
        // be clever about storing the page size (argh)
        NSNumber *pgSizeNumber = [NSNumber numberWithInt:[str intValue]];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:tests, RESULTSET_KEY_TESTS,
                              pgSizeNumber, RESULTSET_KEY_PAGESZ,
                              [NSDate date], RESULTSET_KEY_DATE, nil];
        
		[self performSelectorOnMainThread:@selector(_finishRun:) withObject:dict waitUntilDone:NO];
	});
}

- (void)_finishRun:(NSDictionary *)dict
{
    // insert at top of the list
    [resultSets insertObject:dict atIndex:0];
    
    // save to file
    [self _saveResults];
    
    // update tableView to match results array
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:SECTION_PREV];
    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    
    testButton.enabled = YES;
    [testButton setTitle:@"Start" forState:UIControlStateNormal];
    testNumberLabel.text = @"Test Complete!";
    
    // if there's only one result set, just push it into view...
    if ([resultSets count] == 1)
    {
        [self _showResultSet:dict];
    }
    
    [self _generateAverages];
}

- (void)_generateAverages
{
    calculatingAverages = YES;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_AVG] withRowAnimation:NO];
    
    // perform tests on a dispatch queue to avoid blocking main thread
	dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	dispatch_async(defaultQueue, ^{
        
        NSUInteger  count = [tests count];
        uint64_t    sqliteTimes [count];
        uint64_t    sqlcipherTimes [count];
        // initialize them so we're adding from zero and not garbage
        for (int i=0; i<count; i++)
        {
            sqliteTimes[i]      = 0;
            sqlcipherTimes[i]   = 0;
        }
        for (NSDictionary *dict in self.resultSets)
        {
            for (int i = 0; i < count; i++)
            {
                NSArray *results    = (NSArray *)[dict objectForKey:RESULTSET_KEY_TESTS];
                SqlTest *t          = [results objectAtIndex:i];
                sqliteTimes[i]      = sqliteTimes[i] + t.normalNs;
                sqlcipherTimes[i]   = sqlcipherTimes[i] + t.encryptedNs;
            }
        }
        
        NSMutableArray *averages = [NSMutableArray arrayWithCapacity:count];
        for (int j = 0; j < count; j++)
        {
            SqlTest *t       = [[tests objectAtIndex:j] copy];
            t.normalNs       = floorl(sqliteTimes[j] / count);
            t.encryptedNs    = floorl(sqlcipherTimes[j] / count);
            [averages addObject:t];
            [t release];
        }
        
        self.averageResultSet = [NSDictionary dictionaryWithObjectsAndKeys:averages, RESULTSET_KEY_TESTS,
                                 [NSDate date], RESULTSET_KEY_DATE, nil];

        [self performSelectorOnMainThread:@selector(_finishGeneratingAverages) withObject:nil waitUntilDone:NO];
    });
}

- (void)_finishGeneratingAverages
{
    calculatingAverages = NO;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:SECTION_AVG] withRowAnimation:NO];
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
    
    BOOL result = [NSKeyedArchiver archiveRootObject:resultSets
                                              toFile:resultsFilePath];
    if (!result)
        NSLog(@"%s: Failed to archive data to %@", __func__, resultsFilePath);
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
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

    static NSString *CellIdentifier = @"ResultSetCell";
    
	UITableViewCell *cell = (UITableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == SECTION_PREV)
    {
        NSDictionary *resultSet = (NSDictionary *)[resultSets objectAtIndex:indexPath.row];
        NSDate *date = (NSDate *)[resultSet objectForKey:RESULTSET_KEY_DATE];
        cell.textLabel.text = [NSDate stringForDisplayFromDate:date prefixed:NO alwaysDisplayTime:YES];
        NSNumber *pageSizeNumber = (NSNumber *)[resultSet objectForKey:RESULTSET_KEY_PAGESZ];
        if ([pageSizeNumber intValue] == 0)
            cell.detailTextLabel.text = nil;
        else
            cell.detailTextLabel.text = [NSString stringWithFormat:@"page size: %d", [pageSizeNumber intValue]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }
    else
    {
        cell.detailTextLabel.text = nil;
        if (calculatingAverages)
        {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinner startAnimating];
            cell.accessoryView = spinner;
            cell.textLabel.text = @"Recalculating";
        }
        else {
            cell.accessoryView = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Averaged Results";
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
        if (!calculatingAverages)
            [self _showResultSet:averageResultSet];
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_AVG)
        return UITableViewCellEditingStyleNone;
    else // only makes sense to allow delete of stored data...
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [resultSets removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self _saveResults];
    }
}

@end

//
//  ResultViewController.m
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright Zetetic LLC 2009. All rights reserved.
//

#import "ResultViewController.h"
#import "SqlTest.h"

@implementation ResultViewController
@synthesize results, resultCell;

- (void)dealloc {
	[results release];
	[resultCell release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TestResultCell";
    
	resultCell = (TestResultCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (resultCell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"TestResultCell" owner:self options:nil];
    }
    
	SqlTest *result = (SqlTest *) [results objectAtIndex:indexPath.row];
    resultCell.nameLabel.text = result.name;
	resultCell.sqlLabel.text = result.sql;
	
	int normalMs = result.normalNs / 1000000; // convert to millisconds
	int encryptedMs = result.encryptedNs / 1000000;
	resultCell.normalTimeLabel.text = [NSString stringWithFormat:@"%d ms",  normalMs];
	resultCell.encryptedTimeLabel.text = [NSString stringWithFormat:@"%d ms", encryptedMs];
	resultCell.slowDownLabel.text = [NSString stringWithFormat:@"%.1f%%", ((double) (encryptedMs - normalMs) / (double) normalMs) * 100.0];

    return resultCell;
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}



@end


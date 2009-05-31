//
//  ResultViewController.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright Zetetic LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestResultCell.h"

@interface ResultViewController : UITableViewController {
	NSArray *results;
	IBOutlet TestResultCell *resultCell;
}

@property(nonatomic,retain) NSArray *results;
@property(nonatomic,retain) IBOutlet TestResultCell *resultCell;
@end

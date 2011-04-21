//
//  ProgressViewController.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
	IBOutlet UIButton *testButton;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *testNumberLabel;
    IBOutlet UITableView *tableView;
    IBOutlet UIView *headerView;
    IBOutlet UITextField *pageSizeField;
	NSArray *tests;
    NSMutableArray *resultSets;
    NSDictionary *averageResultSet;
    BOOL calculatingAverages;
}

@property(nonatomic,retain) IBOutlet UIButton *testButton;
@property(nonatomic,retain) IBOutlet UIProgressView *progressView;
@property(nonatomic,retain) IBOutlet UILabel *testNumberLabel;
@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UIView *headerView;
@property(nonatomic,retain) IBOutlet UITextField *pageSizeField;
@property(nonatomic,retain) NSArray *tests;
@property(nonatomic,retain) NSMutableArray *resultSets;
@property(nonatomic,retain) NSDictionary *averageResultSet;
@property(nonatomic) BOOL calculatingAverages;

- (IBAction)reset:(id)sender;
- (IBAction)runTest:(id)sender;

+ (NSString *)pathToDatabase:(NSString *)fileName;

@end

//
//  ProgressViewController.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressViewController : UIViewController {
	IBOutlet UIButton *testButton;
	IBOutlet UIProgressView *progressView;
	IBOutlet UILabel *testNumberLabel;
	IBOutlet UILabel *testNameLabel;
	NSArray *tests;
}

@property(nonatomic,retain) IBOutlet UIButton *testButton;
@property(nonatomic,retain) IBOutlet UIProgressView *progressView;
@property(nonatomic,retain) IBOutlet UILabel *testNumberLabel;
@property(nonatomic,retain) IBOutlet UILabel *testNameLabel;
@property(nonatomic,retain) NSArray *tests;

- (IBAction) runTest:(id)sender;

+ (NSString *)pathToDatabase:(NSString *)fileName;

@end

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
}

@property(nonatomic,retain) IBOutlet UIButton *testButton;
@property(nonatomic,retain) IBOutlet UIProgressView *progressView;

- (IBAction) runTest;

@end

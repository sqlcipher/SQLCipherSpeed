//
//  TestResultCell.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TestResultCell : UITableViewCell {
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *sqlLabel;
	IBOutlet UILabel *slowDownLabel;
	IBOutlet UILabel *normalTimeLabel;
	IBOutlet UILabel *encryptedTimeLabel;
}

@property (nonatomic,retain) IBOutlet UILabel *nameLabel;
@property (nonatomic,retain) IBOutlet UILabel *sqlLabel;
@property (nonatomic,retain) IBOutlet UILabel *slowDownLabel;
@property (nonatomic,retain) IBOutlet UILabel *normalTimeLabel;
@property (nonatomic,retain) IBOutlet UILabel *encryptedTimeLabel;
@end

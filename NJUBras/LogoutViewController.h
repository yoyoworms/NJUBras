//
//  LogoutViewController.h
//  NJUBras
//
//  Created by Xin Liu on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogoutViewController : UIViewController
- (IBAction)logout:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *user;
@property (strong, nonatomic) IBOutlet UILabel *time;

@end

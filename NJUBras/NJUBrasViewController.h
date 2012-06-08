//
//  NJUBrasViewController.h
//  NJUBras
//
//  Created by Xin Liu on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoutViewController.h"

@interface NJUBrasViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong ,nonatomic) LogoutViewController *logoutViewController; 
- (IBAction)login:(id)sender;

@end

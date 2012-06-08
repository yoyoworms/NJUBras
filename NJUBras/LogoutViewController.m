//
//  LogoutViewController.m
//  NJUBras
//
//  Created by Xin Liu on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LogoutViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

@interface LogoutViewController () {
    MBProgressHUD *logoutHUD;
}
@end

@implementation LogoutViewController
@synthesize user = _user;
@synthesize time = _time;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                                selector: @selector(notificationHandle:)
                                                 name: @"LogoutControllor"
                                               object: nil];
    
    [self notificationHandle: nil];
}

- (void)viewDidUnload
{
    [self setUser:nil];
    [self setTime:nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) notificationHandle: (NSNotification*) sender
{
    NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal/"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:15];
    
    request.tag = 0;
    
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (logoutHUD) {
        [logoutHUD removeFromSuperview];  
        logoutHUD = nil;
    }
    
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%@", responseString);
    
    if (request.tag == 0) {
        NSRange range = [responseString rangeOfString:@"在线时长"];
        
        if (range.length > 0) {
            range = [responseString rangeOfString:@"value = \'"];
            NSString *tmp = [responseString substringWithRange: NSMakeRange(range.location + 9, 30)];
            NSRange tmpRange = [tmp rangeOfString:@"\' readonly"];
            _time.text = [tmp substringToIndex:tmpRange.location];
            
            
            range = [responseString rangeOfString:@"IP地址"];
            tmp = [responseString substringWithRange: NSMakeRange(range.location + 58, 20)];
            tmpRange = [tmp rangeOfString:@"</td>"];
            _user.text = [tmp substringToIndex:tmpRange.location];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"连接丢失" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    }
    else if (request.tag == 1) {
        [self.view removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.view removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver: self];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (logoutHUD) {
        [logoutHUD removeFromSuperview];  
        logoutHUD = nil;
    }
    
    NSError *error = [request error];
    NSLog(@"%@", error);
    
    [[[UIAlertView alloc] initWithTitle:@"连接丢失" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)logout:(id)sender {
    // show HUD
    logoutHUD = [[MBProgressHUD alloc] initWithView:self.view];  
    [self.view addSubview: logoutHUD];  
    [self.view bringSubviewToFront: logoutHUD];  
    //[loginHUD setDelegate:self]; 
    logoutHUD.labelText = @"Log out";  
    [logoutHUD show:YES];
    
    // post to p.nju
    NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal/index.html"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    
    [request addRequestHeader:@"Host" value:@"p.nju.edu.cn"];
    [request addRequestHeader:@"Connection" value:@"keep-alive"];
    [request addRequestHeader:@"Cache-Control" value:@"max-age=0"];
    [request addRequestHeader:@"Origin" value:@"http://p.nju.edu.cn"];
    [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5"];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [request addRequestHeader:@"Referer" value:@"http://p.nju.edu.cn/portal/"];
    [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
    [request addRequestHeader:@"Accept-Language" value:@"zh-CN,zh;q=0.8"];
    [request addRequestHeader:@"Accept-Charset" value:@"GBK,utf-8;q=0.7,*;q=0.3"];
    
    [request setPostValue:@"disconnect" forKey:@"action"];
    
    [request setTimeOutSeconds:10];
    request.tag = 1;
    
    [request setDelegate:self];
    [request startAsynchronous];
    
}
@end

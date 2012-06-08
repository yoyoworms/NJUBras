//
//  NJUBrasViewController.m
//  NJUBras
//
//  Created by Xin Liu on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NJUBrasViewController.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface NJUBrasViewController (){
    MBProgressHUD *loginHUD;
    NSString *cookie;
}

- (void)getCookie;
- (void)loginBras;
- (void)openKickBras;
- (void)kickBras;

@end

@implementation NJUBrasViewController
@synthesize username = _username;
@synthesize password = _password;
@synthesize logoutViewController = _logoutViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _username.delegate = self;
    _password.delegate = self;
    
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    NSString *username = [store objectForKey:@"username"];
    NSString *password = [store objectForKey:@"password"];
    
    if(username && password) {
        _username.text = username;
        _password.text = password;
    }

}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setPassword:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)keyboardWillShow:(NSNotification *)noti
{        
    //键盘输入的界面调整        
    //键盘的高度
    float height = 306.0;                
    CGRect frame = self.view.frame;        
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height); 
    NSLog(@"%@", frame.size);
    [UIView beginAnimations:@"Curl"context:nil];//动画开始          
    [UIView setAnimationDuration:0.30];           
    [UIView setAnimationDelegate:self];
    [self.view setFrame:frame];         
    [UIView commitAnimations];         
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{        
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.        
    NSTimeInterval animationDuration = 0.30f;        
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];        
    [UIView setAnimationDuration:animationDuration];        
    CGRect rect = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height);        
    self.view.frame = rect;        
    [UIView commitAnimations];
    
    if (textField == _username) {
        [_password becomeFirstResponder];
    }
    else if (textField == _password) {
        [_password resignFirstResponder];
        [self login:nil];
    }
    return YES;        
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{        
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 306.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;                
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];                
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;                
    float height = self.view.frame.size.height;        
    if(offset > 0)
    {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);                
        self.view.frame = rect;        
    }        
    [UIView commitAnimations];                
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    NSTimeInterval animationDuration = 0.30f;        
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];        
    [UIView setAnimationDuration:animationDuration];        
    CGRect rect = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height);        
    self.view.frame = rect;        
    [UIView commitAnimations];        
    [_username resignFirstResponder];
    [_password resignFirstResponder];
}



- (IBAction)login:(id)sender
{
    // check input
    if (_username.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"请输入用户名" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    
    else if (_password.text.length == 0) {
        [[[UIAlertView alloc] initWithTitle:@"请输入密码" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    
    // save username and password
    NSUserDefaults *store = [NSUserDefaults standardUserDefaults];
    [store setValue: _username.text forKey: @"username"];
    [store setValue: _password.text forKey: @"password"];
    [store synchronize];
    
    
    // fold keyboard
    [_username resignFirstResponder];
    [_password resignFirstResponder];
    NSTimeInterval animationDuration = 0.30f;        
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];        
    [UIView setAnimationDuration:animationDuration];        
    CGRect rect = CGRectMake(0.0f, 20.0f, self.view.frame.size.width, self.view.frame.size.height);        
    self.view.frame = rect;        
    [UIView commitAnimations];
    
    
    // show HUD
    loginHUD = [[MBProgressHUD alloc] initWithView:self.view];  
    [self.view addSubview: loginHUD];  
    [self.view bringSubviewToFront: loginHUD];  
    //[loginHUD setDelegate:self]; 
    loginHUD.labelText = @"Log in";  
    [loginHUD show:YES];
    
    // post to p.nju
    NSURL *url = [NSURL URLWithString:@"http://p.nju.edu.cn/portal/"];
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
    
    [request setPostValue:@"login" forKey:@"action"];
    [request setPostValue:@"http://p.nju.edu.cn" forKey:@"url"];
    [request setPostValue: _username.text forKey:@"login_username"];
    [request setPostValue: _password.text forKey:@"login_password"];
    
    [request setTimeOutSeconds:10];
    request.tag = 0;
    
    [request setDelegate:self];
    [request startAsynchronous];
    
    
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    
    NSString *responseString = [request responseString];
    
    NSLog(@"%@", responseString);
    
    if (request.tag == 0 ) {
        if (loginHUD) {  
            [loginHUD removeFromSuperview];  
            loginHUD = nil;  
        }
        
        // find response
        NSRange range = [responseString rangeOfString:@"在线时长"];
        
        if (range.length > 0) {
            // login success
            // get username, time
            
            _logoutViewController = [[LogoutViewController alloc]initWithNibName:@"LogoutViewController" bundle:nil];  
            [self.view addSubview: _logoutViewController.view];
        }
        else {
            //您已经登录
            range = [responseString rangeOfString:@"您已经登录"];
            if (range.length > 0) {
                _logoutViewController = [[LogoutViewController alloc]initWithNibName:@"LogoutViewController" bundle:nil];  
                [self.view addSubview: _logoutViewController.view];
                return;
            }
            
            
            //if to get new IP
            range = [responseString rangeOfString:@"请重新获取IP地址"];
            if (range.length > 0) {
                [[[UIAlertView alloc] initWithTitle:@"请重新获取IP地址" message:@"换一个AP试试？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
            
            //if too many device
            range = [responseString rangeOfString:@"在线用户数量限制"];
            if (range.length > 0) {
                UIAlertView *kickBrasAlertView = [[UIAlertView alloc] initWithTitle:@"Bras已在别处登录，是否强制下线？" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
                kickBrasAlertView.tag = 1;
                [kickBrasAlertView show];
                return;
            }
            
            //if wrong username
            range = [responseString rangeOfString:@"用户不存在"];
            if (range.length > 0) {
                [[[UIAlertView alloc] initWithTitle:@"用户不存在" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                return;
            }
            
            // if wrong password
            range = [responseString rangeOfString:@"密码错误"];
            if (range.length > 0) {
                [[[UIAlertView alloc] initWithTitle:@"密码错误" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                return;
            }
            
            //未发现此用户
            [[[UIAlertView alloc] initWithTitle:@"未知错误，请重试" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
    }
    else if (request.tag == 1) {
        cookie = [[request responseHeaders] objectForKey:@"Set-Cookie"];
        NSLog(@"Get cookie, %@", cookie);
        
        [self loginBras];
    }
    else if (request.tag == 2) {
        [self openKickBras];
    }
    else if (request.tag == 3) {
        [self kickBras];
    }
    else if (request.tag == 4) {
        if (loginHUD) {  
            [loginHUD removeFromSuperview];  
            loginHUD = nil;  
        }
        //用户不在线
        NSRange range = [responseString rangeOfString:@"用户不在线"];
        
        if (range.length > 0) {
            // kick success            
            [[[UIAlertView alloc] initWithTitle:@"Bras强制下线成功" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }

        
    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1) {
        if (buttonIndex == 0) {
            loginHUD = [[MBProgressHUD alloc] initWithView:self.view];  
            [self.view addSubview: loginHUD];  
            [self.view bringSubviewToFront: loginHUD];  
            //[loginHUD setDelegate:self]; 
            loginHUD.labelText = @"Kick bras";  
            [loginHUD show:YES];
            
            [self getCookie];
            
            NSLog(@"get cookie");
        }
    }
}



- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (loginHUD) {  
        [loginHUD removeFromSuperview];  
        loginHUD = nil;  
    }
    
    NSError *error = [request error];
    NSLog(@"%@", error);
    
    if (request.tag == 0) {
        [[[UIAlertView alloc] initWithTitle:@"连接超时" message:@"你是否接入了校园网？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Bras强制下线失败，请稍后再试" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}


- (void)getCookie
{
    //open the login page once, get the session id
    NSURL *cookieUrl = [NSURL URLWithString:@"http://bras.nju.edu.cn/selfservice/login.jsf"];
    ASIHTTPRequest *cookieRequest = [ASIHTTPRequest requestWithURL:cookieUrl];
    
    [cookieRequest addRequestHeader:@"Host" value:@"bras.nju.edu.cn"];
    [cookieRequest addRequestHeader:@"Connection" value:@"keep-alive"];
    [cookieRequest addRequestHeader:@"Cache-Control" value:@"max-age=0"];
    [cookieRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5"];
    [cookieRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [cookieRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [cookieRequest addRequestHeader:@"Referer" value:@"http://bras.nju.edu.cn/selfservice/login.jsf"];
    [cookieRequest addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
    [cookieRequest addRequestHeader:@"Accept-Language" value:@"zh-CN,zh;q=0.8"];
    
    [cookieRequest setTimeOutSeconds:5];
    
    cookieRequest.tag = 1;
    [cookieRequest setDelegate:self];
    [cookieRequest startAsynchronous];
}


- (void)loginBras
{
    //post the data and login    
    NSURL *loginUrl = [NSURL URLWithString:@"http://bras.nju.edu.cn/selfservice/login.jsf"];
    ASIFormDataRequest *loginRequest = [ASIFormDataRequest requestWithURL:loginUrl];
    
    
    [loginRequest addRequestHeader:@"Host" value:@"bras.nju.edu.cn"];
    [loginRequest addRequestHeader:@"Connection" value:@"keep-alive"];
    [loginRequest addRequestHeader:@"Cache-Control" value:@"max-age=0"];
    [loginRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5"];
    [loginRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [loginRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [loginRequest addRequestHeader:@"Referer" value:@"http://bras.nju.edu.cn/selfservice/login.jsf"];
    [loginRequest addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
    [loginRequest addRequestHeader:@"Accept-Language" value:@"zh-CN,zh;q=0.8"];
    [loginRequest addRequestHeader:@"Cookie" value:cookie];
    
    [loginRequest setPostValue:_username.text forKey:@"cmdForm:username"];
    [loginRequest setPostValue:_password.text forKey:@"cmdForm:password"];
    [loginRequest setPostValue:@"登录" forKey:@"cmdForm:_idJsp21"];
    [loginRequest setPostValue:@"1" forKey:@"cmdForm_SUBMIT"];
    [loginRequest setPostValue:@"1" forKey:@"cmdForm:usertype"];
    
    [loginRequest setTimeOutSeconds:5];
    
    loginRequest.tag = 2;
    [loginRequest setDelegate:self];
    [loginRequest startAsynchronous];
}
    
- (void)openKickBras
{
    NSURL *logoutUrl = [NSURL URLWithString:@"http://bras.nju.edu.cn/selfservice/maintain/offline.jsf"];
    ASIHTTPRequest *logoutRequest = [ASIHTTPRequest requestWithURL:logoutUrl];
    [logoutRequest addRequestHeader:@"Host" value:@"bras.nju.edu.cn"];
    [logoutRequest addRequestHeader:@"Origin" value:@"http://bras.nju.edu.cn"];
    [logoutRequest addRequestHeader:@"Connection" value:@"keep-alive"];
    [logoutRequest addRequestHeader:@"Cache-Control" value:@"max-age=0"];
    [logoutRequest addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5"];
    [logoutRequest addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [logoutRequest addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [logoutRequest addRequestHeader:@"Referer" value:@"http://bras.nju.edu.cn/selfservice/maintain/offline.jsf"];
    [logoutRequest addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
    [logoutRequest addRequestHeader:@"Accept-Language" value:@"zh-CN,zh;q=0.8"];
    [logoutRequest addRequestHeader:@"Accept-Charset" value:@"GBK,utf-8;q=0.7,*;q=0.3"];
    [logoutRequest addRequestHeader:@"Content-Length" value:@"95"];
    [logoutRequest addRequestHeader:@"Cookie" value:cookie];
    
    [logoutRequest setTimeOutSeconds:5];
    
    logoutRequest.tag = 3;
    [logoutRequest setDelegate:self];
    [logoutRequest startAsynchronous];
}

- (void) kickBras
{
    NSURL *logout2Url = [NSURL URLWithString:@"http://bras.nju.edu.cn/selfservice/maintain/offline.jsf?cmdForm%3A_idJsp23=%E4%B8%8B%E7%BA%BF&cmdForm_SUBMIT=1"];
    ASIHTTPRequest *logout2Request = [ASIHTTPRequest requestWithURL:logout2Url];
    
    [logout2Request addRequestHeader:@"Host" value:@"bras.nju.edu.cn"];
    [logout2Request addRequestHeader:@"Origin" value:@"http://bras.nju.edu.cn"];
    [logout2Request addRequestHeader:@"Connection" value:@"keep-alive"];
    [logout2Request addRequestHeader:@"Cache-Control" value:@"max-age=0"];
    [logout2Request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/536.5 (KHTML, like Gecko) Chrome/19.0.1084.52 Safari/536.5"];
    [logout2Request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [logout2Request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
    [logout2Request addRequestHeader:@"Referer" value:@"http://bras.nju.edu.cn/selfservice/maintain/offline.jsf"];
    [logout2Request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
    [logout2Request addRequestHeader:@"Accept-Language" value:@"zh-CN,zh;q=0.8"];
    [logout2Request addRequestHeader:@"Accept-Charset" value:@"GBK,utf-8;q=0.7,*;q=0.3"];
    [logout2Request addRequestHeader:@"Content-Length" value:@"95"];
    [logout2Request addRequestHeader:@"Cookie" value:cookie];
        
    [logout2Request setTimeOutSeconds:5];
    
    logout2Request.tag = 4;
    [logout2Request setDelegate:self];
    [logout2Request startAsynchronous];
    
}

@end

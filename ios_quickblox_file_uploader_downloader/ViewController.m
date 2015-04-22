//
//  ViewController.m
//  ios_quickblox_file_uploader_downloader
//
//  Created by Maxim Bilan on 4/13/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

#import "ViewController.h"
#import "QuickBloxManager.h"
#import "SAMWeak.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton *testingButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)uploadAction:(UIButton *)sender
{
	WEAK(self);
	
	NSString *login = @"test";
	NSString *password = @"testtest";
	
	[[QuickBloxManager quickBloxManager] logInUserWithLogin:login password:password success:^{
		NSLog(@"Login Success");
		
		[_self uploadFiles];
	} failure:^(NSError *error) {
		NSLog(@"Login Failure");
	}];
}

- (IBAction)downloadAction:(UIButton *)sender
{
	WEAK(self);
	
	NSString *login = @"test";
	NSString *password = @"testtest";
	
	[[QuickBloxManager quickBloxManager] logInUserWithLogin:login password:password success:^{
		NSLog(@"Login Success");
		
		[_self downloadFiles];
	} failure:^(NSError *error) {
		NSLog(@"Login Failure");
	}];
}

- (IBAction)testAction:(UIButton *)sender
{
	[self login];
}

- (void)uploadFiles
{
	NSString *path1 = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"];
	NSString *path2 = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"jpg"];
	
	[self startWaiting];
	
	WEAK(self);
	[[QuickBloxManager quickBloxManager] uploadFiles:@[path1, path2] filenames:@[@"1.jpg", @"2.jpg"] success:^{
		[_self stopWaiting];
	} update:^(float percentCompletion) {
		[_progressView setProgress:percentCompletion animated:YES];
	} failure:^(NSError *error) {
		[_self stopWaiting];
	}];
}

- (void)downloadFiles
{
	[self startWaiting];
	
	WEAK(self);
	[[QuickBloxManager quickBloxManager] downloadFile:822342 success:^(NSString *path) {
		NSLog(@"%@", path);
		[_self stopWaiting];
	} update:^(float percentCompletion) {
		[_progressView setProgress:percentCompletion animated:YES];
	} failure:^(NSError *error) {
		[_self stopWaiting];
	}];
}

#pragma mark - Waiting

- (void)startWaiting
{
	[_activityIndicator startAnimating];
	self.view.userInteractionEnabled = NO;
	_progressView.hidden = NO;
	_progressView.progress = 0.0;
	_downloadButton.hidden = YES;
	_uploadButton.hidden = YES;
	_testingButton.hidden = YES;
}

- (void)stopWaiting
{
	[_activityIndicator stopAnimating];
	self.view.userInteractionEnabled = YES;
	_progressView.hidden = YES;
	_progressView.progress = 0.0;
	_downloadButton.hidden = NO;
	_uploadButton.hidden = NO;
	_testingButton.hidden = YES;
}

#pragma mark - Testing

- (void)login
{
	WEAK(self);
	
	NSString *login = @"test";
	NSString *password = @"testtest";
	
	[[QuickBloxManager quickBloxManager] logInUserWithLogin:login password:password success:^{
		NSLog(@"Login success");
		[_self logout];
	} failure:^(NSError *error) {
		NSLog(@"Login Failure: %@", error);
	}];
}

- (void)logout
{
	WEAK(self);
	
	[[QuickBloxManager quickBloxManager] logout:^{
		NSLog(@"Logout success");
		[_self login];
	} failure:^(NSError *error) {
		NSLog(@"Login Failure: %@", error);
	}];
}

@end

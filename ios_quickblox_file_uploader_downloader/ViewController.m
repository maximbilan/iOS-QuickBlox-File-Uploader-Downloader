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
	
	[[QuickBloxManager quickBloxManager] uploadFiles:@[path1, path2] filenames:@[@"1.jpg", @"2.jpg"] success:^{
		
	} update:^(float percentCompletion) {
		
	} failure:^(NSError *error) {
		
	}];
}

- (void)downloadFiles
{
	//749471
	
	[[QuickBloxManager quickBloxManager] downloadFile:749484 success:^(NSString *path) {
		
	} update:^(float percentCompletion) {
		
	} failure:^(NSError *error) {
		
	}];
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

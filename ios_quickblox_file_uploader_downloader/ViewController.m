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
	
	NSString *login = @"dusw02";
	NSString *password = @"9h6ols7j6m7fnp1u";
	
	[[QuickBloxManager quickBloxManager] logInUserWithLogin:login password:password success:^{
		NSLog(@"Login Success");
		
		[_self uploadFiles];
	} failure:^(NSError *error) {
		NSLog(@"Login Failure");
	}];
	
	
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

@end

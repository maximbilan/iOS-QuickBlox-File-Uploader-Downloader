//
//  ViewController.m
//  ios_quickblox_file_uploader_downloader
//
//  Created by Maxim Bilan on 4/13/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

#import "ViewController.h"
#import "QuickBloxManager.h"

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
	
	NSString *login = @"dusw02";
	NSString *password = @"9h6ols7j6m7fnp1u";
	
	[[QuickBloxManager quickBloxManager] logInUserWithLogin:login password:password success:^{
		NSLog(@"Login Success");
	} failure:^(NSError *error) {
		NSLog(@"Login Failure");
	}];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end

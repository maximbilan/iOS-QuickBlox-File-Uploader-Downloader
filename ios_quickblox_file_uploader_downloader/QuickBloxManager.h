//
//  BYQuickBloxManager.h
//  ios_quickblox_file_uploader_downloader
//
//  Created by Maxim Bilan on 4/13/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickBloxManager : NSObject

+ (QuickBloxManager *)quickBloxManager;

// Setup
- (void)setup;

// Sign in/out
- (void)createUserWithLogin:(NSString *)login password:(NSString *)password success:(void (^)(void))success failure:(void (^)(NSError *))failure;
- (void)logInUserWithLogin:(NSString *)login password:(NSString *)password success:(void (^)(void))success failure:(void (^)(NSError *))failure;
- (void)logout:(void (^)(void))success failure:(void (^)(NSError *))failure;

- (void)uploadFiles:(NSArray *)fileURLs
		  filenames:(NSArray *)filenames
			success:(void (^)(void))success
			 update:(void (^)(float percentCompletion))update
			failure:(void (^)(NSError *))failure;

- (void)downloadFile:(NSUInteger)fileId
			 success:(void (^)(NSString *path))success
			  update:(void (^)(float percentCompletion))update
			 failure:(void (^)(NSError *))failure;

@property (strong, nonatomic, readonly) NSString *login;
@property (strong, nonatomic, readonly) NSString *password;

@property (nonatomic, readonly) BOOL isLogged;

@end

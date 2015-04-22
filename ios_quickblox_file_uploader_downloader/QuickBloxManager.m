//
//  BYQuickBloxManager.m
//  ios_quickblox_file_uploader_downloader
//
//  Created by Maxim Bilan on 4/13/15.
//  Copyright (c) 2015 Maxim Bilan. All rights reserved.
//

#import "QuickBloxManager.h"

#import <Quickblox/Quickblox.h>
#import "ASIFormDataRequest.h"
#import "SAMWeak.h"
#import "MBFileDownloader.h"

@interface QuickBloxManager ()
{
	QBUUser *currentUser;
}

@property (nonatomic, readwrite) NSString *token;
@property (nonatomic, readwrite) BOOL isLogged;

@end

@implementation QuickBloxManager

#pragma mark - Initialization

+ (QuickBloxManager *)quickBloxManager
{
	static dispatch_once_t once_token;
	static QuickBloxManager *quickBloxManager = nil;
	dispatch_once(&once_token, ^{
		quickBloxManager = [[self alloc] init];
	});
	
	return quickBloxManager;
}

#pragma mark - Setup

- (void)setup
{
	[QBApplication sharedApplication].applicationId = 21320;
	[QBConnection registerServiceKey:@"mC3ZcEJO9Y4nXNJ"];
	[QBConnection registerServiceSecret:@"vqOLNZ3KLqabbRA"];
	[QBSettings setAccountKey:@"vmVE4sGeFsrcaFoi9iCG"];
	
	[QBConnection setAutoCreateSessionEnabled:YES];
	
#ifndef DEBUG
	[QBApplication sharedApplication].productionEnvironmentForPushesEnabled = YES;
	[QBSettings setLogLevel:QBLogLevelErrors];
#endif
}

#pragma mark - Sign in/out

- (void)createUserWithLogin:(NSString *)login password:(NSString *)password success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
	QBUUser *qbUser = [QBUUser user];
	qbUser.login = login;
	qbUser.password = password;
	
	WEAK(self);
	[QBRequest signUp:qbUser successBlock:^(QBResponse *response, QBUUser *user) {
		currentUser = user;
		currentUser.login = qbUser.login;
		currentUser.password = qbUser.password;
		NSLog(@"%@", response);
		[_self logInUserWithLogin:currentUser.login password:currentUser.password success:success failure:failure];
	} errorBlock:^(QBResponse *response) {
		NSLog(@"%@", response);
		failure(response.error.error);
	}];
}

- (void)logInUserWithLogin:(NSString *)login password:(NSString *)password success:(void (^)(void))success failure:(void (^)(NSError *))failure
{
	WEAK(self);
	
	currentUser = [QBUUser user];
	currentUser.login = login;
	currentUser.password = password;
	
	[QBRequest logInWithUserLogin:login password:password successBlock:^(QBResponse *response, QBUUser *user) {
		currentUser.ID = user.ID;
		currentUser.login = login;
		currentUser.password = password;
		_self.isLogged = YES;
		_token = [QBBaseModule sharedModule].token;
		
		success();
	} errorBlock:^(QBResponse *response) {
		failure(response.error.error);
	}];
}

- (void)logout:(void (^)(void))success failure:(void (^)(NSError *))failure;
{
	if (self.isLogged) {
		WEAK(self);
		[QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
			_self.isLogged = NO;
			currentUser = nil;
			success();
		} errorBlock:^(QBResponse *response) {
			failure(response.error.error);
		}];
	}
	else {
		currentUser = nil;
		success();
	}
}

#pragma mark - Upload/Download

- (void)uploadFiles:(NSArray *)fileURLs
		  filenames:(NSArray *)filenames
			success:(void (^)(void))success
			 update:(void (^)(float percentCompletion))update
			failure:(void (^)(NSError *))failure
{
	WEAK(self);
	
	NSMutableArray *blobs = [NSMutableArray array];
	
	NSInteger index = 0;
	for (NSString *filename in filenames) {
		
		QBCBlob *b = [QBCBlob blob];
		b.name = filename;
		b.contentType = @"image/jpeg";
		
		[QBRequest createBlob:b successBlock:^(QBResponse *response, QBCBlob *blob) {
			NSLog(@"Successfull response!");
			[blobs addObject:blob];
			if (blobs.count == filenames.count) {
				update(10);
				[_self uploadBlobs:blobs fileURLs:fileURLs success:success update:update failure:failure];
			}
		} errorBlock:^(QBResponse *response) {
			NSLog(@"Response error: %@", response.error);
			failure(response.error.error);
		}];
		
		++index;
	}
}

- (void)uploadBlobs:(NSArray *)blobs
		   fileURLs:(NSArray *)fileURLs
			success:(void (^)(void))success
			 update:(void (^)(float percentCompletion))update
			failure:(void (^)(NSError *))failure
{
	WEAK(self);
	NSInteger index = 0;
	__block NSInteger responseIndex = 0;
	__block NSInteger successIndex = 0;
	for (QBCBlob *blob in blobs) {
		NSString *url = fileURLs[index];
		
		NSString *expires = (NSString *)blob.blobObjectAccess.expires;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
		NSDate *dateExpires = [dateFormatter dateFromString:expires];
		long long epochTime = [@(floor([dateExpires timeIntervalSince1970])) longLongValue];
		
		NSLog(@"url params %@", blob.blobObjectAccess.urlWithParams);
		NSLog(@"expires %@", @(epochTime));
		
		NSError *attributesError;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url error:&attributesError];
		NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
		long long fileSize = [fileSizeNumber longLongValue];
		
		NSDictionary *params = blob.blobObjectAccess.params;
		
		// ASIHTTPRequest
		
		ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:blob.blobObjectAccess.url];
		[request setPostValue:params[@"key"] forKey:@"key"];
		[request setPostValue:params[@"acl"] forKey:@"acl"];
		[request setPostValue:params[@"success_action_status"] forKey:@"success_action_status"];
		[request setPostValue:params[@"AWSAccessKeyId"] forKey:@"AWSAccessKeyId"];
		[request setPostValue:params[@"Policy"] forKey:@"Policy"];
		[request setPostValue:params[@"Signature"] forKey:@"Signature"];
		[request setPostValue:params[@"Content-Type"] forKey:@"Content-Type"];
		[request setFile:url forKey:@"file"];
		
		[request setCompletionBlock:^{
			// Use when fetching text data
			//NSString *responseString = [request responseString];
			
			// Use when fetching binary data
			//NSData *responseData = [request responseData];
			
			++responseIndex;
			++successIndex;
			if (responseIndex == blobs.count) {
				if (successIndex == responseIndex) {
					update(80);
					[_self completeBlobs:blobs fileURLs:fileURLs success:success update:update failure:failure];
				}
				else {
					failure(nil);
				}
			}
			
//			[QBRequest completeBlobWithID:blob.ID size:fileSize successBlock:^(QBResponse *response) {
//				int a;
//				a= 0;
//			} errorBlock:^(QBResponse *response) {
//			}];
		}];
		
		[request setFailedBlock:^{
			++responseIndex;
			if (responseIndex == blobs.count) {
				failure(nil);
			}
		}];
		
		[request startAsynchronous];
		
		++index;
	}
}

- (void)completeBlobs:(NSArray *)blobs
			 fileURLs:(NSArray *)fileURLs
			  success:(void (^)(void))success
			   update:(void (^)(float percentCompletion))update
			  failure:(void (^)(NSError *))failure
{
	NSInteger index = 0;
	__block NSInteger responseIndex = 0;
	__block NSInteger successIndex = 0;
	for (QBCBlob *blob in blobs) {
		NSString *url = fileURLs[index];
		
		NSError *attributesError;
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:url error:&attributesError];
		NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
		long long fileSize = [fileSizeNumber longLongValue];
		
		[QBRequest completeBlobWithID:blob.ID size:fileSize successBlock:^(QBResponse *response) {
			++responseIndex;
			++successIndex;
			if (responseIndex == blobs.count) {
				if (successIndex == responseIndex) {
					update(100);
					success();
				}
				else {
					failure(nil);
				}
			}
		} errorBlock:^(QBResponse *response) {
			++responseIndex;
			if (responseIndex == blobs.count) {
				failure(nil);
			}
		}];
		++index;
	}
}

- (void)downloadFile:(NSUInteger)fileId
			 success:(void (^)(NSString *path))success
			  update:(void (^)(float percentCompletion))update
			 failure:(void (^)(NSError *))failure
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	NSString *lastPathComponent = [NSString stringWithFormat:@"%@", @(fileId)];
	NSString *filePath = [basePath stringByAppendingPathComponent:lastPathComponent];
	
	[QBRequest blobObjectAccessWithBlobID:fileId successBlock:^(QBResponse *response, QBCBlobObjectAccess *objectAccess) {
		MBFileDownloader *fileDownloader = [[MBFileDownloader alloc] initWithURL:[NSURL URLWithString:objectAccess.urlWithParams]
																	  toFilePath:filePath];
		[fileDownloader downloadWithSuccess:^{
			success(filePath);
		} update:^(float value) {
			update(value);
		} failure:^(NSError *error) {
			failure(error);
		}];
	} errorBlock:^(QBResponse *response) {
		failure(response.error.error);
	}];
}

#pragma mark - Properties

- (NSString *)login
{
	return currentUser.login;
}

- (NSString *)password
{
	return currentUser.password;
}

@end

//
//  BYQuickBloxManager.m
//  disckreet
//
//  Created by Maxim Bilan on 3/26/15.
//  Copyright (c) 2015 Antovate Pty Ltd. All rights reserved.
//

#import "QuickBloxManager.h"

#import <Quickblox/Quickblox.h>
#import "STHTTPRequest.h"
#import "SAMWeak.h"

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
	for (NSString *fileURL in fileURLs) {
		NSString *filename = filenames[index];
		
		QBCBlob *b = [QBCBlob blob];
		b.name = filename;
		//b.contentType = @"application/octet-stream";
		b.contentType = @"image/jpeg";
		
		[QBRequest createBlob:b successBlock:^(QBResponse *response, QBCBlob *blob) {
			NSLog(@"Successfull response!");
			[blobs addObject:blob];
			
			if (blobs.count == fileURLs.count) {
				[_self uploadBlobs:blobs fileURLs:fileURLs];
			}
		} errorBlock:^(QBResponse *response) {
			NSLog(@"Response error: %@", response.error);
			
			failure(response.error.error);
		}];
		
		++index;
	}
}

- (void)uploadBlobs:(NSArray *)blobs fileURLs:(NSArray *)fileURLs
{
	NSInteger index = 0;
	for (QBCBlob *blob in blobs) {
		NSString *url = fileURLs[index];
		STHTTPRequest *request = [STHTTPRequest requestWithURL:blob.blobObjectAccess.url];
		request.HTTPMethod = @"POST";
		
		NSString *expires = (NSString *)blob.blobObjectAccess.expires;
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
		NSDate *dateExpires = [dateFormatter dateFromString:expires];
		long long epochTime = [@(floor([dateExpires timeIntervalSince1970])) longLongValue];
		
		NSMutableDictionary *params = [NSMutableDictionary new];
		[params addEntriesFromDictionary:blob.blobObjectAccess.params];
		[params setObject:@(epochTime) forKey:@"Expires"];
		
		NSLog(@"url params %@", blob.blobObjectAccess.urlWithParams);
		NSLog(@"expires %@", @(epochTime));
		
		request.POSTDictionary = params;
		[request addFileToUpload:url parameterName:@"file"];
		request.completionBlock = ^(NSDictionary *headers, NSString *body) {
			NSLog(@"%@ %@", headers, body);
		};
		
		request.errorBlock = ^(NSError *error) {
			NSLog(@"%@", error.description);
		};
		
		[request startAsynchronous];
		
		++index;
	}
}

- (void)downloadFile:(NSUInteger)fileId
			 success:(void (^)(NSData *))success
			  update:(void (^)(float percentCompletion))update
			 failure:(void (^)(NSError *))failure
{
	[QBRequest TDownloadFileWithBlobID:fileId successBlock:^(QBResponse *response, NSData *fileData) {
		success(fileData);
	} statusBlock:^(QBRequest *request, QBRequestStatus *status) {
		update(status.percentOfCompletion);
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

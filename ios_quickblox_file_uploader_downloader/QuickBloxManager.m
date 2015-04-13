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

@interface BYQuickBloxManager ()
{
	QBUUser *currentUser;
}

@property (nonatomic, readwrite) NSString *token;

@property (nonatomic, readwrite) BOOL isLogged;

@end

@implementation BYQuickBloxManager

#pragma mark - Initialization

+ (BYQuickBloxManager *)quickBloxManager
{
	static dispatch_once_t once_token;
	static BYQuickBloxManager *quickBloxManager = nil;
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
	NSMutableArray *blobs = [NSMutableArray array];
	dispatch_semaphore_t semaphore;
	
	semaphore = dispatch_semaphore_create(0);
	
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
			
			if (fileURLs.count - 1 == index) {
				dispatch_semaphore_signal(semaphore);
			}
		} errorBlock:^(QBResponse *response) {
			NSLog(@"Response error: %@", response.error);
			
			if (fileURLs.count - 1 == index) {
				dispatch_semaphore_signal(semaphore);
			}
		}];
		
		++index;
	}
	
	dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	
	if (fileURLs.count != blobs.count) {
		failure(nil);
		return;
	}
	
	if (blobs.count > 0) {
		
		semaphore = dispatch_semaphore_create(0);
		
		NSInteger index = 0;
		for (QBCBlob *blob in blobs) {
			NSString *url = fileURLs[index];
			STHTTPRequest *request = [STHTTPRequest requestWithURL:blob.blobObjectAccess.url];
			request.HTTPMethod = @"POST";
			
//			NSDictionary *params = @{
//									 @"AWSAccessKeyId" : blob.blobObjectAccess.params[@""],
//									 @"Signature" : blob.blobObjectAccess.params[@""],
//									 @"" : blob.blobObjectAccess.expires
//									 };
//			request.POSTDictionary = params;
			
			NSLog(@"Token %@", self.token);
			NSLog(@"Time: %f", floor([blob.blobObjectAccess.expires timeIntervalSince1970] * 1000));
			
			request.POSTDictionary = blob.blobObjectAccess.params;
			[request addFileToUpload:url parameterName:@"file"];
			
			request.completionBlock = ^(NSDictionary *headers, NSString *body) {
				
				NSLog(@"%@ %@", headers, body);
				
				if (blobs.count - 1 == index) {
					dispatch_semaphore_signal(semaphore);
				}
			};
			
			request.errorBlock = ^(NSError *error) {
				
				NSLog(@"%@", error.description);
				
				if (blobs.count - 1 == index) {
					dispatch_semaphore_signal(semaphore);
				}
			};
			
			[request startAsynchronous];
			
			++index;
		}
		
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
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

//
//  ABMAppUpdateNotifier.h
//  ApplicationUpdateDemo
//
//  Created by Abdul Basit on 3/13/15.
//  Copyright (c) 2015 Abdul Basit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApplicationInformation.h"

#define kAppUpdateItunesLookUpURLFormat    @"http://itunes.apple.com/lookup?bundleId=%@"


typedef enum {
    APPUPDATE_NO_CONNECTION_ERROR_CODE = 100,
    APPUPDATE_RESPONSE_PARSING_ERROR_CODE = 101,
    APPUPDATE_NO_APP_FOUND_ERROR_CODE = 102,
    APPUPDATE_UNKNOWN_ERROR_CODE = 103,
} AppUpdateErrorCode;

#if NS_BLOCKS_AVAILABLE

typedef void (^AppUpdateCodeBlock)(NSError* error, NSString* currentVersion, NSString *itunesVersion, ApplicationInformation* appInfo, BOOL isUpdateAvailable);

#endif


@protocol AppUpdateNotifierDelegate <NSObject>

@required
-(void) appUpdateCompleteWithCurrentVersion:(NSString*)currentVersion withItunesVersion:(NSString*)itunesVersion withApplicatonInfo:(ApplicationInformation*) appInfo isUpdateAvailable:(BOOL) updateAvaliable;

@optional
-(void) appUpdateFailed:(NSError *)error;


@end

@interface AppUpdateNotifier : NSObject<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSString * _bundleIdentifier;
    NSString *_currentVersion;
    AppUpdateCodeBlock _completionCallBack;
    
    NSMutableData * _responseData;
}

@property(nonatomic, weak) id<AppUpdateNotifierDelegate> delegate;


+(id) sharedInstance;
-(void) checkNow;


#if NS_BLOCKS_AVAILABLE

-(void) checkNowWithBlock:(AppUpdateCodeBlock) block;

#endif


@end

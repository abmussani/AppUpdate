//
//  ABMAppUpdateNotifier.m
//  ApplicationUpdateDemo
//
//  Created by Abdul Basit on 3/13/15.
//  Copyright (c) 2015 Abdul Basit. All rights reserved.
//

#import "AppUpdateNotifier.h"

@interface AppUpdateNotifier (Private)

-(void) executeFailureCode:(NSError*)error;
-(void) executeSuccessCodeWithCurrentVersion:(NSString*)currentVersion withItunesVersion:(NSString*) itunesVersion withApplicationInfo:(ApplicationInformation*) info withIsUpdateAvailable:(BOOL) isUpdateAvailable;
-(NSString*) getErrorDomainString:(NSString*) domain;
-(NSError*) getErrorObject:(AppUpdateErrorCode) errorCode;
-(NSComparisonResult) compareVersions: (NSString*) version1 version2: (NSString*) version2;

@end

@implementation AppUpdateNotifier


+(id)sharedInstance
{
    static AppUpdateNotifier *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}



-(id) init
{
    if(self = [super init])
    {
        _bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        _currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    }
    return self;
}

- (NSComparisonResult) compareVersions: (NSString*) version1 version2: (NSString*) version2 {
    NSComparisonResult result = NSOrderedSame;
    
    NSMutableArray* a = [[version1 componentsSeparatedByString: @"."] mutableCopy];
    NSMutableArray* b = [[version2 componentsSeparatedByString: @"."] mutableCopy];
    
    while (a.count < b.count) { [a addObject: @"0"]; }
    while (b.count < a.count) { [b addObject: @"0"]; }
    
    for (int i = 0; i < a.count; ++i) {
        if ([[a objectAtIndex: i] integerValue] < [[b objectAtIndex: i] integerValue]) {
            result = NSOrderedAscending;
            break;
        }
        else if ([[b objectAtIndex: i] integerValue] < [[a objectAtIndex: i] integerValue]) {
            result = NSOrderedDescending;
            break;
        }
    }
    
    return result;
}

-(void) executeFailureCode:(NSError*)error
{
    
    if([self.delegate respondsToSelector:@selector(appUpdateFailed:)])
    {
        [self.delegate appUpdateFailed:error];
    }
    
    // notify thru code block if it was given at the time of checking;
#if NS_BLOCKS_AVAILABLE
    
    if(_completionCallBack != nil)
    {
        _completionCallBack(error,nil, nil, nil, NO);
    }
#endif
    
}

-(void) executeSuccessCodeWithCurrentVersion:(NSString*)currentVersion withItunesVersion:(NSString*) itunesVersion withApplicationInfo:(ApplicationInformation*) info withIsUpdateAvailable:(BOOL) isUpdateAvailable
{
    if([self.delegate respondsToSelector:@selector(appUpdateCompleteWithCurrentVersion:withItunesVersion:withApplicatonInfo:isUpdateAvailable:)])
    {
        [self.delegate appUpdateCompleteWithCurrentVersion:currentVersion withItunesVersion:itunesVersion withApplicatonInfo:info isUpdateAvailable:isUpdateAvailable];
    }
    
#if NS_BLOCKS_AVAILABLE
    if(_completionCallBack != nil)
    {
        _completionCallBack(nil, currentVersion, itunesVersion, info, YES);
    }
#endif
}

-(NSString*) getErrorDomainString:(NSString*) domain
{
    return [NSString stringWithFormat:@"%@.%@", _bundleIdentifier, domain];
}

-(NSError*) getErrorObject:(AppUpdateErrorCode) errorCode
{
    NSString *errorDomain = nil;
    NSString* errorMessage = nil;
    switch (errorCode) {
        case APPUPDATE_NO_CONNECTION_ERROR_CODE:
            errorDomain = [self getErrorDomainString:@"connection_error"];
            errorMessage = @"Network connectivity issue";
            break;
            
        case APPUPDATE_NO_APP_FOUND_ERROR_CODE:
            errorDomain = [self getErrorDomainString:@"no_app_found_error"];
            errorMessage = @"No application found on itunes";
            break;
            
        case APPUPDATE_RESPONSE_PARSING_ERROR_CODE:
            errorDomain = [self getErrorDomainString:@"parsing_response_error"];
            errorMessage = @"Error in parsing response from itunes";
            break;
            
        default:
            errorDomain = [self getErrorDomainString:@"unknown_error"];
            errorMessage = @"Unknown error occured";
            break;
    }
    
    
    return [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{@"ErrorMessage": errorMessage}];
}


-(void) checkNow
{
    _responseData = [NSMutableData data];
    
    NSURL *lookUpUrl = [NSURL URLWithString:[NSString stringWithFormat:kAppUpdateItunesLookUpURLFormat, _bundleIdentifier]];
    NSURLConnection *lookUpConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: lookUpUrl] delegate:self];
    
    if(lookUpConnection == nil)
    {
        // notify thru delegates
        [self executeFailureCode: [self getErrorObject: APPUPDATE_NO_CONNECTION_ERROR_CODE]];
    }
}


#if NS_BLOCKS_AVAILABLE

-(void) checkNowWithBlock:(AppUpdateCodeBlock) block
{
    if(_completionCallBack != nil)
    {
        _completionCallBack = nil;
    }
    
    _completionCallBack = block;
    [self checkNow];
}

#endif

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_responseData setLength: 0];
}


-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // jama karna hai
    [_responseData appendData: data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // pasring
    @try {

        NSError* error = nil;

        NSDictionary* object = [NSJSONSerialization  JSONObjectWithData: _responseData options: 0 error: &error];
        if (error != nil) {
            [self executeFailureCode: [self getErrorObject: APPUPDATE_RESPONSE_PARSING_ERROR_CODE]];
            return;
        }

        NSInteger resultCount = [[object objectForKey:@"resultCount"] integerValue];

        if(resultCount > 0)
        {
            NSArray *result = [object objectForKey:@"results"];
            if([result count] >0)
            {
                NSDictionary* appInfoDictionary = [result objectAtIndex:0];
                NSString* itunesVersion = [appInfoDictionary objectForKey:@"version"];

                ApplicationInformation *appInfo = [[ApplicationInformation alloc] init];
                appInfo.screenshotUrls = [appInfoDictionary objectForKey:@"screenshotUrls"];
                appInfo.price = [[appInfoDictionary objectForKey:@"price"] floatValue];
                appInfo.sellerName = [appInfoDictionary objectForKey:@"sellerName"];
                appInfo.overallUserRating = [[appInfoDictionary objectForKey:@"averageUserRating"] floatValue];
                appInfo.currentVersionUserRating= [[appInfoDictionary objectForKey:@"averageUserRatingForCurrentVersion"] floatValue];
                appInfo.appDescription = [appInfoDictionary objectForKey:@"description"];
                appInfo.itunesVersion = itunesVersion;
                appInfo.artnetworkUrls60 = [appInfoDictionary objectForKey:@"artworkUrl60"];
                appInfo.artnetworkUrl100 = [appInfoDictionary objectForKey:@"artworkUrl100"];
                appInfo.artnetworkUrl512 = [appInfoDictionary objectForKey:@"artworkUrl512"];

                BOOL isUpdate = ([self compareVersions:_currentVersion version2:itunesVersion] == NSOrderedAscending);

                [self executeSuccessCodeWithCurrentVersion:_currentVersion withItunesVersion:itunesVersion withApplicationInfo:appInfo withIsUpdateAvailable:isUpdate];
            }
            else
            {
                [self executeFailureCode: [self getErrorObject: APPUPDATE_NO_APP_FOUND_ERROR_CODE]];
            }
        }
        else
        {
            [self executeFailureCode: [self getErrorObject: APPUPDATE_NO_APP_FOUND_ERROR_CODE]];
        }
    }
    @catch (NSException *exception) {
        [self executeFailureCode:[self getErrorObject: APPUPDATE_RESPONSE_PARSING_ERROR_CODE]];
    }

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self executeFailureCode: [self getErrorObject: APPUPDATE_NO_CONNECTION_ERROR_CODE]];
}

@end

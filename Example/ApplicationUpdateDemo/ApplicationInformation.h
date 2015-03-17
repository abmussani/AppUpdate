//
//  ApplicationInformation.h
//  ApplicationUpdateDemo
//
//  Created by Abdul Basit on 3/17/15.
//  Copyright (c) 2015 Abdul Basit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationInformation : NSObject
{
    
}

@property (nonatomic, strong) NSArray * screenshotUrls;
@property (nonatomic, strong) NSString * artnetworkUrls60;
@property (nonatomic, strong) NSString * artnetworkUrl100;
@property (nonatomic, strong) NSString * artnetworkUrl512;
@property (nonatomic, assign) NSString* appDescription;
@property (nonatomic, assign) NSString* itunesVersion;
@property (nonatomic, assign) NSString* sellerName;
@property (nonatomic, assign) float     overallUserRating;
@property (nonatomic, assign) float     currentVersionUserRating;
@property (nonatomic, assign) float     price;


@end

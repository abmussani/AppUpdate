//
//  AppDelegate.h
//  ApplicationUpdateDemo
//
//  Created by Abdul Basit on 3/13/15.
//  Copyright (c) 2015 Abdul Basit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUpdateNotifier.h"

@interface AppDelegate : UIResponder <AppUpdateNotifierDelegate, UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


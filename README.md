# AppUpdateNotifier

A simple class that calls Apple's search API service (http://itunes.apple.com/lookup) to get info for an application bundle identifier and check if an App update is available. This class will read bundle identifier from info plist of target.

After getting response from lookup service, This class will compare current version (retrieved using CFBundleShortVersionString from info.plist) and itunes's version and notify delegates.

## How to use it
### Using delegate
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  AppUpdateNotifier *appUpdateNotifier = [AppUpdateNotifier sharedInstance];
  appUpdateNotifier.delegate = self;

  [appUpdateNotifier checkNow];
}

-(void)appUpdateCompleteWithCurrentVersion:(NSString *)currentVersion withItunesVersion:(NSString *)itunesVersion withApplicatonInfo:(ApplicationInformation *)appInfo isUpdateAvailable:(BOOL)updateAvaliable
{
    NSLog(@"Current Version: %@", currentVersion);
    NSLog(@"New Version: %@", itunesVersion);
    NSLog(@"Is Update Available: %@", updateAvaliable? @"Yes" : @"No");
}

-(void)appUpdateFailed:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

```

### Using blocks 

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    AppUpdateNotifier *appUpdateNotifier = [AppUpdateNotifier sharedInstance];
    
    [appUpdateNotifier checkNowWithBlock:^(NSError *error, NSString *currentVersion, NSString *itunesVersion, ApplicationInformation *appInfo, BOOL isUpdateAvailable) {
        if(error != nil)
        {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"Current Version: %@", currentVersion);
            NSLog(@"New Version: %@", itunesVersion);
            NSLog(@"Is Update Available: %@", isUpdateAvailable? @"Yes" : @"No");
        }
    }];
}
```

//
//  GameSettings.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "GameSettings.h"
#import "Reachability.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "MTRandom.h"

@implementation GameSettings

@synthesize inDebug, displayScreenStats, backgroundMusicEnabled, fontName, textColor, appStoreID, appStoreURL;
@synthesize storeLevelsIdentifiers, settStarsSpeed, playerLives, playerCredits, useMTRandom, motionManager;

+ (GameSettings *)sharedInstance {
    static dispatch_once_t once;
    static GameSettings * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)LogThis:(NSString *)log, ... {
    if (self.inDebug) {
        NSString *output;
        va_list ap;
        va_start(ap, log);
        output = [[NSString alloc] initWithFormat:log arguments:ap];
        va_end(ap);
        NSLog(@"[HyperSuit] %@", output);
    }
}

- (BOOL)internetAvailable {
	Reachability *r = [Reachability reachabilityForInternetConnection];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	BOOL result = FALSE;
	if (internetStatus == ReachableViaWiFi || internetStatus == ReachableViaWWAN)
	    result = TRUE;
	return result;
}

- (id) init {
	if (self = [super init]) {
        self.inDebug = YES;
        self.displayScreenStats = self.inDebug;
        self.backgroundMusicEnabled = NO;
        self.useMTRandom = YES;
        
        self.fontName = @"Harabara";
        self.appStoreID = @"734264899";
        self.appStoreURL = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/hypersuit/id%@?ls=1&mt=8", self.appStoreID];
        
        self.storeLevelsIdentifiers = [NSSet setWithObjects:
                                       @"net.supudo.apps.ios.HyperSuit.missions.Pack1",
                                       nil];
        
        self.settStarsSpeed = 1;
        self.playerLives = 3;
        self.playerCredits = 10;
        
        self.motionManager = [[CMMotionManager alloc] init];

        [self initializeGoogleAnalytics];
    }
    return self;
}

- (void)initializeGoogleAnalytics {
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 300;
    if (self.inDebug)
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    else
        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
    if (self.inDebug)
        self.GATracker = [[GAI sharedInstance] trackerWithTrackingId:@"<debug-id>"];
    else
        self.GATracker = [[GAI sharedInstance] trackerWithTrackingId:@"<live-id>"];
}

- (void)GATrack:(NSString *)screen {
    [self.GATracker set:kGAIScreenName value:screen];
    [self.GATracker send:[[GAIDictionaryBuilder createAppView] build]];
    //[[GAI sharedInstance] dispatch];
}

- (CGFloat)randomFloatBetween:(CGFloat)low andValue:(CGFloat)high {
    return (((CGFloat) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (double)randomDoubleBetween:(double)low andValue:(double)high {
    MTRandom *rnd = [[MTRandom alloc] init];
    return [rnd randomDoubleFrom:low to:high];
}

- (int)randomMTInt {
    MTRandom *rnd = [[MTRandom alloc] init];
    return [rnd randomUInt32];
}

- (int)randomIntBetween:(int)min andValue:(int)max {
    return arc4random() % max + 1;
}

- (UIColor *)getRandomColor {
    float r = (arc4random() % 50);
    float randomRed = r / 255;
    float randomGreen = r / 255;
    float randomBlue = r / 255;
    return [UIColor colorWithRed:randomRed green:randomGreen blue:randomBlue alpha:1.0];
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
	return degrees / 180.0f * M_PI;
}

- (CGPoint)mult:(CGPoint)v with:(CGFloat)s {
	return CGPointMake(v.x * s, v.y * s);
}

@end

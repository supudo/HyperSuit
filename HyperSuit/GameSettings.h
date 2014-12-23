//
//  GameSettings.h
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

@import CoreMotion;
#import "GAI.h"

#define kGCAchievementFirstLevel @"hypersuit_straigtshooter"

//#define DegToRad(angle) ((angle) / 180.0 * M_PI)
#define DegToRad(angle) [[GameSettings sharedInstance] degreesToRadians:angle]
#define Multiply(rect, s) [[GameSettings sharedInstance] mult:rect with:s]

@interface GameSettings : NSObject

@property BOOL inDebug, displayScreenStats, backgroundMusicEnabled, useMTRandom;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *appStoreID, *appStoreURL;
@property (nonatomic, strong) NSSet *storeLevelsIdentifiers;
@property float settStarsSpeed;
@property int playerLives, playerCredits;
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, strong) id<GAITracker> GATracker;

- (void)LogThis:(NSString *)log, ...;
- (BOOL)internetAvailable;
- (void)GATrack:(NSString *)screen;
- (CGFloat)randomFloatBetween:(CGFloat)low andValue:(CGFloat)high;
- (double)randomDoubleBetween:(double)low andValue:(double)high;
- (int)randomMTInt;
- (int)randomIntBetween:(int)min andValue:(int)max;
- (UIColor *)getRandomColor;
- (CGFloat)degreesToRadians:(CGFloat)degrees;
- (CGPoint)mult:(CGPoint)v with:(CGFloat)s;

+ (GameSettings *)sharedInstance;

@end

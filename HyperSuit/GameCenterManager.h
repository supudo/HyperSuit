//
//  GameCenterManager.h
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "GameCenterDelegate.h"

@interface GameCenterManager : NSObject <GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>

@property (weak) id<GameCenterDelegate> delegate;

typedef enum GCMOperation {
    GCMOperationAuthenticate = 0,
	GCMOperationLeaderboards,
	GCMOperationAchievements
} GCMOperation;

@property GCMOperation GCMCurrentOperation;

- (BOOL)isGameCenterAPIAvailable;
- (void)showAchievements;
- (void)showLeaderboards;
- (void)submitScore:(int64_t)score category:(NSString *)category;
- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete;

+ (GameCenterManager *)sharedInstance;

@end

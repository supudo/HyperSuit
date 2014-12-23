//
//  GameCenterDelegate.h
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

@protocol GameCenterDelegate <NSObject>
@optional
- (void)gameCenterExitScreen:(id)sender;
- (void)gameCenterFailed:(id)sender withError:(NSString *)error;
- (void)gameCenterPlayerAuthenticated:(id)sender;
- (void)gameCenterAuthenticate:(id)sender withViewController:(UIViewController *)viewController;
- (void)gameCenterAchievements:(id)sender withViewController:(UIViewController *)viewController;
- (void)gameCenterLeaderboards:(id)sender withViewController:(UIViewController *)viewController;
- (void)gameCenterScoreSubmitted:(int64_t)score;
- (void)gameCenterAchievementSubmitted:(GKAchievement *)ach error:(NSError *)error;
@end

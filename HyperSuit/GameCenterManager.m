//
//  GameCenterManager.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "GameCenterManager.h"

@interface GameCenterManager ()
@property BOOL achievementsRequested;
@property (retain) NSMutableDictionary *earnedAchievementCache;
@end

@implementation GameCenterManager

@synthesize delegate, GCMCurrentOperation, earnedAchievementCache;

+ (GameCenterManager *)sharedInstance {
    static dispatch_once_t once;
    static GameCenterManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Game Center

- (BOOL)isGameCenterAPIAvailable {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] isGameCenterAPIAvailable ..."];
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    // Device must be running 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    return (localPlayerClassAvailable && osVersionSupported);
}

#pragma mark - Authentication

- (void)authenticateLocalPlayer {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] authenticateLocalPlayer ..."];
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        if (viewController != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] authenticateLocalPlayer - authenticatePlayerWithView ..."];
                [self authenticatePlayerWithView:viewController];
            });
        }
        else if (error != nil) {
            [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] authenticateLocalPlayer - error - %@ ...", [error localizedDescription]];
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterFailed:withError:)])
                [self.delegate gameCenterFailed:self withError:[error localizedDescription]];
        }
        else
            [self playerAuthenticated];
    };
}

- (void)authenticatePlayerWithView:(UIViewController *)viewController {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] authenticatePlayerWithView ..."];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterAuthenticate:withViewController:)])
        [self.delegate gameCenterAuthenticate:self withViewController:viewController];
}

- (void)playerAuthenticated {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] playerAuthenticated ..."];
    switch (self.GCMCurrentOperation) {
        case GCMOperationLeaderboards:
            [self showLeaderboards];
            break;
        case GCMOperationAchievements:
            [self showAchievements];
            break;
        case GCMOperationAuthenticate:
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterPlayerAuthenticated:)])
                [self.delegate gameCenterPlayerAuthenticated:self];
            break;
        default:
            break;
    }
}

#pragma mark - Achievements

- (void)showAchievements {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] showAchievements ..."];
    self.GCMCurrentOperation = GCMOperationAchievements;
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.isAuthenticated) {
        [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] showing achievements controller ..."];
        GKAchievementViewController *cont = [[GKAchievementViewController alloc] init];
        if (cont!= nil) {
            cont.achievementDelegate = self;
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterAchievements:withViewController:)])
                [self.delegate gameCenterAchievements:self withViewController:cont];
        }
    }
    else
        [self authenticateLocalPlayer];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] achievementViewControllerDidFinish ..."];
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterExitScreen:)])
            [self.delegate gameCenterExitScreen:self];
    }];
}

- (void)submitAchievement:(NSString *)identifier percentComplete:(double)percentComplete {
    if (self.earnedAchievementCache == NULL) {
        [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *scores, NSError *error) {
            if (error == nil) {
                NSMutableDictionary *tempCache = [NSMutableDictionary dictionaryWithCapacity:[scores count]];
                 for (GKAchievement *score in tempCache)
                     [tempCache setObject:score forKey:score.identifier];
                 self.earnedAchievementCache = tempCache;
                 [self submitAchievement:identifier percentComplete:percentComplete];
            }
            else {
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterAchievementSubmitted:error:)])
                    [self.delegate gameCenterAchievementSubmitted:nil error:error];
            }
         }];
	}
	else {
		GKAchievement *achievement = [self.earnedAchievementCache objectForKey:identifier];
		if (achievement != nil) {
			if ((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete))
				achievement = nil;
			achievement.percentComplete = percentComplete;
		}
		else {
			achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
			achievement.percentComplete = percentComplete;
			[self.earnedAchievementCache setObject:achievement forKey:achievement.identifier];
		}
		if (achievement != nil) {
            [achievement reportAchievementWithCompletionHandler: ^(NSError *error)
             {
                 if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterAchievementSubmitted:error:)])
                     [self.delegate gameCenterAchievementSubmitted:achievement error:error];
             }];
		}
	}
}

#pragma mark - Leaderboards

- (void)showLeaderboards {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] showLeaderboards ..."];
    self.GCMCurrentOperation = GCMOperationLeaderboards;
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.isAuthenticated) {
        [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] showing leaderboards controller ..."];
        GKLeaderboardViewController *cont = [[GKLeaderboardViewController alloc] init];
        if (cont != nil) {
            cont.leaderboardDelegate = self;
            cont.timeScope = GKLeaderboardTimeScopeAllTime;
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterLeaderboards:withViewController:)])
                [self.delegate gameCenterLeaderboards:self withViewController:cont];
        }
    }
    else
        [self authenticateLocalPlayer];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] leaderboardViewControllerDidFinish ..."];
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterExitScreen:)])
            [self.delegate gameCenterExitScreen:self];
    }];
}

- (void)submitScore:(int64_t)score category:(NSString *)category {
    if (![self isGameCenterAPIAvailable]) {
        [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] Player not authenticated"];
        return;
    }
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] submitScore to %@ - %lli ...", category, score];
    GKScore *gkScore = [[GKScore alloc] initWithCategory:category];
    gkScore.value = score;
    [gkScore reportScoreWithCompletionHandler: ^(NSError* error) {
        if (error == nil) {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterScoreSubmitted:)])
                [self.delegate gameCenterScoreSubmitted:score];
        }
        else {
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterFailed:withError:)])
                [self.delegate gameCenterFailed:self withError:[error localizedDescription]];
        }
    }];
}

#pragma mark - Game Center delegates

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [[GameSettings sharedInstance] LogThis:@"[GameCenterManager] gameCenterViewControllerDidFinish ..."];
    [gameCenterViewController dismissViewControllerAnimated:YES completion:^{
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(gameCenterExitScreen:)])
            [self.delegate gameCenterExitScreen:self];
    }];
}

@end

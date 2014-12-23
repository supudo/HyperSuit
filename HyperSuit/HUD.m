//
//  HUD.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "HUD.h"
#import "GameScene.h"
#import "ShipGen.h"

@implementation HUD

@synthesize gameView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gameView.showsFPS = [GameSettings sharedInstance].displayScreenStats;
    self.gameView.showsNodeCount = [GameSettings sharedInstance].displayScreenStats;
    self.gameView.showsDrawCount = [GameSettings sharedInstance].displayScreenStats;
    
    SKScene *scene = [GameScene sceneWithSize:self.gameView.bounds.size];
    //SKScene *scene = [ShipGen sceneWithSize:self.gameView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.gameView presentScene:scene];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.gameView.paused = YES;
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[GameSettings sharedInstance].motionManager stopAccelerometerUpdates];
    
}

- (IBAction)iboNew:(id)sender {
    ShipGen *g = (ShipGen *)self.gameView.scene;
    [g generateSpaceship:NO];
}

@end

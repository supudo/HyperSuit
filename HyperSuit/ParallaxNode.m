//
//  ParallaxNode.m
//  HyperSuit
//
//  Created by Sergey Petrov on 12/3/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "ParallaxNode.h"

@interface ParallaxNode ()
@property __block NSMutableArray *backgrounds;
@property NSInteger numberOfImagesForBackground;
@property NSTimeInterval lastUpdateTime, deltaTime;
@property float pointsPerSecondSpeed;
@property BOOL randomizeDuringRollover;
@end

@implementation ParallaxNode

@synthesize viewSize, backgrounds, numberOfImagesForBackground, lastUpdateTime, deltaTime;
@synthesize pointsPerSecondSpeed, randomizeDuringRollover, shouldRotateNodes;

- (instancetype)init:(NSArray *)files size:(CGSize)size pointsPerSecondSpeed:(float)speed withName:(NSString *)pxName loadNum:(int)ln {
    if (self = [super init]) {
        pointsPerSecondSpeed = speed;
        numberOfImagesForBackground = [files count];
        backgrounds = [NSMutableArray arrayWithCapacity:numberOfImagesForBackground];
        randomizeDuringRollover = NO;
        shouldRotateNodes = NO;
        
        if ([files count] < ln)
            ln = [files count];
        
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:obj];
            [node setSize:size];
            [node setAnchorPoint:CGPointZero];
            [node setPosition:CGPointMake(0.0, size.height * idx)];
            [node setName:pxName];
            [node setBlendMode:SKBlendModeAdd];
            [node setHidden:YES];
            [backgrounds addObject:node];
            [self addChild:node];
        }];

        for (int i=0; i<ln; i++) {
            int idx = [[GameSettings sharedInstance] randomIntBetween:0 andValue:[backgrounds count]];
            SKSpriteNode *n = [backgrounds objectAtIndex:idx];
            [n setHidden:NO];
        }
    }
    return self;
}

- (void)randomizeNodesPositions {
    [backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *node = (SKSpriteNode *)obj;
        [self randomizeNodePosition:node];
    }];
    randomizeDuringRollover = YES;
}

- (void)randomizeNodePosition:(SKSpriteNode *)node {
    CGFloat randomXPosition = [[GameSettings sharedInstance] randomFloatBetween:0.0 andValue:self.viewSize.width];
    CGFloat randomYPosition = [[GameSettings sharedInstance] randomFloatBetween:0.0 andValue:self.viewSize.height];
    [node setPosition:CGPointMake(randomXPosition, randomYPosition)];
}

- (void)rotateNodes {
    [backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *node = (SKSpriteNode *)obj;
        [self rotateNode:node];
    }];
}

- (void)rotateNode:(SKSpriteNode *)node {
    if (self.shouldRotateNodes) {
        SKAction *action = [SKAction rotateByAngle:0.2 duration:100];
        [node runAction:[SKAction repeatActionForever:action]];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    if (lastUpdateTime)
        deltaTime = currentTime - lastUpdateTime;
    else
        deltaTime = 0;

    lastUpdateTime = currentTime;
    
    CGPoint bgVelocity = CGPointMake(0.0, -pointsPerSecondSpeed);
    CGPoint amtToMove = CGPointMake(bgVelocity.x * deltaTime, bgVelocity.y * deltaTime);
    if (pointsPerSecondSpeed > 0)
        [self setPosition:CGPointMake(self.position.x + amtToMove.x, self.position.y + amtToMove.y)];
    SKNode *backgroundScreen = self.parent;

    [backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)obj;
        [self rotateNode:bg];
        CGPoint bgScreenPos = [self convertPoint:bg.position toNode:backgroundScreen];
        if (bgScreenPos.y <= -bg.size.height) {
            bg.position = CGPointMake(bg.position.x, bg.position.y + (bg.size.height * numberOfImagesForBackground));
            if (randomizeDuringRollover)
                [self randomizeNodePosition:bg];
        }
    }];
}

@end

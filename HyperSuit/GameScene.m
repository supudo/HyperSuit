//
//  GameScene.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

@import AVFoundation;
#import "GameScene.h"
#import "ParallaxNode.h"
#import "PixelSpaceship.h"

@interface GameScene()
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval, lastUpdateTimeInterval;
@property (strong) ParallaxNode *pxNebulas;
@property (strong) SKSpriteNode *nodeBackground1, *nodeBackground2, *selectedNode, *playerNode;
@property (strong) NSMutableArray *arrNebulas, *arrShips, *shipLasers;
@property double nextSpawnNebula, nextSpawnShip, gameOverTime;
@property int nextNebula, shipsSpawned, nextShipLaser, playerLives;
@property (nonatomic, strong) AVAudioPlayer *backgroundAudioPlayer;
@property BOOL gameOver;
@end

static NSString *const kSpriteBackground = @"background";
static NSString *const kSpritePlayer = @"player";
static NSString *const kSpriteEnemy = @"enemy";
static NSString *const kSpriteNebula = @"nebula";
static NSString *const kSpriteLabelWinLose = @"winLoseLabel";
static NSString *const kSpriteLabelRestart = @"restartLabel";

static int const kZBackground = -100;
static int const kZPlayer = 100;
static int const kZPlayerLaser = kZPlayer + 1;
static int const kZEnemy = 1;
static int const kZEnemyLaser = kZEnemy + 1;
static int const kZNebula = -99;
static int const kZUI = 1000;

static int const kPlayerLasersMax = 5;

typedef enum : uint32_t {
    TYPE_SUBSPACE       = 1,
    TYPE_WORLD          = 2,
    TYPE_CHILD          = 4
} ColliderTypes;

@implementation GameScene

@synthesize pxNebulas, nodeBackground1, nodeBackground2, arrNebulas, nextSpawnNebula, nextNebula, shipLasers, nextShipLaser;
@synthesize nextSpawnShip, shipsSpawned, arrShips, selectedNode, backgroundAudioPlayer, playerNode;
@synthesize playerLives, gameOverTime, gameOver;

#pragma mark - Init

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.nextSpawnNebula = 0;
        self.nextNebula = 0;
        self.nextSpawnShip = 0;
        self.shipsSpawned = 0;
        
        self.backgroundColor = [SKColor blackColor];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        [self setupStaticBackground];
        //[self setupBackground];
        //[self setupNebulas];
        [self startStars];
        
        self.arrShips = [NSMutableArray array];
        
        [self setupPlayer];
        [self setupPlayerLasers];
        [self setupBackgroundMusic];
        [self startGame];
    }
    return self;
}

#pragma mark - Setups

- (void)startGame {
    self.playerLives = [GameSettings sharedInstance].playerLives;
    double curTime = CACurrentMediaTime();
    self.gameOverTime = curTime + 30.0;
    self.gameOver = NO;

    for (SKSpriteNode *laser in self.shipLasers) {
        [laser setHidden:YES];
    }
    [self startMonitoringAcceleration];
}

- (void)setupPlayer {
    self.playerNode = [SKSpriteNode spriteNodeWithImageNamed:@"player.png"];
    CGPoint pp = CGPointMake(self.size.width / 2, self.playerNode.size.height + 60);
    [self.playerNode setPosition:pp];
    [self.playerNode setZPosition:kZPlayer];
    [self.playerNode setAlpha:1.0];
    [self.playerNode setName:kSpritePlayer];
    [self.playerNode setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:self.playerNode.frame.size]];
    [self.playerNode.physicsBody setDynamic:YES];
    [self.playerNode.physicsBody setAffectedByGravity:NO];
    [self.playerNode.physicsBody setMass:0.02];
    [self addChild:self.playerNode];
}

- (void)setupPlayerLasers {
    self.shipLasers = [[NSMutableArray alloc] initWithCapacity:kPlayerLasersMax];
    for (int i=0; i<kPlayerLasersMax; ++i) {
        SKSpriteNode *shipLaser = [SKSpriteNode spriteNodeWithImageNamed:@"laserbeam_player1"];
        [shipLaser setHidden:YES];
        [self.shipLasers addObject:shipLaser];
        [self addChild:shipLaser];
    }
}

- (void)setupStaticBackground {
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"nebula2.png"];
    [bg setPosition:CGPointMake(self.size.width / 2, self.size.height / 2)];
    [bg setZPosition:kZBackground];
    [bg setAlpha:1.0];
    [bg setName:kSpriteBackground];
    [self addChild:bg];
}

- (void)setupBackground {
    self.nodeBackground1 = [SKSpriteNode spriteNodeWithImageNamed:@"space1"];
    [self.nodeBackground1 setAnchorPoint:CGPointZero];
    [self.nodeBackground1 setPosition:CGPointMake(0, 0)];
    [self.nodeBackground1 setZPosition:-100];
    [self.nodeBackground1 setAlpha:0.9];
    [self.nodeBackground1 setBlendMode:SKBlendModeAdd];
    [self addChild:self.nodeBackground1];
    
    self.nodeBackground2 = [SKSpriteNode spriteNodeWithImageNamed:@"space1"];
    [self.nodeBackground2 setAnchorPoint:CGPointZero];
    [self.nodeBackground2 setPosition:CGPointMake(0, self.nodeBackground1.size.height - 1)];
    [self.nodeBackground2 setZPosition:-100];
    [self.nodeBackground2 setAlpha:0.9];
    [self.nodeBackground2 setBlendMode:SKBlendModeAdd];
    [self addChild:self.nodeBackground2];
}

- (void)setupNebulas {
    int nebulaCount = 15;
    NSMutableArray *an = [NSMutableArray arrayWithCapacity:nebulaCount];
    for (int i=1; i<=nebulaCount; i++)
        [an addObject:[NSString stringWithFormat:@"nebulae%i.png", i]];
    
    CGSize sizeNebulas = CGSizeMake(200.0, 200.0);
    self.pxNebulas = [[ParallaxNode alloc] init:an size:sizeNebulas pointsPerSecondSpeed:100.0 withName:@"nebulae" loadNum:1];
    [self.pxNebulas setViewSize:self.size];
    [self.pxNebulas setPosition:CGPointZero];
    [self.pxNebulas randomizeNodesPositions];
    [self.pxNebulas setShouldRotateNodes:YES];
    [self.pxNebulas setZPosition:kZNebula];
    //[self addChild:self.pxNebulas];
    
    self.arrNebulas = [NSMutableArray arrayWithCapacity:[an count]];
    for (int i=1; i<=[an count]; i++) {
        int idx = [[GameSettings sharedInstance] randomIntBetween:1 andValue:[an count]];
        SKSpriteNode *nebula = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"nebulae%i.png", idx]];
        [nebula setHidden:YES];
        [nebula setXScale:0.5];
        [nebula setYScale:0.5];
        [nebula setAlpha:[[GameSettings sharedInstance] randomFloatBetween:0.2 andValue:0.7]];
        [nebula setBlendMode:SKBlendModeAdd];
        [self.arrNebulas addObject:nebula];
        [self addChild:nebula];
    }
}

- (void)startStars {
    //[self addChild:[self loadEmitterNode:@"nebulas"]];
    //[self addChild:[self loadEmitterNode:@"star1"]];
    //[self addChild:[self loadEmitterNode:@"star2"]];
    
    [self addChild:[self loadEmitterNode:@"Stars"]];
    
    //SKNode *stars = [self loadEmitterNode:@"star1"];
    //[stars setZPosition:-98];
    //[self addChild:stars];
}

- (void)setupBackgroundMusic {
    if (![GameSettings sharedInstance].backgroundMusicEnabled)
        [self.backgroundAudioPlayer stop];
    else {
        NSError *err;
        NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"background_music.caf" ofType:nil]];
        self.backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
        if (err) {
            [[GameSettings sharedInstance] LogThis:@"Background music error - %@", [err userInfo]];
            return;
        }
        [self.backgroundAudioPlayer prepareToPlay];
        [self.backgroundAudioPlayer setNumberOfLoops:-1];
        [self.backgroundAudioPlayer setVolume:1.0];
        [self.backgroundAudioPlayer play];
    }
}

#pragma mark - Timer

- (void)update:(CFTimeInterval)currentTime {
    [self updateBackground];
    //[self.pxNebulas update:currentTime];

    //[self updateShipPositionFromMotionManager];
    
    if (!self.gameOver) {
        double curTime = CACurrentMediaTime();
        if (curTime > nextSpawnNebula && [self.arrNebulas count] > 0) {
            float randSecs = [[GameSettings sharedInstance] randomFloatBetween:0.20 andValue:1.0];
            nextSpawnNebula = randSecs + curTime;
            
            float randX = [[GameSettings sharedInstance] randomFloatBetween:0.0 andValue:self.frame.size.width];
            float randY = [[GameSettings sharedInstance] randomFloatBetween:0.0 andValue:self.frame.size.height];
            float randScale = [[GameSettings sharedInstance] randomFloatBetween:0.1 andValue:1.0];
            float durationMax = 30.0;
            float randDuration = durationMax - [[GameSettings sharedInstance] randomFloatBetween:1.0 andValue:randScale * durationMax];
            float randRotationDuration = [[GameSettings sharedInstance] randomFloatBetween:4.0 andValue:100.0];
            
            SKSpriteNode *nebula = [self.arrNebulas objectAtIndex:nextNebula];
            nextNebula++;
            
            if (nextNebula >= [self.arrNebulas count])
                nextNebula = 0;
            
            randY = self.frame.size.height + nebula.size.height / 2;
            
            [nebula removeAllActions];
            [nebula setPosition:CGPointMake(randX, randY)];
            [nebula setHidden:NO];
            float nebulaAlpha = nebula.alpha;
            [nebula setAlpha:0.0];
            [nebula runAction:[SKAction fadeAlphaTo:nebulaAlpha duration:4.0] withKey:@"showNebula"];
            [nebula setScale:randScale];
            
            SKEffectNode *blur = [[SKEffectNode alloc] init];
            [blur setFilter:[CIFilter filterWithName:kCICategoryBlur]];
            [nebula addChild:blur];

            SKAction *rotation = [SKAction rotateByAngle:(nextNebula % 2 == 0 ? M_PI : -M_PI) duration:randRotationDuration];
            [nebula runAction:[SKAction repeatActionForever:rotation]];
            
            //[[GameSettings sharedInstance] LogThis:@"Spawning nebula %i @ %1.2f - %1.2f", nextNebula, nebula.position.x, nebula.position.y];
            
            CGPoint location = CGPointMake(randX, 0);
            
            SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
            SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
                [nebula runAction:[SKAction fadeOutWithDuration:10.0] withKey:@"hideNebula"];
            }];
            SKAction *moveNebulaActionWithDone = [SKAction sequence:@[moveAction, doneAction]];
            [nebula runAction:moveNebulaActionWithDone withKey:@"nebulaMoving"];
        }

        if (curTime > nextSpawnShip && shipsSpawned < 10) {
            float randSecs = [[GameSettings sharedInstance] randomFloatBetween:2.0 andValue:3.0];
            nextSpawnShip = randSecs + curTime;
            [self generateSpaceship:NO];
        }
        
        for (SKSpriteNode *enemy in self.arrShips) {
            for (SKSpriteNode *shipLaser in self.shipLasers) {
                if ([shipLaser isHidden])
                    continue;

                for (SKSpriteNode *n in [enemy children]) {
                    if ([shipLaser intersectsNode:n]) {
                        if ([GameSettings sharedInstance].backgroundMusicEnabled) {
                            SKAction *enemyExplosionSound = [SKAction playSoundFileNamed:@"explosion_small.caf" waitForCompletion:NO];
                            [enemy runAction:enemyExplosionSound];
                        }
                        [shipLaser setHidden:YES];
                        [self removeEnemy:enemy];
                        continue;
                    }
                }
            }

            BOOL alreadyHit = YES;
            for (SKSpriteNode *n in [enemy children]) {
                CGRect childFrame = CGRectZero;
                CGPoint positionInScene = [self.scene convertPoint:n.position fromNode:enemy];
                childFrame.origin.x = positionInScene.x + (n.size.width / 2);
                childFrame.origin.x = positionInScene.y + (n.size.height / 2);
                childFrame.size.width = n.size.width;
                childFrame.size.height = n.size.height;
                //if ([self.playerNode intersectsNode:n]) {
                //if ([self.playerNode containsPoint:positionInScene]) {
                if (CGRectIntersectsRect(self.playerNode.frame, childFrame)) {
                    if (alreadyHit) {
                        NSLog(@"HIT!!!!!");
                        NSLog(@"%1.2f - %1.2f <----> %1.2f - %1.2f", self.playerNode.frame.origin.x, self.playerNode.frame.origin.y, self.playerNode.frame.size.width, self.playerNode.frame.size.height);
                        //NSLog(@"%1.2f - %1.2f <----> %1.2f - %1.2f", n.frame.origin.x, n.frame.origin.y, n.frame.size.width, n.frame.size.height);
                        NSLog(@"%1.2f - %1.2f <----> %1.2f - %1.2f", childFrame.origin.x, childFrame.origin.y, childFrame.size.width, childFrame.size.height);
                        alreadyHit = NO;
                    }
                    [enemy setHidden:YES];
                    SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.1], [SKAction fadeInWithDuration:0.1]]];
                    SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
                    if ([GameSettings sharedInstance].backgroundMusicEnabled) {
                        SKAction *shipExplosionSound = [SKAction playSoundFileNamed:@"explosion_large.caf" waitForCompletion:NO];
                        [self.playerNode runAction:[SKAction sequence:@[shipExplosionSound, blinkForTime]]];
                    }
                    else
                        [self.playerNode runAction:blinkForTime];
                    self.playerLives--;
                }
            }
        }

        if (self.playerLives <= 0) {
            [[GameSettings sharedInstance] LogThis:@"LOSE!"];
            [self endGame:NO];
        }
        else if (curTime >= self.gameOverTime) {
            [[GameSettings sharedInstance] LogThis:@"WIN!"];
            [self endGame:YES];
        }
    }
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateBackground {
    self.nodeBackground1.position = CGPointMake(self.nodeBackground1.position.x, self.nodeBackground1.position.y - 4);
    self.nodeBackground2.position = CGPointMake(self.nodeBackground2.position.x, self.nodeBackground2.position.y - 4);
    
    if (self.nodeBackground1.position.y < -self.nodeBackground1.size.height)
        self.nodeBackground1.position = CGPointMake(self.nodeBackground2.position.y, self.nodeBackground1.position.y + self.nodeBackground2.size.height);
    
    if (self.nodeBackground2.position.y < -self.nodeBackground2.size.height)
        self.nodeBackground2.position = CGPointMake(self.nodeBackground1.position.y, self.nodeBackground2.position.y + self.nodeBackground1.size.height);
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        //[[GameSettings sharedInstance] LogThis:@"Updating ..."];
    }
}

- (void)endGame:(BOOL)isWin {
    if (self.gameOver)
        return;
    
    [self removeAllActions];
    [self stopMonitoringAcceleration];
    [self.playerNode setHidden:YES];
    self.gameOver = YES;
    
    NSString *message;
    if (isWin)
        message = NSLocalizedString(@"EndGame.Win", @"EndGame.Win");
    else
        message = NSLocalizedString(@"EndGame.Lose", @"EndGame.Lose");
    
    SKLabelNode *label = [[SKLabelNode alloc] initWithFontNamed:[GameSettings sharedInstance].fontName];
    [label setFontSize:18.0];
    [label setName:kSpriteLabelWinLose];
    [label setText:message];
    [label setScale:0.1];
    [label setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height * 0.6)];
    [label setFontColor:[SKColor yellowColor]];
    [label setZPosition:kZUI];
    [self addChild:label];
    
    SKLabelNode *restartLabel = [[SKLabelNode alloc] initWithFontNamed:[GameSettings sharedInstance].fontName];
    [restartLabel setFontSize:18.0];
    [restartLabel setName:kSpriteLabelRestart];
    [restartLabel setText:NSLocalizedString(@"EndGame.PlayAgain", @"EndGame.PlayAgain")];
    [restartLabel setScale:0.5];
    [restartLabel setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height * 0.4)];
    [restartLabel setFontColor:[SKColor yellowColor]];
    [restartLabel setZPosition:kZUI];
    [self addChild:restartLabel];
    
    SKAction *labelScaleAction = [SKAction scaleTo:1.0 duration:0.5];
    [restartLabel runAction:labelScaleAction];
    [label runAction:labelScaleAction];
}

#pragma mark - Emitters

- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName {
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    emitterNode.particlePosition = CGPointMake(self.size.width / 2.0, self.size.height / 2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width, self.size.height);
    return emitterNode;
}

#pragma mark - Spaceships

- (void)generateSpaceship:(BOOL)shouldRotate {
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:shouldRotate], @"shouldRotate", nil];
    [self performSelectorInBackground:@selector(doSpaceship:) withObject:args];
}

- (void)doSpaceship:(NSDictionary *)args {
    BOOL shouldRotate = [[args objectForKey:@"shouldRotate"] boolValue];

    SKSpriteNode *spaceShip = [SKSpriteNode node];

    int shipSize = 12;
    int shipScale = 10;
    //double shipNodeScale = [[GameSettings sharedInstance] randomFloatBetween:0.5 andValue:1.0];
    //double shipNodeScale = [[GameSettings sharedInstance] randomFloatBetween:0.2 andValue:0.8];
    double shipNodeScale = [[GameSettings sharedInstance] randomFloatBetween:1.0 andValue:2.0];
    
    CGRect f = CGRectMake(self.frame.origin.x, self.frame.origin.y, shipSize * shipScale, shipSize * shipScale);
    
    PixelSpaceship *ship = [[PixelSpaceship alloc] init];
    [ship initPixelSpaceship:shipSize withHeight:shipSize withScale:shipScale cellBorder:NO];
    [ship setShipColor:[UIColor darkGrayColor]];
    [ship setContour:NO withColor:[UIColor whiteColor]];
    [ship generateShip];
    [ship setScale:shipNodeScale];
    [ship setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [ship setBlendMode:SKBlendModeAlpha];
    [ship setZPosition:kZEnemy];
    
    NSArray *effectOption1 = [NSArray arrayWithObjects:kCIInputRadiusKey, [NSNumber numberWithInt:10], nil];
    NSArray *effectOption2 = [NSArray arrayWithObjects:kCIInputIntensityKey, [NSNumber numberWithInt:2], nil];
    [ship applyEffect:UIImageEffectBloom withOptions:[NSArray arrayWithObjects:effectOption1, effectOption2, nil]];
    
    [ship drawShip:f];
    
    [spaceShip addChild:ship];
    
    SKSpriteNode *exhaust = [self addShipExhaust:shouldRotate forShip:ship withScale:shipNodeScale];
    [spaceShip addChild:exhaust];
    
    float randDuration = [[GameSettings sharedInstance] randomFloatBetween:10.0 andValue:11.0];

    float randXMin = -(self.view.frame.size.width / 2) + ([ship getWidth] / 2);
    float randXMax = (self.view.frame.size.width / 2) - ([ship getWidth] / 2);
    float randX = [[GameSettings sharedInstance] randomFloatBetween:randXMin andValue:randXMax];
    float randY = (self.frame.size.height / 2) + ([ship getHeight] / 2);
    
    [spaceShip removeAllActions];
    [spaceShip setPosition:CGPointMake(randX, randY)];

    //[[GameSettings sharedInstance] LogThis:@"Spawning spaceship (%i) @ %1.2f - %1.2f", shipsSpawned, spaceShip.position.x, spaceShip.position.y];
    
    CGPoint endPoint = CGPointMake(randX, -(self.frame.size.height / 2 + spaceShip.size.height));
    SKAction *moveAction = [SKAction moveTo:endPoint duration:randDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        [spaceShip removeFromParent];
        shipsSpawned--;
        [self.arrShips removeObject:spaceShip];
        //[[GameSettings sharedInstance] LogThis:@"Removing spaceship (%i) ...", shipsSpawned];
    }];
    [spaceShip runAction:[SKAction sequence:@[moveAction, doneAction]] withKey:@"spaceshipMoving"];

    [spaceShip setUserInteractionEnabled:YES];

    [self addChild:spaceShip];
    [self.arrShips addObject:spaceShip];
    shipsSpawned++;
}

- (SKSpriteNode *)addShipExhaust:(BOOL)shouldRotate forShip:(PixelSpaceship *)ship withScale:(double)shipNodeScale {
    SKSpriteNode *spaceShipExhaust = [SKSpriteNode node];

    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"exhaust"];
    SKTexture *f1 = [atlas textureNamed:@"exhaust1.png"];
    SKTexture *f2 = [atlas textureNamed:@"exhaust2.png"];
    SKTexture *f3 = [atlas textureNamed:@"exhaust3.png"];
    NSArray *exhaustTextures = @[f1, f2, f3];
    [SKTexture preloadTextures:exhaustTextures withCompletionHandler:^(void){}];
    
    CGSize exhaustSize = CGSizeZero;
    exhaustSize = CGSizeMake(f1.size.width * shipNodeScale, f1.size.height * shipNodeScale);
    
    SKSpriteNode *exhaustNode = [SKSpriteNode spriteNodeWithTexture:[exhaustTextures objectAtIndex:0]];
    [exhaustNode setZPosition:-1];
    [exhaustNode setBlendMode:SKBlendModeAlpha];
    [exhaustNode setSize:exhaustSize];
    [exhaustNode setScale:shipNodeScale];
    [exhaustNode setPosition:CGPointMake(ship.position.x, ship.position.y + exhaustSize.height - 30)];
    [spaceShipExhaust addChild:exhaustNode];
    
    SKSpriteNode *exhaustNodeLeft = [SKSpriteNode spriteNodeWithTexture:[exhaustTextures objectAtIndex:0]];
    [exhaustNodeLeft setZPosition:-1];
    [exhaustNodeLeft setBlendMode:SKBlendModeAlpha];
    [exhaustNodeLeft setSize:exhaustSize];
    [exhaustNodeLeft setScale:shipNodeScale];
    [exhaustNodeLeft setPosition:CGPointMake(ship.position.x - 10, ship.position.y + exhaustSize.height - 40)];
    [spaceShipExhaust addChild:exhaustNodeLeft];
    
    SKSpriteNode *exhaustNodeRight = [SKSpriteNode spriteNodeWithTexture:[exhaustTextures objectAtIndex:0]];
    [exhaustNodeRight setZPosition:-1];
    [exhaustNodeRight setBlendMode:SKBlendModeAlpha];
    [exhaustNodeRight setSize:exhaustSize];
    [exhaustNodeRight setScale:shipNodeScale];
    [exhaustNodeRight setPosition:CGPointMake(ship.position.x + 10, ship.position.y + exhaustSize.height - 40)];
    [spaceShipExhaust addChild:exhaustNodeRight];
    
    CGSize ssize = CGSizeMake([ship getWidth], [ship getHeight] + exhaustSize.height);
    [spaceShipExhaust setSize:ssize];
    
    SKAction *exhaustAction = [SKAction animateWithTextures:exhaustTextures timePerFrame:0.01];
    [exhaustNode runAction:[SKAction repeatActionForever:exhaustAction]];
    [exhaustNodeLeft runAction:[SKAction repeatActionForever:exhaustAction]];
    [exhaustNodeRight runAction:[SKAction repeatActionForever:exhaustAction]];
    
    if (shouldRotate) {
        float randRotationDuration = [[GameSettings sharedInstance] randomFloatBetween:1.0 andValue:5.0];
        SKAction *rotation = [SKAction rotateByAngle:M_PI duration:randRotationDuration];
        [spaceShipExhaust runAction:[SKAction repeatActionForever:rotation]];
    }
    
    return spaceShipExhaust;
}

- (void)removeEnemy:(SKSpriteNode *)enemy {
    //[[GameSettings sharedInstance] LogThis:@"remove enemy %@", enemy.name];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        [enemy removeFromParent];
        shipsSpawned--;
        [self.arrShips removeObject:enemy];
    }];
    [enemy runAction:doneAction withKey:@"spaceshipShootDown"];
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual:kSpriteLabelRestart]) {
            [[self childNodeWithName:kSpriteLabelRestart] removeFromParent];
            [[self childNodeWithName:kSpriteLabelWinLose] removeFromParent];
            [self startGame];
            return;
        }
    }

    if (self.gameOver)
        return;
    
    SKSpriteNode *shipLaser = [self.shipLasers objectAtIndex:self.nextShipLaser];
    self.nextShipLaser++;
    if (self.nextShipLaser >= self.shipLasers.count) {
        self.nextShipLaser = 0;
    }
    [shipLaser setPosition:CGPointMake(self.playerNode.position.x + shipLaser.size.width / 2, self.playerNode.position.y + 10)];
    [shipLaser setHidden:NO];
    [shipLaser removeAllActions];
    [shipLaser setZPosition:kZPlayerLaser];
    
    CGPoint location = CGPointMake(self.playerNode.position.x, self.frame.size.height);
    SKAction *laserFireSoundAction = [SKAction playSoundFileNamed:@"laser_ship.caf" waitForCompletion:NO];
    SKAction *laserMoveAction = [SKAction moveTo:location duration:0.5];
    SKAction *laserDoneAction = [SKAction runBlock:(dispatch_block_t)^() {
        [shipLaser setHidden:YES];
    }];
    SKAction *moveLaserActionWithDone = nil;
    if ([GameSettings sharedInstance].backgroundMusicEnabled)
        moveLaserActionWithDone = [SKAction sequence:@[laserFireSoundAction, laserMoveAction, laserDoneAction]];
    else
        moveLaserActionWithDone = [SKAction sequence:@[laserMoveAction, laserDoneAction]];
    [shipLaser runAction:moveLaserActionWithDone withKey:@"laserFired"];

    //UITouch *touch = [touches anyObject];
    //CGPoint positionInScene = [touch locationInNode:self];
    //[self selectNodeForTouch:positionInScene];
}

- (void)selectNodeForTouch:(CGPoint)touchLocation {
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
	if (![self.selectedNode isEqual:touchedNode]) {
		[self.selectedNode removeAllActions];
		[self.selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
		self.selectedNode = touchedNode;
        /*
         if ([[touchedNode name] isEqualToString:kSpritePlayer]) {
         SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:DegToRad(-4.0f) duration:0.1],
         [SKAction rotateByAngle:0.0 duration:0.1],
         [SKAction rotateByAngle:DegToRad(4.0f) duration:0.1]]];
         [selectedNode runAction:[SKAction repeatActionForever:sequence]];
         }
         */
	}
}

- (void)didMoveToView:(SKView *)view {
    //UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    //[[self view] addGestureRecognizer:gestureRecognizer];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self selectNodeForTouch:touchLocation];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (![[self.selectedNode name] isEqualToString:kSpritePlayer]) {
            float scrollDuration = 0.2;
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            CGPoint pos = [self.selectedNode position];
            CGPoint p = Multiply(velocity, scrollDuration);
            
            CGPoint newPos = CGPointMake(pos.x + p.x, pos.y + p.y);
            newPos = [self boundLayerPos:newPos];
            [self.selectedNode removeAllActions];
            
            SKAction *moveTo = [SKAction moveTo:newPos duration:scrollDuration];
            [moveTo setTimingMode:SKActionTimingEaseOut];
            [self.selectedNode runAction:moveTo];
        }
    }
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = self.size;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -[self size].width + winSize.width);
    retval.y = [self position].y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [self.selectedNode position];
    if ([[self.selectedNode name] isEqualToString:kSpritePlayer])
        [self.selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
}

#pragma mark - Motion monitoring

- (void)startMonitoringAcceleration {
    if ([GameSettings sharedInstance].motionManager.accelerometerAvailable)
        [[GameSettings sharedInstance].motionManager startAccelerometerUpdates];
}

- (void)stopMonitoringAcceleration {
    if ([GameSettings sharedInstance].motionManager.accelerometerAvailable && [GameSettings sharedInstance].motionManager.accelerometerActive)
        [[GameSettings sharedInstance].motionManager stopAccelerometerUpdates];
}

- (void)updateShipPositionFromMotionManager {
    CMAccelerometerData *data = [GameSettings sharedInstance].motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        //[self.playerNode.physicsBody applyForce:CGVectorMake(0.0, 40.0 * data.acceleration.x)];
        //[self.playerNode.physicsBody applyForce:CGVectorMake(40.0 * data.acceleration.x, 0.0)];
        [self.playerNode.physicsBody applyForce:CGVectorMake(40.0 * data.acceleration.x, 40.0 * data.acceleration.y)];
        //[self startMotionDetection];
    }
}

- (void)startMotionDetection {
    __block float stepMoveFactor = 15;

    [[GameSettings sharedInstance].motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect rect = self.playerNode.frame;

            float movetoX = rect.origin.x + (data.acceleration.x * stepMoveFactor);
            float maxX = self.scene.frame.size.width - rect.size.width;

            float movetoY = (rect.origin.y + rect.size.height) - (data.acceleration.y * stepMoveFactor);
            float maxY = self.scene.frame.size.height;

            if (movetoX > 0 && movetoX < maxX)
                rect.origin.x += (data.acceleration.x * stepMoveFactor);
            if (movetoY > 0 && movetoY < maxY)
                rect.origin.y -= (data.acceleration.y * stepMoveFactor);

            [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
                NSLog(@"POS - %1.2f - %1.2f", rect.origin.x, rect.origin.y);
                [self.playerNode setPosition:rect.origin];
            }
            completion:nil];
        });
    }];
}

@end

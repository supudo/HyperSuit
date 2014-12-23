//
//  GameCanvas.m
//  HyperSuit
//
//  Created by Sergey Petrov on 1/10/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import "ShipGen.h"
#import "PixelSpaceship.h"

@interface ShipGen ()
@property (nonatomic, strong) NSMutableArray *spaceShips;
@end

@implementation ShipGen

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor redColor];
        if (self.spaceShips == nil)
            self.spaceShips = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)generateSpaceship:(BOOL)shouldRotate {
    NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:shouldRotate], @"shouldRotate", nil];
    [self performSelectorInBackground:@selector(doShip:) withObject:args];
}

- (void)doShip:(NSDictionary *)args {
    [self removeAllChildren];
    [self addSpaceship:[[args objectForKey:@"shouldRotate"] boolValue]];
}

- (void)addSpaceship:(BOOL)shouldRotate {
    SKSpriteNode *spaceShipNode = [SKSpriteNode node];

    int shipSize = 12;
    int shipScale = 10;
    double shipNodeScale = [[GameSettings sharedInstance] randomFloatBetween:0.5 andValue:1.0];
    
    CGRect f = CGRectMake(self.frame.origin.x, self.frame.origin.y, shipSize * shipScale, shipSize * shipScale);

    PixelSpaceship *ship = [[PixelSpaceship alloc] init];
    [ship initPixelSpaceship:shipSize withHeight:shipSize withScale:shipScale cellBorder:NO];
    [ship setShipColor:[UIColor darkGrayColor]];
    [ship setContour:YES withColor:[UIColor whiteColor]];
    [ship generateShip];
    [ship setScale:shipNodeScale];
    [ship setPosition:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
    [ship setBlendMode:SKBlendModeAlpha];
    [ship setZPosition:1];
    
    NSArray *effectOption1 = [NSArray arrayWithObjects:kCIInputRadiusKey, [NSNumber numberWithInt:10], nil];
    NSArray *effectOption2 = [NSArray arrayWithObjects:kCIInputIntensityKey, [NSNumber numberWithInt:2], nil];
    [ship applyEffect:UIImageEffectBloom withOptions:[NSArray arrayWithObjects:effectOption1, effectOption2, nil]];
    
    [ship drawShip:f];
    
    [spaceShipNode addChild:ship];
    
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
    [spaceShipNode addChild:exhaustNode];
    
    SKSpriteNode *exhaustNodeLeft = [SKSpriteNode spriteNodeWithTexture:[exhaustTextures objectAtIndex:0]];
    [exhaustNodeLeft setZPosition:-1];
    [exhaustNodeLeft setBlendMode:SKBlendModeAlpha];
    [exhaustNodeLeft setSize:exhaustSize];
    [exhaustNodeLeft setScale:shipNodeScale];
    [exhaustNodeLeft setPosition:CGPointMake(ship.position.x - 10, ship.position.y + exhaustSize.height - 40)];
    [spaceShipNode addChild:exhaustNodeLeft];
    
    SKSpriteNode *exhaustNodeRight = [SKSpriteNode spriteNodeWithTexture:[exhaustTextures objectAtIndex:0]];
    [exhaustNodeRight setZPosition:-1];
    [exhaustNodeRight setBlendMode:SKBlendModeAlpha];
    [exhaustNodeRight setSize:exhaustSize];
    [exhaustNodeRight setScale:shipNodeScale];
    [exhaustNodeRight setPosition:CGPointMake(ship.position.x + 10, ship.position.y + exhaustSize.height - 40)];
    [spaceShipNode addChild:exhaustNodeRight];
    
    [self addChild:spaceShipNode];

    SKAction *exhaustAction = [SKAction animateWithTextures:exhaustTextures timePerFrame:0.01];
    [exhaustNode runAction:[SKAction repeatActionForever:exhaustAction]];
    [exhaustNodeLeft runAction:[SKAction repeatActionForever:exhaustAction]];
    [exhaustNodeRight runAction:[SKAction repeatActionForever:exhaustAction]];
    
    if (shouldRotate) {
        float randRotationDuration = [[GameSettings sharedInstance] randomFloatBetween:1.0 andValue:5.0];
        SKAction *rotation = [SKAction rotateByAngle:M_PI duration:randRotationDuration];
        [spaceShipNode runAction:[SKAction repeatActionForever:rotation]];
    }
}

@end

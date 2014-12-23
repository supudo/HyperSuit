//
//  PixelSpaceship.h
//  HyperSuit
//
//  Created by Sergey Petrov on 1/10/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import "UIImage+Effect.h"

@interface PixelSpaceship : SKSpriteNode

- (void)initPixelSpaceship:(int)width withHeight:(int)height withScale:(int)scale cellBorder:(BOOL)outline;
- (void)setShipColor:(UIColor *)sc;
- (void)setContour:(BOOL)doContour withColor:(UIColor *)cc;
- (void)setSolidBorder:(BOOL)squareBorder;
- (void)applyEffect:(UIImageEffect)effect withOptions:(NSArray *)effectOptions;
- (void)clearEffects;
- (void)generateShip;
- (void)drawShip:(CGRect)rect;
- (CGFloat)getWidth;
- (CGFloat)getHeight;

@end

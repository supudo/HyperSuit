//
//  UIImage+Effect.h
//  HyperSuit
//
//  Created by Sergey Petrov on 1/23/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Effect)

typedef enum UIImageEffect {
    UIImageEffectNone = 0,
    UIImageEffectSepia,
    UIImageEffectProjectionShadow,
    UIImageEffectBloom,
    UIImageEffectColorInvert,
    UIImageEffectGaussianBlur,
    UIImageEffectPixelate
} UIImageEffect;

- (UIImage *)applyEffects:(NSArray *)effectData;

@end

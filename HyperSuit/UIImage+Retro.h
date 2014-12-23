//
//  UIImage+Retro.h
//  HyperSuit
//
//  Created by Sergey Petrov on 1/24/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Retro)

typedef enum UIImageRetroStyle {
    UIImageRetroStyleNone = 0,
    UIImageRetroStyleSuperMarioBros,
    UIImageRetroStyleFlashMan,
    UIImageRetroStyleHyrule,
    UIImageRetroStyleKungFu,
    UIImageRetroStyleTetris,
    UIImageRetroStyleContra,
    UIImageRetroStyleGrayscale,
    UIImageRetroStyleNES,
    UIImageRetroStyleAppleII,
    UIImageRetroStyleGameboy,
    UIImageRetroStyleCommodore64,
    UIImageRetroStyleIntellivision,
    UIImageRetroStyleSegaMasterSystem,
    UIImageRetroStyleAtari2600
} UIImageRetroStyle;

- (UIImage *)retroize:(int)style;

@end

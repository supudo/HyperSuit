//
//  UIImage+Effect.m
//  HyperSuit
//
//  Created by Sergey Petrov on 1/23/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import "UIImage+Effect.h"

@implementation UIImage (Effect)

- (UIImage *)applyEffects:(NSArray *)effectData {
    UIImage *resultImage = self;
    int effect = [[effectData objectAtIndex:0] intValue];
    NSArray *options = (NSArray *)[effectData objectAtIndex:1];
    switch (effect) {
        case UIImageEffectSepia:
            resultImage = [self effectSepia:resultImage withOptions:options];
            break;
        case UIImageEffectProjectionShadow:
            resultImage = [self effectShadow:resultImage withOptions:options];
            break;
        case UIImageEffectBloom:
            resultImage = [self effectBloom:resultImage withOptions:options];
            break;
        case UIImageEffectColorInvert:
            resultImage = [self effectColorInvert:resultImage withOptions:options];
            break;
        case UIImageEffectGaussianBlur:
            resultImage = [self effectGaussianBlur:resultImage withOptions:options];
            break;
        case UIImageEffectPixelate:
            resultImage = [self effectPixelate:resultImage withOptions:options];
            break;
        default:
            break;
    }
    return resultImage;
}

- (UIImage *)effectPixelate:(UIImage *)originalImage withOptions:(NSArray *)effectOptions {
    CIImage *beginImage = [CIImage imageWithCGImage:[originalImage CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    for (int i=0; i<[effectOptions count]; i++)
        [filter setValue:[[effectOptions objectAtIndex:i] objectAtIndex:1] forKey:[[effectOptions objectAtIndex:i] objectAtIndex:0]];
    //[filter setValue:[NSNumber numberWithInt:3] forKey:@"inputScale"];
    
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    originalImage = newImg;
    
    CGImageRelease(cgimg);
    return originalImage;
}

- (UIImage *)effectGaussianBlur:(UIImage *)originalImage withOptions:(NSArray *)effectOptions {
    CIImage *beginImage = [CIImage imageWithCGImage:[originalImage CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    for (int i=0; i<[effectOptions count]; i++)
        [filter setValue:[[effectOptions objectAtIndex:i] objectAtIndex:1] forKey:[[effectOptions objectAtIndex:i] objectAtIndex:0]];
    //[filter setValue:[NSNumber numberWithInt:2] forKey:@"inputRadius"];
    
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    originalImage = newImg;
    
    CGImageRelease(cgimg);
    return originalImage;
}

- (UIImage *)effectColorInvert:(UIImage *)originalImage withOptions:(NSArray *)effectOptions {
    CIImage *beginImage = [CIImage imageWithCGImage:[originalImage CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorInvert"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    for (int i=0; i<[effectOptions count]; i++)
        [filter setValue:[[effectOptions objectAtIndex:i] objectAtIndex:1] forKey:[[effectOptions objectAtIndex:i] objectAtIndex:0]];
    
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    originalImage = newImg;
    
    CGImageRelease(cgimg);
    return originalImage;
}

- (UIImage *)effectBloom:(UIImage *)originalImage withOptions:(NSArray *)effectOptions {
    CIImage *beginImage = [CIImage imageWithCGImage:[originalImage CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    for (int i=0; i<[effectOptions count]; i++)
        [filter setValue:[[effectOptions objectAtIndex:i] objectAtIndex:1] forKey:[[effectOptions objectAtIndex:i] objectAtIndex:0]];
    //[filter setValue:[NSNumber numberWithInt:30] forKey:kCIInputRadiusKey];
    //[filter setValue:[NSNumber numberWithInt:2] forKey:kCIInputIntensityKey];
    
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    originalImage = newImg;
    
    CGImageRelease(cgimg);
    return originalImage;
}

- (UIImage *)effectSepia:(UIImage *)originalImage withOptions:(NSArray *)effectOptions {
    CIImage *beginImage = [CIImage imageWithCGImage:[originalImage CGImage]];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:beginImage forKey:kCIInputImageKey];
    //[filter setValue:[NSNumber numberWithInt:0.8] forKey:kCIInputIntensityKey];
    for (int i=0; i<[effectOptions count]; i++)
        [filter setValue:[[effectOptions objectAtIndex:i] objectAtIndex:1] forKey:[[effectOptions objectAtIndex:i] objectAtIndex:0]];
    CIImage *outputImage = [filter outputImage];
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    originalImage = newImg;
    
    CGImageRelease(cgimg);
    return originalImage;
}

- (UIImage *)effectShadow:(UIImage *)image withOptions:(NSArray *)effectOptions {
    UIColor *shadowColor = (UIColor *)[effectOptions objectAtIndex:0]; // [UIColor lightGrayColor]
    float blur =  [[effectOptions objectAtIndex:1] floatValue]; // 10.0
    CGPoint offset = [[effectOptions objectAtIndex:2] CGPointValue]; // CGPointMake(0, 10)
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                                       CGImageGetBitsPerComponent(image.CGImage), 0, colourSpace,
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colourSpace);
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(offset.x, offset.y), blur, shadowColor.CGColor);
    
    CGContextDrawImage(shadowContext, CGRectMake(0, 10, image.size.width, image.size.height), image.CGImage);
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGContextRelease(shadowContext);
    
    UIImage *shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

@end

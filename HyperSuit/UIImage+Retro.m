//
//  UIImage+Retro.m
//  HyperSuit
//
//  Created by Sergey Petrov on 1/24/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import "UIImage+Retro.h"

@implementation UIImage (Retro)

- (UIImage *)retroize:(int)style {
    UIImage *resultImage = self;
    
    CGImageRef imageRef = [resultImage CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char *)calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSArray *retroData = [self getColorPalette:style];

    for (int x = 0; x < width; x++) {
        
        for (int y = 0; y < height; y++) {
            
            int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            
            CGFloat red = (rawData[byteIndex] * 1.0);
            CGFloat green = (rawData[byteIndex + 1] * 1.0);
            CGFloat blue = (rawData[byteIndex + 2] * 1.0);
            float fromColor[3] = {red, green, blue};
            
            NSArray *closesColorParts = [self getClosesColor:fromColor pallete:retroData];
            
            rawData[byteIndex] = [[closesColorParts objectAtIndex:0] intValue];
            rawData[byteIndex + 1] = [[closesColorParts objectAtIndex:1] intValue];
            rawData[byteIndex + 2] = [[closesColorParts objectAtIndex:2] intValue];
            rawData[byteIndex + 3] = 255;
            
            byteIndex += 4;
            
        }
        
    }
    
    context = CGBitmapContextCreate(rawData, width, height,
                                    bitsPerComponent, bytesPerRow, colorSpace,
                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    resultImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    
    if (rawData)
        free(rawData);
    
    return resultImage;
}

- (NSArray *)getClosesColor:(float[3])color pallete:(NSArray *)palleteArray {
    float bestScore = MAXFLOAT;
    CGFloat r2 = color[0], g2 = color[1], b2 = color[2];
    for (int i = 0; i<[palleteArray count]; i++) {
        float r = [[[palleteArray objectAtIndex:i] objectAtIndex:0] intValue];
        float g = [[[palleteArray objectAtIndex:i] objectAtIndex:1] intValue];
        float b = [[[palleteArray objectAtIndex:i] objectAtIndex:2] intValue];
        
        CGFloat dR = color[0] - r;
        CGFloat dG = color[1] - g;
        CGFloat dB = color[2] - b;
        
        double distance = sqrtf(dR * dR + dG * dG + dB * dB);
        
        if (distance < bestScore) {
            bestScore = distance;
            
            r2 = r;
            g2 = g;
            b2 = b;
        }
    }
    
    NSMutableArray *cColor = [NSMutableArray array];
    [cColor addObject:[NSNumber numberWithInt:r2]];
    [cColor addObject:[NSNumber numberWithInt:g2]];
    [cColor addObject:[NSNumber numberWithInt:b2]];
    return cColor;
}

- (NSArray *)getColorPalette:(int)style {
    NSMutableArray *dataColors = [NSMutableArray array];
    switch (style) {
        case UIImageRetroStyleSuperMarioBros:
            [[GameSettings sharedInstance] LogThis:@"Style SuperMarioBros"];
            for (int i=0; i < sizeof(dataSuperMarioBros) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataSuperMarioBros[i][0]],
                                       [NSNumber numberWithInt:dataSuperMarioBros[i][1]],
                                       [NSNumber numberWithInt:dataSuperMarioBros[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleFlashMan:
            [[GameSettings sharedInstance] LogThis:@"Style FlashMan"];
            for (int i=0; i < sizeof(dataFlashMan) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataFlashMan[i][0]],
                                       [NSNumber numberWithInt:dataFlashMan[i][1]],
                                       [NSNumber numberWithInt:dataFlashMan[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleHyrule:
            [[GameSettings sharedInstance] LogThis:@"Style Hyrule"];
            for (int i=0; i < sizeof(dataHirule) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataHirule[i][0]],
                                       [NSNumber numberWithInt:dataHirule[i][1]],
                                       [NSNumber numberWithInt:dataHirule[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleKungFu:
            [[GameSettings sharedInstance] LogThis:@"Style KungFu"];
            for (int i=0; i < sizeof(dataKungFu) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataKungFu[i][0]],
                                       [NSNumber numberWithInt:dataKungFu[i][1]],
                                       [NSNumber numberWithInt:dataKungFu[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleTetris:
            [[GameSettings sharedInstance] LogThis:@"Style Tetris"];
            for (int i=0; i < sizeof(dataTetris) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataTetris[i][0]],
                                       [NSNumber numberWithInt:dataTetris[i][1]],
                                       [NSNumber numberWithInt:dataTetris[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleContra:
            [[GameSettings sharedInstance] LogThis:@"Style Contra"];
            for (int i=0; i < sizeof(dataContra) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataContra[i][0]],
                                       [NSNumber numberWithInt:dataContra[i][1]],
                                       [NSNumber numberWithInt:dataContra[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleGrayscale:
            [[GameSettings sharedInstance] LogThis:@"Style Grayscale"];
            for (int i=0; i < sizeof(dataGreyscale) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataGreyscale[i][0]],
                                       [NSNumber numberWithInt:dataGreyscale[i][1]],
                                       [NSNumber numberWithInt:dataGreyscale[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleNES:
            [[GameSettings sharedInstance] LogThis:@"Style NES"];
            for (int i=0; i < sizeof(dataNES) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataNES[i][0]],
                                       [NSNumber numberWithInt:dataNES[i][1]],
                                       [NSNumber numberWithInt:dataNES[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleAppleII:
            [[GameSettings sharedInstance] LogThis:@"Style AppleII"];
            for (int i=0; i < sizeof(dataAppleII) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataAppleII[i][0]],
                                       [NSNumber numberWithInt:dataAppleII[i][1]],
                                       [NSNumber numberWithInt:dataAppleII[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleGameboy:
            [[GameSettings sharedInstance] LogThis:@"Style Gameboy"];
            for (int i=0; i < sizeof(dataGameBoy) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataGameBoy[i][0]],
                                       [NSNumber numberWithInt:dataGameBoy[i][1]],
                                       [NSNumber numberWithInt:dataGameBoy[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleCommodore64:
            [[GameSettings sharedInstance] LogThis:@"Style Commodore64"];
            for (int i=0; i < sizeof(dataCommodore64) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataCommodore64[i][0]],
                                       [NSNumber numberWithInt:dataCommodore64[i][1]],
                                       [NSNumber numberWithInt:dataCommodore64[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleIntellivision:
            [[GameSettings sharedInstance] LogThis:@"Style Intellivision"];
            for (int i=0; i < sizeof(dataIntellivision) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataIntellivision[i][0]],
                                       [NSNumber numberWithInt:dataIntellivision[i][1]],
                                       [NSNumber numberWithInt:dataIntellivision[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleSegaMasterSystem:
            [[GameSettings sharedInstance] LogThis:@"Style SegaMasterSystem"];
            for (int i=0; i < sizeof(dataSegaMasterSystem) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataSegaMasterSystem[i][0]],
                                       [NSNumber numberWithInt:dataSegaMasterSystem[i][1]],
                                       [NSNumber numberWithInt:dataSegaMasterSystem[i][2]],
                                       nil]];
            break;
        case UIImageRetroStyleAtari2600:
            [[GameSettings sharedInstance] LogThis:@"Style Atari2600"];
            for (int i=0; i < sizeof(dataAtari2600) / sizeof(float) / 3; i++)
                [dataColors addObject:[NSArray arrayWithObjects:
                                       [NSNumber numberWithInt:dataAtari2600[i][0]],
                                       [NSNumber numberWithInt:dataAtari2600[i][1]],
                                       [NSNumber numberWithInt:dataAtari2600[i][2]],
                                       nil]];
            break;
        default:
            dataColors = nil;
            break;
    }
    //[[GameSettings sharedInstance] LogThis:@"%@", dataColors];
    return dataColors;
}

float dataSuperMarioBros[10][3] = {
    {146, 144, 255},
    {13,  147, 0},
    {136, 216, 0},
    {107, 109, 0},
    {234, 158, 34},
    {153, 78,  0},
    {255, 204, 197},
    {181, 49,  32},
    {255, 255, 255},
    {0,   0,   0}
};

float dataFlashMan[12][3] = {
    {50,  194, 255},
    {160, 26,  204},
    {20,  18,  167},
    {66,  64,  255},
    {21,  95,  217},
    {100, 176, 255},
    {192, 223, 255},
    {72,  205, 222},
    {228, 229, 148},
    {255, 129, 112},
    {255, 255, 255},
    {0,   0,   0}
};

float dataHirule[12][3] = {
    {66,  64,  255},
    {146, 144, 255},
    {13,  147, 0},
    {136, 216, 0},
    {234, 158, 34},
    {247, 216, 165},
    {153, 78,  0},
    {255, 204, 197},
    {181, 49,  32},
    {255, 255, 255},
    {102, 102, 102},
    {0,   0,   0}
};

float dataKungFu[11][3] = {
    {160, 26,  204},
    {146, 144, 255},
    {192, 223, 255},
    {189, 244, 171},
    {56,  135, 0},
    {136, 216, 0},
    {234, 158, 34},
    {247, 216, 165},
    {181, 49,  32},
    {255, 255, 255},
    {0,   0,   0}
};

float dataTetris[12][3] = {
    {50,  194, 255},
    {160, 26,  204},
    {20,  18,  167},
    {66,  64,  255},
    {21,  95,  217},
    {100, 176, 255},
    {192, 223, 255},
    {72,  205, 222},
    {228, 229, 148},
    {255, 129, 112},
    {255, 255, 255},
    {0,   0,   0}
};

float dataContra[15][3] = {
    {66,  64,  255},
    {21,  95,  217},
    {100, 176, 255},
    {56,  135, 0},
    {136, 216, 0},
    {51,  53,  0},
    {188, 190, 0},
    {107, 109, 0},
    {247, 216, 165},
    {255, 129, 112},
    {255, 204, 197},
    {181, 49,  32},
    {255, 255, 255},
    {173, 173, 173},
    {0,   0,   0}
};

float dataGreyscale[14][3] = {
    {0,   0,   0},
    {20,  20,  20},
    {40,  40,  40},
    {60,  60,  60},
    {80,  80,  80},
    {100, 100, 100},
    {120, 120, 120},
    {140, 140, 140},
    {160, 160, 160},
    {180, 180, 180},
    {200, 200, 200},
    {220, 220, 220},
    {240, 240, 240},
    {255, 255, 255}
};

float dataNES[55][3] = {
    {124, 124, 124},
    {0,   0,   252},
    {0,   0,   188},
    {68,  40,  188},
    {148, 0,   132},
    {168, 0,   32},
    {168, 16,  0},
    {136, 20,  0},
    {80,  48,  0},
    {0,   120, 0},
    {0,   104, 0},
    {0,   88,  0},
    {0,   64,  88},
    {0,   0,   0},
    {188, 188, 188},
    {0,   120, 248},
    {0,   88,  248},
    {104, 68,  252},
    {216, 0,   204},
    {228, 0,   88},
    {248, 56,  0},
    {228, 92,  16},
    {172, 124, 0},
    {0,   184, 0},
    {0,   168, 0},
    {0,   168, 68},
    {0,   136, 136},
    {248, 248, 248},
    {60,  188, 252},
    {104, 136, 252},
    {152, 120, 248},
    {248, 120, 248},
    {248, 88,  152},
    {248, 120, 88},
    {252, 160, 68},
    {248, 184, 0},
    {184, 248, 24},
    {88,  216, 84},
    {88,  248, 152},
    {0,   232, 216},
    {120, 120, 120},
    {252, 252, 252},
    {164, 228, 252},
    {184, 184, 248},
    {216, 184, 248},
    {248, 184, 248},
    {248, 164, 192},
    {240, 208, 176},
    {252, 224, 168},
    {248, 216, 120},
    {216, 248, 120},
    {184, 248, 184},
    {184, 248, 216},
    {0,   252, 252},
    {216, 216, 216},
};

float dataAppleII[15][3] = {
    {0,   0,   0},
    {108, 41,  64},
    {64,  53,  120},
    {217, 60,  240},
    {19,  87,  64},
    {128, 128, 128},
    {38,  151, 240},
    {191, 180, 248},
    {64,  75,  7},
    {217, 104, 15},
    {236, 168, 191},
    {38,  195, 15},
    {191, 202, 135},
    {147, 214, 191},
    {255, 255, 255}
};

float dataGameBoy[4][3] = {
    {15,  56,  15},
    {48,  98,  48},
    {139, 172, 15},
    {155, 188, 15}
};

float dataCommodore64[16][3] = {
    {0,   0,   0},
    {255, 255, 255},
    {136, 57,  50},
    {103, 182, 189},
    {139, 63,  150},
    {85,  160, 73},
    {64,  49,  141},
    {191, 206, 114},
    {139, 84,  41},
    {87,  66,  0},
    {184, 105, 98},
    {80,  80,  80},
    {120, 120, 120},
    {148, 224, 137},
    {120, 105, 196},
    {159, 159, 159}
};

float dataIntellivision[16][3] = {
    {0,   0,   0},
    {164, 150, 255},
    {255, 61,  16},
    {181, 26,  88},
    {84,  110, 0},
    {0,   167, 86},
    {255, 180, 31},
    {201, 207, 171},
    {0,   45,  255},
    {36,  184, 255},
    {255, 78,  87},
    {189, 172, 200},
    {56,  107, 63},
    {117, 204, 128},
    {250, 234, 80},
    {255, 255, 255}
};

float dataSegaMasterSystem[64][3] = {
    {0,   0,   0},
    {85,  0,   0},
    {170, 0,   0},
    {255, 0,   0},
    {0,   0,   85},
    {85,  0,   85},
    {170, 0,   85},
    {255, 0,   85},
    {0,   85,  0},
    {85,  85,  0},
    {170, 85,  0},
    {255, 85,  0},
    {0,   85,  85},
    {85,  85,  85},
    {170, 85,  85},
    {255, 85,  85},
    {0,   170, 0},
    {85,  170, 0},
    {170, 170, 0},
    {255, 170, 0},
    {0,   170, 85},
    {85,  170, 85},
    {170, 170, 85},
    {255, 170, 85},
    {0,   255, 0},
    {85,  255, 0},
    {170, 255, 0},
    {255, 255, 0},
    {0,   255, 85},
    {85,  255, 85},
    {170, 255, 85},
    {255, 255, 85},
    {0,   0,   170},
    {85,  0,   170},
    {170, 0,   170},
    {255, 0,   170},
    {0,   0,   255},
    {85,  0,   255},
    {170, 0,   255},
    {255, 0,   255},
    {0,   85,  170},
    {85,  85,  170},
    {170, 85,  170},
    {255, 85,  170},
    {0,   85,  255},
    {85,  85,  255},
    {170, 85,  255},
    {255, 85,  255},
    {0,   170, 170},
    {85,  170, 170},
    {170, 170, 170},
    {255, 170, 170},
    {0,   170, 255},
    {85,  170, 255},
    {170, 170, 255},
    {255, 170, 255},
    {0,   255, 170},
    {85,  255, 170},
    {170, 255, 170},
    {255, 255, 170},
    {0,   255, 255},
    {85,  255, 255},
    {170, 255, 255},
    {255, 255, 255}
};

float dataAtari2600[128][3] = {
    {0,   0,  0},
    {68,  68, 0},
    {112, 40, 0},
    {132, 24, 0},
    {136, 0,  0},
    {120, 0,  92},
    {72,  0,  120},
    {20,  0,  132},
    {0,   0,  136},
    {0,   24,  124},
    {0,   44,  92},
    {0,   64,  44},
    {0,   60,  0},
    {20,  56,  0},
    {44,  48,  0},
    {68,  40,  0},
    {64,  64,  64},
    {100, 100, 16},
    {132, 68,  20},
    {152, 52,  24},
    {156, 32,  32},
    {140, 32,  116},
    {96,  32,  144},
    {48,  32,  152},
    {28,  32,  156},
    {28,  56,  144},
    {28,  76,  120},
    {28,  92,  72},
    {32,  92,  32},
    {52,  92,  28},
    {76,  80,  28},
    {100, 72,  24},
    {108, 108, 108},
    {132, 132, 36},
    {152, 92,  40},
    {172, 80,  48},
    {176, 60,  60},
    {160, 60,  136},
    {120, 60,  164},
    {76,  60,  172},
    {56,  64,  176},
    {56,  84,  168},
    {56,  104, 144},
    {56,  124, 100},
    {64,  124, 64},
    {80,  124, 56},
    {104, 112, 52},
    {132, 104, 48},
    {144, 144, 144},
    {160, 160, 52},
    {172, 120, 60},
    {192, 104, 72},
    {192, 88,  88},
    {176, 88,  156},
    {140, 88,  184},
    {104, 88,  192},
    {80,  92,  192},
    {80,  112, 188},
    {80,  132, 172},
    {80,  156, 128},
    {92,  156, 92},
    {108, 152, 80},
    {132, 140, 76},
    {160, 132, 68},
    {176, 176, 176},
    {184, 184, 64},
    {188, 140, 76},
    {208, 128, 92},
    {208, 112, 112},
    {192, 112, 176},
    {160, 112, 204},
    {124, 112, 208},
    {104, 116, 208},
    {104, 136, 204},
    {104, 156, 192},
    {104, 180, 148},
    {116, 180, 116},
    {132, 180, 104},
    {156, 168, 100},
    {184, 156, 88},
    {200, 200, 200},
    {208, 208, 80},
    {204, 160, 92},
    {224, 148, 112},
    {224, 136, 136},
    {208, 132, 192},
    {180, 132, 220},
    {148, 136, 224},
    {124, 140, 224},
    {124, 156, 220},
    {124, 180, 212},
    {124, 208, 172},
    {140, 208, 140},
    {156, 204, 124},
    {180, 192, 120},
    {208, 180, 108},
    {220, 220, 220},
    {232, 232, 92},
    {220, 180, 104},
    {236, 168, 128},
    {236, 160, 160},
    {220, 156, 208},
    {196, 156, 236},
    {168, 160, 236},
    {144, 164, 236},
    {144, 180, 236},
    {144, 204, 232},
    {144, 228, 192},
    {164, 228, 164},
    {180, 228, 144},
    {204, 212, 136},
    {232, 204, 124},
    {236, 236, 236},
    {252, 252, 104},
    {232, 204, 124},
    {252, 188, 148},
    {252, 180, 180},
    {236, 176, 224},
    {212, 176, 252},
    {188, 180, 252},
    {164, 184, 252},
    {164, 200, 252},
    {164, 224, 252},
    {164, 252, 212},
    {184, 252, 184},
    {200, 252, 164},
    {224, 236, 156},
    {252, 224, 140}
};

@end

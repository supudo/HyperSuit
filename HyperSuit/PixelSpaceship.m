//
//  PixelSpaceship.m
//  HyperSuit
//
//  Created by Sergey Petrov on 1/10/14.
//  Copyright (c) 2014 supudo.net. All rights reserved.
//

#import "PixelSpaceship.h"

@interface PixelSpaceship() {
    int **shipGrid, **shipGridBorder;
    int scaleFactor;
    int shipWidth, shipHeight, shipWidthBorder, shipHeightBorder, shipBorderExtra;
    BOOL drawBorder, drawContour, drawSquareBorder;
    UIColor *shipColor, *contourColor;
    NSMutableArray *shipData, *shipEffects;
}

typedef enum GridPixelType {
    GridPixelTypeEmpty,
    GridPixelTypeAvoid,
    GridPixelTypeSolid,
    GridPixelTypeCokpt,
    GridPixelTypeBorder
} GridPixelType;

@end

@implementation PixelSpaceship

#pragma mark - Publics

- (void)initPixelSpaceship:(int)width withHeight:(int)height withScale:(int)scale cellBorder:(BOOL)outline {
    drawBorder = outline;
    drawContour = !outline;
    drawSquareBorder = NO;
    
    shipWidth = width;
    shipHeight = height;

    shipBorderExtra = 4;
    shipWidthBorder = width + shipBorderExtra;
    shipHeightBorder = height + shipBorderExtra;
    scaleFactor = scale;
    
    shipGrid = (int **)calloc(shipHeight, sizeof(int *));
    for (int pos = 0; pos < shipHeight; pos++)
        shipGrid[pos] = (int *)calloc(shipWidth, sizeof(int));
    
    shipGridBorder = (int **)calloc(shipHeightBorder, sizeof(int *));
    for (int pos = 0; pos < shipHeightBorder; pos++)
        shipGridBorder[pos] = (int *)calloc(shipWidthBorder, sizeof(int));
    
    shipData = [NSMutableArray array];
    shipEffects = [NSMutableArray array];
    
    shipColor = [UIColor blackColor];
}

- (void)setShipColor:(UIColor *)sc {
    shipColor = sc;
}

- (void)setContour:(BOOL)doContour withColor:(UIColor *)cc {
    drawContour = doContour;
    contourColor = cc;
}

- (void)setSolidBorder:(BOOL)squareBorder {
    drawSquareBorder = squareBorder;
}

- (void)applyEffect:(UIImageEffect)effect withOptions:(NSArray *)effectOptions {
    [shipEffects addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:effect], effectOptions, nil]];
}

- (void)clearEffects {
    [shipEffects removeAllObjects];
}

- (CGFloat)getWidth {
    SKSpriteNode *ship = [self.children objectAtIndex:0];
    return self.xScale * ship.size.width;
}

- (CGFloat)getHeight {
    SKSpriteNode *ship = [self.children objectAtIndex:0];
    return self.yScale * ship.size.height;
}

#pragma mark - Draw

- (void)drawShip:(CGRect)rect {
    int seedColor = 0;
    if ([GameSettings sharedInstance].useMTRandom)
        seedColor = [[GameSettings sharedInstance] randomMTInt];
    else
        seedColor = arc4random();

    float arrSaturation[] = { 40, 60, 80,  100, 80,  60,  80,  100, 120, 100, 80,  60 };
    float arrBrightnes[] =  { 40, 70, 100, 130, 160, 190, 220, 220, 190, 160, 130, 100, 70, 40 };

    CGRect borderRect = rect;
    borderRect.size.width = shipWidthBorder * scaleFactor;
    borderRect.size.height = shipHeightBorder * scaleFactor;
    UIGraphicsBeginImageContext(borderRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    for (int currentRow = 0; currentRow < [shipData count]; currentRow++) {
        NSMutableArray *row = (NSMutableArray *)[shipData objectAtIndex:currentRow];
        for (int currentColumn = 0; currentColumn < [row count]; currentColumn++) {
            int x = currentColumn * scaleFactor;
            int y = currentRow * scaleFactor;
            
            int pixelType = [[row objectAtIndex:currentColumn] intValue];

            UIColor *pColor = [UIColor clearColor];
            if (pixelType == GridPixelTypeSolid)
                pColor = shipColor;
            else if (drawSquareBorder && pixelType == GridPixelTypeBorder)
                pColor = contourColor;
            else {
                if (pixelType == GridPixelTypeAvoid) {
                    float cSaturation = arrSaturation[currentRow];
                    float cBrightness = arrBrightnes[currentColumn];
                    int cHue = 0;
                    if (currentRow < 6)
                        cHue = (seedColor & 0xff00) >> 8;
                    else if (currentRow < 9)
                        cHue = (seedColor & 0xff0000) >> 16;
                    else
                        cHue = (seedColor & 0xff000000) >> 24;
                    
                    pColor = [UIColor colorWithHue:cHue / 255.0 saturation:cSaturation / 255.0 brightness:cBrightness / 255.0 alpha:1.0];
                }
                else if (pixelType == GridPixelTypeCokpt) {
                    float cSaturation = arrSaturation[currentColumn];
                    float cBrightness = arrBrightnes[currentRow] + 40;
                    int cHue = (seedColor & 0xff);
                    
                    pColor = [UIColor colorWithHue:cHue / 255.0 saturation:cSaturation / 255.0 brightness:cBrightness / 255.0 alpha:1.0];
                }
                else
                    pColor = [UIColor clearColor];
            }
            
            CGRect cellRect = CGRectMake(x, y, scaleFactor, scaleFactor);

            CGPathRef path = CGPathCreateWithRect(cellRect, NULL);
            [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] setStroke];
            [pColor setFill];

            CGContextAddPath(ctx, path);
            CGContextDrawPath(ctx, kCGPathFillStroke);
            CGPathRelease(path);
        }
    }

    UIImage *textureImage = nil;

    if (drawContour)
        textureImage = [self contour:UIGraphicsGetImageFromCurrentImageContext()];
    else
        textureImage = UIGraphicsGetImageFromCurrentImageContext();
    
    textureImage = [self applyEffects:textureImage];
    
    CGContextRelease(ctx);
    
    SKTexture *texture = [SKTexture textureWithImage:textureImage];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture];
    [sprite setSize:CGSizeMake(scaleFactor * shipWidthBorder, scaleFactor * shipHeightBorder)];
    [self addChild:sprite];
}

#pragma mark - Contour

- (UIImage *)contour:(UIImage *)originalImage {
    UIImage *resultImage = originalImage;
    
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

    for (int x = 0; x < width; x++) {
        
        for (int y = 0; y < height; y++) {
            
            int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            int byteIndexNext = (bytesPerRow * y) + (x + 1) * bytesPerPixel;
            int byteIndexPrevious = (bytesPerRow * y) + (x - 1) * bytesPerPixel;
            int byteIndexTop = (bytesPerRow * (y + 1)) + x * bytesPerPixel;
            int byteIndexBottom = (bytesPerRow * (y - 1)) + x * bytesPerPixel;
            
            CGFloat alpha = (rawData[byteIndex + 3] * 1.0) / 255.0;

            CGFloat alphaNext = (rawData[byteIndexNext + 3] * 1.0) / 255.0;
            CGFloat alphaPrevious = (rawData[byteIndexPrevious + 3] * 1.0) / 255.0;
            CGFloat alphaTop = (rawData[byteIndexTop + 3] * 1.0) / 255.0;
            CGFloat alphaBottom = (rawData[byteIndexBottom + 3] * 1.0) / 255.0;
            
            if (alpha == 0) {
                if (alphaPrevious == 0 && alphaNext > 0) { // right
                    rawData[byteIndex] = 255;
                    rawData[byteIndex + 1] = 255;
                    rawData[byteIndex + 2] = 255;
                    rawData[byteIndex + 3] = 255;
                }
                else if (alphaPrevious > 0 && alphaNext == 0) { // left
                    rawData[byteIndexPrevious] = 255;
                    rawData[byteIndexPrevious + 1] = 255;
                    rawData[byteIndexPrevious + 2] = 255;
                    rawData[byteIndexPrevious + 3] = 255;
                }
            }
            else {
                if (alphaTop == 0) { // top
                    rawData[byteIndex] = 255;
                    rawData[byteIndex + 1] = 255;
                    rawData[byteIndex + 2] = 255;
                    rawData[byteIndex + 3] = 255;
                }
                else if (alphaBottom == 0) { // bottom
                    rawData[byteIndex] = 255;
                    rawData[byteIndex + 1] = 255;
                    rawData[byteIndex + 2] = 255;
                    rawData[byteIndex + 3] = 255;
                }
            }
            
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

#pragma mark - Effects

- (UIImage *)applyEffects:(UIImage *)originalImage {
    UIImage *resultImage = originalImage;
    if ([shipEffects count] > 0) {
        for (NSArray *effectData in shipEffects)
            resultImage = [originalImage applyEffects:effectData];
    }
    else
        resultImage = originalImage;
    return resultImage;
}

#pragma mark - Generate

- (void)wipeShipGrid {
    for (int r = 0; r < shipHeight; r++)
        for (int c = 0; c < shipWidth; c++)
            shipGrid[r][c] = GridPixelTypeEmpty;
    for (int r = 0; r < shipHeightBorder; r++)
        for (int c = 0; c < shipWidthBorder; c++)
            shipGridBorder[r][c] = GridPixelTypeEmpty;
}

- (void)generateShip {
    [self wipeShipGrid];
    
    int randomSeed = arc4random();
    
    // REQUIRED SOLID CELLS
    int csSolid[] = { 5, 5, 5, 5, 5 };
    int rsSolid[] = { 2, 3, 4, 5, 9 };
    for (int i = 0; i < 5; i++) {
        int c = csSolid[i];
        int r = rsSolid[i];
        shipGrid[r][c] = GridPixelTypeSolid;
    }
    
    // SEED-SPECIFIED BODY CELLS, AVOID OR EMPTY
    int csAvoid[] = { 4, 5, 4, 3, 4, 3, 4, 2, 3, 4, 1, 2, 3, 1, 2, 3, 1, 2, 3, 1, 2, 3, 4, 3,  4,  5  };
    int rsAvoid[] = { 1, 1, 2, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10 };
    int bitmask = 1;
    for (int i = 0; i < 26; i++) {
        int c = csAvoid[i];
        int r = rsAvoid[i];
        shipGrid[r][c] = ((randomSeed & bitmask) != 0) ? GridPixelTypeAvoid : GridPixelTypeEmpty;
        bitmask <<= 1;
    }
    
    // FLIP THE SEED-SPECIFIED COCKPIT CELLS, SOLID OR EMPTY
    int csEmpty[] = { 4, 5, 4, 5, 4, 5 };
    int rsEmpty[] = { 6, 6, 7, 7, 8, 8 };
    bitmask = 1 << 26;
    for (int i = 0; i < 6; i++) {
        int c = csEmpty[i];
        int r = rsEmpty[i];
        shipGrid[r][c] = ((randomSeed & bitmask) != 0) ? GridPixelTypeSolid : GridPixelTypeCokpt;
        bitmask <<= 1;
    }
    
    // SKINNING -- wrap the AVOIDs with SOLIDs where EMPTY
    for (int r = 0; r < shipHeight; r++) {
        for (int c = 0; c < shipWidth; c++) {
            int here = shipGrid[r][c];
            if (here != GridPixelTypeEmpty)
                continue;
            
            BOOL needSolid = NO;
            
            if ((c > 0) && (shipGrid[r][c - 1] == GridPixelTypeAvoid))
                needSolid = YES;
            
            if ((c < shipWidth - 1) && (shipGrid[r][c + 1] == GridPixelTypeAvoid))
                needSolid = YES;
            
            if ((r > 0) && (shipGrid[r - 1][c] == GridPixelTypeAvoid))
                needSolid = YES;
            
            if ((r < shipHeight - 1) && (shipGrid[r + 1][c] == GridPixelTypeAvoid))
                needSolid = YES;
            
            if (needSolid)
                shipGrid[r][c] = GridPixelTypeSolid;
        }
    }
    
    // Mirror left side into right side
    for (int r = 0; r < shipHeight; r++) {
        for (int c = 0; c < shipWidth / 2; c++)
            shipGrid[r][shipWidth - 1 - c] = shipGrid[r][c];
    }
    
    // border data
    for (int r = 0, r2 = shipBorderExtra / 2; r < shipHeight; r++, r2++) {
        for (int c = 0, c2 = shipBorderExtra / 2; c < shipWidth; c++, c2++) {
            shipGridBorder[r2][c2] = shipGrid[r][c];
        }
    }
    
    // border pixel
    for (int r = 0; r < shipHeightBorder; r++) {
        for (int c = 0; c < shipWidthBorder; c++) {
            int here = shipGridBorder[r][c];
            if (here != GridPixelTypeEmpty)
                continue;
            
            BOOL needSolid = NO;
            
            if ((c > 0) && (shipGridBorder[r][c - 1] == GridPixelTypeSolid))
                needSolid = YES;
            
            if ((c < shipWidth - 1) && (shipGridBorder[r][c + 1] == GridPixelTypeSolid))
                needSolid = YES;
            
            if ((r > 0) && (shipGridBorder[r - 1][c] == GridPixelTypeSolid))
                needSolid = YES;
            
            if ((r < shipHeight - 1) && (shipGridBorder[r + 1][c] == GridPixelTypeSolid))
                needSolid = YES;
            
            if (needSolid)
                shipGridBorder[r][c] = GridPixelTypeBorder;
        }
    }
    
    // populate the ship data
    for (int r = 0; r < shipHeightBorder; r++) {
        NSMutableArray *row = [NSMutableArray array];
        for (int c = 0; c < shipWidthBorder; c++)
            [row addObject:[NSNumber numberWithInt:shipGridBorder[r][c]]];
        [shipData addObject:row];
    }
    
    // flip upside-down
    NSUInteger i = 0;
    NSUInteger j = [shipData count] - 1;
    while (i < j) {
        [shipData exchangeObjectAtIndex:i withObjectAtIndex:j];
        i++;
        j--;
    }
    
    /*
     NSMutableString *sb0 = [NSMutableString stringWithFormat:@"\n"];
     for (int r = 0; r < [shipData count]; r++) {
     NSMutableString *sb = [NSMutableString stringWithFormat:@""];
     NSMutableArray *row = (NSMutableArray *)[shipData objectAtIndex:r];
     for (int c = 0; c < [row count]; c++)
     [sb appendFormat:@"%i, ", [[row objectAtIndex:c] intValue]];
     [sb0 appendFormat:@"%@\n", sb];
     }
     [[GameSettings sharedInstance] LogThis:@"%@", sb0];
     */
    
    // free int** memory
    if (shipGrid)
        free(shipGrid);
    
    if (shipGridBorder)
        free(shipGridBorder);
}

@end

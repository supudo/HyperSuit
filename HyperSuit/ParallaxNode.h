//
//  ParallaxNode.h
//  HyperSuit
//
//  Created by Sergey Petrov on 12/3/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

@interface ParallaxNode : SKNode

@property CGSize viewSize;
@property BOOL shouldRotateNodes;

- (instancetype)init:(NSArray *)files size:(CGSize)size pointsPerSecondSpeed:(float)speed withName:(NSString *)pxName loadNum:(int)ln;
- (void)randomizeNodesPositions;
- (void)rotateNodes;
- (void)update:(NSTimeInterval)currentTime;

@end

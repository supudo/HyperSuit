//
//  SokobaniaInAppHelper.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "SNInAppHelper.h"

@implementation SNInAppHelper

+ (SNInAppHelper *)sharedInstance {
    static dispatch_once_t once;
    static SNInAppHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithProductIdentifiers:[GameSettings sharedInstance].storeLevelsIdentifiers];
    });
    return sharedInstance;
}

@end

//
//  URLReader.h
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol URLReaderDelegate <NSObject>
@optional
- (void)urlRequestLevelsDownloaded:(id)sender packs:(NSSet *)levels;
- (void)urlRequestError:(id)sender errorMessage:(NSString *)errorMessage;
@end

@interface URLReader : NSObject {
	id<URLReaderDelegate> __weak delegate;
}

@property (weak) id<URLReaderDelegate> delegate;

@end

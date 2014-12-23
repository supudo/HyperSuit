//
//  URLReader.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "URLReader.h"

@interface URLReader ()
- (void)getFromURL:(NSString *)URL postData:(NSString *)pData postMethod:(NSString *)pMethod;
@property (nonatomic, strong) NSMutableData *responseData;
@end

@implementation URLReader

@synthesize delegate, responseData;

- (void)getFromURL:(NSString *)URL postData:(NSString *)pData postMethod:(NSString *)pMethod {
	NSData *postData = [pData dataUsingEncoding:NSASCIIStringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:URL]];
	[request setHTTPMethod:pMethod];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
	[request setHTTPBody:[pData dataUsingEncoding:NSUTF8StringEncoding]];
	[[GameSettings sharedInstance] LogThis:@"getFromURL method = %@, postData = %@", pMethod, pData];
	
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if ([data length] > 0 && error == nil) {
            NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            [[GameSettings sharedInstance] LogThis:@"getFromURL downloaded = %@", s];
            NSArray *sets = [s componentsSeparatedByString:@"\n"];
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(urlRequestLevelsDownloaded:packs:)])
                [delegate urlRequestLevelsDownloaded:self packs:[[NSSet alloc] initWithArray:sets]];
        }
        else {
            [[GameSettings sharedInstance] LogThis:@"getFromURL error = %@", [error localizedDescription]];
            if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(urlRequestError:errorMessage:)])
                [delegate urlRequestError:self errorMessage:[error localizedDescription]];
        }
    }];
}

- (NSString *)urlCryptedEncode:(NSString *)stringToEncrypt {
	NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
																		   NULL,
																		   (CFStringRef)stringToEncrypt,
																		   NULL,
																		   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																		   kCFStringEncodingUTF8));
	return result;
}

@end

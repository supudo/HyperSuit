//
//  IAPHelper.m
//  HyperSuit
//
//  Created by Sergey Petrov on 11/19/13.
//  Copyright (c) 2013 supudo.net. All rights reserved.
//

#import "IAPHelper.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductDownloadedNotification = @"IAPHelperProductDownloadedNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper {
    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    NSSet *_productIdentifiers;
    NSMutableSet *_purchasedProductIdentifiers;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        _productIdentifiers = productIdentifiers;
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                [[GameSettings sharedInstance] LogThis:@"[InApp] Previously purchased: %@", productIdentifier];
            }
            else
                [[GameSettings sharedInstance] LogThis:@"[InApp] Not purchased: %@", productIdentifier];
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    _completionHandler = [completionHandler copy];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    [[GameSettings sharedInstance] LogThis:@"[InApp] Buying %@...", product.productIdentifier];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    [[GameSettings sharedInstance] LogThis:@"[InApp] Loaded list of products..."];
    _productsRequest = nil;
    NSArray *skProductsInvalid = response.invalidProductIdentifiers;
    for (SKProduct *skProduct in skProductsInvalid)
        [[GameSettings sharedInstance] LogThis:@"[InApp] Invalid product: %@", skProduct];
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts)
        [[GameSettings sharedInstance] LogThis:@"[InApp] Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue];
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [[GameSettings sharedInstance] LogThis:@"[InApp] Failed to load list of products with error - %@", [error localizedDescription]];
    _productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
            case SKDownloadStateActive:
                [[GameSettings sharedInstance] LogThis:@"[InApp] Download progress = %f", download.progress];
                [[GameSettings sharedInstance] LogThis:@"[InApp] Download time = %f", download.timeRemaining];
                break;
            case SKDownloadStateFinished: {
                NSError *error = nil;
                //NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                [[GameSettings sharedInstance] LogThis:@"[InApp] Download documentsDirectory = %@", documentsDirectory];
                
                NSString *source = [download.contentURL relativePath];
                [[GameSettings sharedInstance] LogThis:@"[InApp] Download source = %@", source];
                NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[source stringByAppendingPathComponent:@"ContentInfo.plist"]];
                [[GameSettings sharedInstance] LogThis:@"[InApp] Download dict = %@", dict];
                
                if (![dict objectForKey:@"Files"]) {
                    [[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
                    return;
                }
                
                NSMutableArray *productContentFiles = [NSMutableArray array];
                for (NSString *file in [dict objectForKey:@"Files"]) {
                    [[GameSettings sharedInstance] LogThis:@"[InApp] Download file = %@", file];
                    NSString *content = [[source stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:file];
                    [[GameSettings sharedInstance] LogThis:@"[InApp] Download file content = %@", content];
                    
                    NSString *newLoc = [NSString stringWithFormat:@"%@/%@", documentsDirectory, file];
                    BOOL succeed = [[NSFileManager defaultManager] copyItemAtPath:content toPath:newLoc error:&error];
                    if (error || !succeed)
                        [[GameSettings sharedInstance] LogThis:@"[InApp] Unable to copy file - %@, %@", [error localizedDescription], file];
                    else
                        [productContentFiles addObject:newLoc];
                }
                
                if (download.transaction.transactionState == SKPaymentTransactionStatePurchased)
                    [[GameSettings sharedInstance] LogThis:@"[InApp] Finished"];
                
                [[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductDownloadedNotification object:productContentFiles userInfo:nil];

                break;
            }
            case SKDownloadStateCancelled:
                [[GameSettings sharedInstance] LogThis:@"[InApp] SKDownloadStateCancelled..."];
                break;
            case SKDownloadStateFailed:
                [[GameSettings sharedInstance] LogThis:@"[InApp] SKDownloadStateFailed..."];
                break;
            case SKDownloadStatePaused:
                [[GameSettings sharedInstance] LogThis:@"[InApp] SKDownloadStatePaused..."];
                break;
            case SKDownloadStateWaiting:
                [[GameSettings sharedInstance] LogThis:@"[InApp] SKDownloadStateWaiting..."];
                break;
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[GameSettings sharedInstance] LogThis:@"[InApp] completeTransaction..."];
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    if (transaction.downloads)
        [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
    else
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[GameSettings sharedInstance] LogThis:@"[InApp] restoreTransaction..."];
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [[GameSettings sharedInstance] LogThis:@"[InApp] failedTransaction..."];
    if (transaction.error.code != SKErrorPaymentCancelled)
        [[GameSettings sharedInstance] LogThis:@"[InApp] Transaction error: %@", transaction.error.localizedDescription];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end

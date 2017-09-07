//
//  ANXZBar.h
//  ZBar
//
//  Created by Max Rozdobudko on 9/5/17.
//  Copyright © 2017 Max Rozdobudko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBarSDK.h"
#import "FlashRuntimeExtensions.h"

typedef void (^ANXZBarScanCompletion)(NSError* error, NSArray<__kindof NSString*>* result);

@interface ANXZBar : NSObject

#pragma mark Shared Instance

+ (ANXZBar*)sharedInstance;

//#pragma mark Properties
//
//@property (readonly, nonatomic) ZBarImageScanner *scanner;

#pragma mark Scan

- (void)setDisabledCopyingBitmapData:(BOOL)disableCopyingBitmapData;

- (void)scanBitmapData:(FREObject)bmd withCompletion:(ANXZBarScanCompletion)completion;
- (void)testScanBitmapData:(FREObject)bmd withCompletion:(ANXZBarScanCompletion)completion;
- (FREObject)scanBitmapData:(FREObject)bmd;

@end

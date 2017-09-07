//
//  ANXZBar.m
//  ZBar
//
//  Created by Max Rozdobudko on 9/5/17.
//  Copyright © 2017 Max Rozdobudko. All rights reserved.
//

#import "ANXZBar.h"
#import "ZBarSDK.h"

@implementation ANXZBar {
    ZBarImageScanner *_scanner;
}

#pragma mark Shared instance

static ANXZBar* _sharedInstance = nil;

+ (ANXZBar*)sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[super allocWithZone:NULL] init];
    }
    return _sharedInstance;
}

#pragma mark Initializers

-(id) init {
    self = [super init];
    _scanner = [[ZBarImageScanner alloc] init];
//    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_X_DENSITY to:1];
//    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_Y_DENSITY to:1];
//    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_ENABLE    to:0];
//    [_scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE    to:1];
    return self;
}

#pragma mark Properties



#pragma mark Methods

- (void)scanBitmapData:(FREObject)bmd withCompletion:(ANXZBarScanCompletion)completion {
    NSLog(@"ANXZBar: Start scan BitmapData");
    
    FREBitmapData2 bitmapData;
    FREAcquireBitmapData2(bmd, &bitmapData);
    
    int width       = bitmapData.width;
    int height      = bitmapData.height;
    
    uint32_t *bits  = malloc(width * height * sizeof(uint32_t));
    memcpy(bits, bitmapData.bits32, (width * height * sizeof(uint32_t)));
    
    CGBitmapInfo bitmapInfo;
    if (bitmapData.hasAlpha) {
        if (bitmapData.isPremultiplied) {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        } else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        }
    } else {
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    }
    
    FREReleaseBitmapData(bmd);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bits, (width * height * 4), NULL);
        int                     bitsPerComponent    = 8;
        int                     bitsPerPixel        = 32;
        int                     bytesPerRow         = 4 * width;
        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef              imageRef            = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        
        ZBarImage* imgToScan = [[ZBarImage alloc] initWithCGImage:imageRef];
        NSInteger resultCount = [_scanner scanImage:imgToScan];
        imgToScan = nil;
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        
        if (resultCount > 0){
            NSLog(@"ANXZbar: Found some barcodes.");
            ZBarSymbolSet* results = [_scanner results];
            NSMutableArray* codes = [NSMutableArray arrayWithCapacity:resultCount];
            for(ZBarSymbol *symbol in results) {
                [codes addObject:symbol.data];
            }
            if (completion) {
                completion(nil, [codes copy]);
            }
        } else {
            NSLog(@"ANXZBar: No barcodes found.");
            if (completion) {
                completion(nil, @[]);
            }
        }
        
        free(bits);
    });
}

@end

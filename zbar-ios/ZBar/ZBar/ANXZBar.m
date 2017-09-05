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
    dispatch_queue_t zbar_scan_bitmapdata_queue;
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
    zbar_scan_bitmapdata_queue = dispatch_queue_create("com.github.airext.zbar.ScanBitmapDataQueue", DISPATCH_QUEUE_CONCURRENT);
    _scanner = [[ZBarImageScanner alloc] init];
    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_X_DENSITY to:1];
    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_Y_DENSITY to:1];
    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_ENABLE    to:0];
    [_scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE    to:1];
    return self;
}

- (void)scanBitmapData:(FREObject)bmd withCompletion:(ANXZBarScanCompletion)completion {
    
    NSLog(@"ANXZBar.scanBitmapData 1");
    
    FREBitmapData2  bitmapData;
    
    FREAcquireBitmapData2(bmd, &bitmapData);
    
    int width       = bitmapData.width;
    int height      = bitmapData.height;
    
    NSLog(@"ANXZBar.scanBitmapData 2");
    
//    uint32_t* bits = NULL;
//    memcpy(bits, bitmapData.bits32, sizeof(uint32_t) * width * height);

    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (width * height * 4), NULL);
    
    FREReleaseBitmapData(bmd);
    
    NSLog(@"ANXZBar.scanBitmapData 3");
    
    dispatch_async(zbar_scan_bitmapdata_queue, ^{
        
        NSLog(@"ANXZBar.scanBitmapData 4");
        
        int                     bitsPerComponent    = 8;
        int                     bitsPerPixel        = 32;
        int                     bytesPerRow         = 4 * width;
        CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo            bitmapInfo;
        
        if (bitmapData.hasAlpha) {
            if (bitmapData.isPremultiplied) {
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            } else {
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
            }
        } else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
        }
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef cgImage                          = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        ZBarImage *zbarImage                        = [[ZBarImage alloc] initWithCGImage:cgImage];

        NSLog(@"ANXZBar.scanBitmapData 5");

        NSInteger foundCodesCount = 0;//[_scanner scanImage:zbarImage];
        if (foundCodesCount > 0) {
            NSLog(@"ANXZBar.scanBitmapData 5.1");
            ZBarSymbolSet* symbols = [_scanner results];
            NSMutableArray* codes = [NSMutableArray arrayWithCapacity:foundCodesCount];
            for (ZBarSymbol *symbol in symbols) {
                [codes addObject:symbol.data];
            }
            if (completion) {
                completion(nil, [codes copy]);
            }
        } else {
            NSLog(@"ANXZBar.scanBitmapData 5.2");
            if (completion) {
                completion(nil, @[]);
            }
        }
        
        [zbarImage cleanup];
        
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(cgImage);
        CGDataProviderRelease(provider);
        
        if (completion) {
            completion(nil, @[]);
        }
        
        NSLog(@"ANXZBar.scanBitmapData 6");
    });
}

@end

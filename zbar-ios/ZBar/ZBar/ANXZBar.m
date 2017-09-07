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
    BOOL _disabledCopyingBitmapData;
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
    _disabledCopyingBitmapData = YES;
//    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_X_DENSITY to:1];
//    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_Y_DENSITY to:1];
//    [_scanner setSymbology:ZBAR_NONE   config:ZBAR_CFG_ENABLE    to:0];
//    [_scanner setSymbology:ZBAR_QRCODE config:ZBAR_CFG_ENABLE    to:1];
    return self;
}

#pragma mark Properties

- (void)setDisabledCopyingBitmapData:(BOOL)disableCopyingBitmapData {
    _disabledCopyingBitmapData = disableCopyingBitmapData;
}

#pragma mark Methods

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
        
        if( bitmapData.hasAlpha) {
            if(bitmapData.isPremultiplied)
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
            else
                bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        } else {
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
        }
        
        CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
        CGImageRef              imageRef            = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        
        ZBarImage* imgToScan = [[ZBarImage alloc] initWithCGImage:imageRef];
        NSInteger resultCount = [_scanner scanImage:imgToScan];
        imgToScan = nil;
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        
        if (resultCount > 0){
            ZBarSymbolSet* results = [_scanner results];
            NSLog(@"Found barcodes!");
            ZBarSymbol *sym = nil;
            NSMutableArray* codes = [NSMutableArray arrayWithCapacity:resultCount];
            for(sym in results) {
                [codes addObject:sym.data];
            }
            if (completion) {
                completion(nil, [codes copy]);
            }
        } else {
            if (completion) {
                completion(nil, @[]);
            }
        }
        
        NSLog(@"ANXZBar.scanBitmapData 6");
    });
}

- (FREObject)scanBitmapData:(FREObject)bmd {
    
    FREObject retVal = NULL;
    
    FREObject       objectBitmapData = bmd;
    FREBitmapData2  bitmapData;
    
    FREAcquireBitmapData2(objectBitmapData, &bitmapData);
    
    int width       = bitmapData.width;
    int height      = bitmapData.height;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData.bits32, (width * height * 4), NULL);
    
    int                     bitsPerComponent    = 8;
    int                     bitsPerPixel        = 32;
    int                     bytesPerRow         = 4 * width;
    CGColorSpaceRef         colorSpaceRef       = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo            bitmapInfo;
    
    if( bitmapData.hasAlpha) {
        if(bitmapData.isPremultiplied)
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
        else
            bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
    } else {
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    }
    
    CGColorRenderingIntent  renderingIntent     = kCGRenderingIntentDefault;
    CGImageRef              imageRef            = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    ZBarImage* imgToScan = [[ZBarImage alloc] initWithCGImage:imageRef];
    NSInteger resultCount = [_scanner scanImage:imgToScan];
    imgToScan = nil;
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    FREReleaseBitmapData(objectBitmapData);
    
    if(resultCount > 0){
        ZBarSymbolSet* results = [_scanner results];
        NSLog(@"Found barcodes!");
        ZBarSymbol *sym = nil;
        FREObject exception;
        FRENewObject((uint8_t*)"Array", 0, nil, &retVal, &exception);
        for(sym in results) {
            if (sym) {
                NSLog(@"Found barcode! quality: %d string: %@", sym.quality, sym.data);
                FREObject strToAdd;
                FRENewObjectFromUTF8((uint32_t)sym.data.length, (uint8_t*)[sym.data UTF8String], &strToAdd);
                FRECallObjectMethod(retVal, (uint8_t*)"push", 1, &strToAdd, &exception, &exception);
            }
        }
    }
    
    return retVal;
}

- (void)testScanBitmapData:(FREObject)bmd withCompletion:(ANXZBarScanCompletion)completion {
    NSLog(@"ANXZBar.testScanBitmapData 1");
    
    FREBitmapData2 bitmapData;
    FREAcquireBitmapData2(bmd, &bitmapData);
    
    int width       = bitmapData.width;
    int height      = bitmapData.height;
    
    uint32_t *bits = NULL;
    
    if (_disabledCopyingBitmapData) {
        bits = bitmapData.bits32;
    } else {
        uint32_t* bits = malloc(width * height * 4);
        memcpy(bits, bitmapData.bits32, width * height * 4);
    }
    
    bitmapData.bits32 = bits;

    NSLog(@"ANXZBar.testScanBitmapData 2");
    
    FREReleaseBitmapData(bmd);
    
    NSLog(@"ANXZBar.testScanBitmapData 3");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//    dispatch_async(zbar_scan_bitmapdata_queue, ^{
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bits, (width * height * 4), NULL);
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
        CGImageRef              imageRef            = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
        
    
        NSLog(@"ANXZBar.testScanBitmapData 4");
        
        NSLog(@"ANXZBar.testScanBitmapData 5, %i, %i", width, height);
        
        ZBarImage* imgToScan = [[ZBarImage alloc] initWithCGImage:imageRef];
        NSLog(@"ANXZBar.testScanBitmapData 5.1");
        NSInteger resultCount = [_scanner scanImage:imgToScan];
        NSLog(@"ANXZBar.testScanBitmapData 5.2");
        imgToScan = nil;
        CGColorSpaceRelease(colorSpaceRef);
        NSLog(@"ANXZBar.testScanBitmapData 5.3");
        CGImageRelease(imageRef);
        NSLog(@"ANXZBar.testScanBitmapData 5.4");
        CGDataProviderRelease(provider);
        
        if (resultCount > 0){
            NSLog(@"ANXZBar.testScanBitmapData 5.5");
            ZBarSymbolSet* results = [_scanner results];
            NSLog(@"Found barcodes!");
            ZBarSymbol *sym = nil;
            NSMutableArray* codes = [NSMutableArray arrayWithCapacity:resultCount];
            for(sym in results) {
                [codes addObject:sym.data];
            }
            if (completion) {
                completion(nil, [codes copy]);
            }
        } else {
            NSLog(@"ANXZBar.testScanBitmapData 5.6");
            if (completion) {
                completion(nil, @[]);
            }
        }
        
        NSLog(@"ANXZBar.testScanBitmapData 6");
//        NSLog(@"ANXZBar.FREReleaseBitmapData: %i", FREReleaseBitmapData(bmd));
//    });
    });
}

@end

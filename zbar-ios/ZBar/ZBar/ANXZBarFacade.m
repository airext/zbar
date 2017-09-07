//
//  ANXZBarFacade.m
//  ANXZBarFacade
//
//  Created by Max Rozdobudko on 9/5/17.
//  Copyright © 2017 Max Rozdobudko. All rights reserved.
//

#import "ANXZBarFacade.h"
#import "FlashRuntimeExtensions.h"
#import "ANXZBarConversionRoutines.h"
#import "ANXBridge.h"
#import "ANXZBar.h"

@implementation ANXZBarFacade

@end

#pragma mark API

FREObject ANXZBarIsSupported(FREContext context, void* functionData, uint32_t argc, FREObject argv[]){
    NSLog(@"ANXZBarIsSupported");
    return [ANXZBarConversionRoutines convertBoolToFREObject: YES];
}

FREObject ANXZBarScan(FREContext context, void* functionData, uint32_t argc, FREObject argv[]) {
    ANXBridgeCall* call = [ANXBridge call:context];
    
    NSLog(@"ANXZBarScan");
    
    [[ANXZBar sharedInstance] scanBitmapData:argv[0] withCompletion:^(NSError *error, NSArray<__kindof NSString *> *result) {
        if (error) {
            [call reject:error];
        } else {
            [call result:result];
        }
    }];
    
    return [call toFREObject];
}

#pragma mark ContextInitialize/ContextFinalizer

void ANXZBarContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
    
    *numFunctionsToSet = 2;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToSet));
    
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &ANXZBarIsSupported;
    
    func[1].name = (const uint8_t*) "scan";
    func[1].functionData = NULL;
    func[1].function = &ANXZBarScan;
    
    [ANXBridge setup:numFunctionsToSet functions:&func];
    
    *functionsToSet = func;
}

void ANXZBarContextFinalizer(FREContext ctx){
    NSLog(@"ANXZBarContextFinalizer");
}

#pragma mark Initializer/Finalizer

void ANXZBarInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) {
    NSLog(@"ANXZBarInitializer");
    
    *extDataToSet = NULL;
    
    *ctxInitializerToSet = &ANXZBarContextInitializer;
    *ctxFinalizerToSet = &ANXZBarContextFinalizer;
}

void ANXZBarFinalizer(void* extData) {
    NSLog(@"ANXZBarFinalizer");
}

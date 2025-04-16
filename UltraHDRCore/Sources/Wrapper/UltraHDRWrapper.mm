#import <Foundation/Foundation.h>
#import "UltraHDRWrapperObjC.h"
#include "UltraHDRWrapper.h"

@implementation UltraHDRWrapperObjC {
    UltraHDRWrapper* _wrapper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _wrapper = new UltraHDRWrapper();
    }
    return self;
}

- (void)dealloc {
    delete _wrapper;
}

- (BOOL)encodeFromHDROnly:(NSData *)hdrData
                    width:(NSInteger)width
                   height:(NSInteger)height
           hdrPixelFormat:(NSInteger)hdrPixelFormat
                  quality:(NSInteger)quality
                   output:(NSMutableData **)output {
    
    std::vector<uint8_t> outputData;
    BOOL result = _wrapper->encodeFromHDROnly(
        hdrData.bytes, hdrData.length,
        (int)width, (int)height, (int)hdrPixelFormat,
        (int)quality, outputData);
    
    if (result) {
        *output = [NSMutableData dataWithBytes:outputData.data() length:outputData.size()];
    }
    
    return result;
}

- (BOOL)encodeFromHDRAndSDR:(NSData *)hdrData
             hdrPixelFormat:(NSInteger)hdrPixelFormat
                    sdrData:(NSData *)sdrData
             sdrPixelFormat:(NSInteger)sdrPixelFormat
                      width:(NSInteger)width
                     height:(NSInteger)height
                    quality:(NSInteger)quality
                     output:(NSMutableData **)output {
    
    std::vector<uint8_t> outputData;
    BOOL result = _wrapper->encodeFromHDRAndSDR(
        hdrData.bytes, hdrData.length, (int)hdrPixelFormat,
        sdrData.bytes, sdrData.length, (int)sdrPixelFormat,
        (int)width, (int)height, (int)quality, outputData);
    
    if (result) {
        *output = [NSMutableData dataWithBytes:outputData.data() length:outputData.size()];
    }
    
    return result;
}

- (BOOL)encodeFromHDRAndCompressedSDR:(NSData *)hdrData
                       hdrPixelFormat:(NSInteger)hdrPixelFormat
                          sdrJpegData:(NSData *)sdrJpegData
                                width:(NSInteger)width
                               height:(NSInteger)height
                               output:(NSMutableData **)output {
    
    std::vector<uint8_t> outputData;
    BOOL result = _wrapper->encodeFromHDRAndCompressedSDR(
        hdrData.bytes, hdrData.length, (int)hdrPixelFormat,
        sdrJpegData.bytes, sdrJpegData.length,
        (int)width, (int)height, outputData);
    
    if (result) {
        *output = [NSMutableData dataWithBytes:outputData.data() length:outputData.size()];
    }
    
    return result;
}

- (BOOL)encodeFromCompressedSDRAndGainmap:(NSData *)sdrJpegData
                          gainmapJpegData:(NSData *)gainmapJpegData
                                   output:(NSMutableData **)output {
    
    std::vector<uint8_t> outputData;
    BOOL result = _wrapper->encodeFromCompressedSDRAndGainmap(
        sdrJpegData.bytes, sdrJpegData.length,
        gainmapJpegData.bytes, gainmapJpegData.length,
        outputData);
    
    if (result) {
        *output = [NSMutableData dataWithBytes:outputData.data() length:outputData.size()];
    }
    
    return result;
}

- (BOOL)decodeToHDR:(NSData *)jpegrData
   outputPixelFormat:(NSInteger)outputPixelFormat
          maxDisplay:(float)maxDisplayBoost
              output:(NSMutableData **)output
               width:(NSInteger *)width
              height:(NSInteger *)height {
    
    void* outputData = NULL;
    size_t outputDataSize = 0;
    int outWidth = 0, outHeight = 0;
    
    BOOL result = _wrapper->decodeToHDR(
        jpegrData.bytes, jpegrData.length,
        outputData, outputDataSize,
        outWidth, outHeight, (int)outputPixelFormat,
        maxDisplayBoost);
    
    if (result) {
        *output = [NSMutableData dataWithBytesNoCopy:outputData
                                              length:outputDataSize
                                         freeWhenDone:YES];
        *width = outWidth;
        *height = outHeight;
    }
    
    return result;
}

- (BOOL)isUltraHDRImage:(NSData *)jpegData {
    return _wrapper->isUltraHDRImage(jpegData.bytes, jpegData.length);
}

- (NSString *)lastError {
    return [NSString stringWithUTF8String:_wrapper->getLastError()];
}

@end 
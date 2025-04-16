#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Objective-C wrapper for the UltraHDR library.
 * Provides methods to encode and decode UltraHDR images.
 */
@interface UltraHDRWrapperObjC : NSObject

// Encoding methods

/**
 * Encodes an HDR image to UltraHDR format by generating an SDR image and gain map internally.
 *
 * @param hdrData The raw HDR image data
 * @param width The width of the image
 * @param height The height of the image
 * @param hdrPixelFormat The pixel format of the HDR image (see UltraHDRPixelFormat)
 * @param quality The JPEG quality for compression (0-100)
 * @param output On success, contains the encoded UltraHDR image data
 * @return YES if encoding succeeded, NO otherwise
 */
- (BOOL)encodeFromHDROnly:(NSData *)hdrData
                    width:(NSInteger)width
                   height:(NSInteger)height
           hdrPixelFormat:(NSInteger)hdrPixelFormat
                  quality:(NSInteger)quality
                   output:(NSMutableData **)output;

/**
 * Encodes HDR and SDR raw images to UltraHDR format.
 *
 * @param hdrData The raw HDR image data
 * @param hdrPixelFormat The pixel format of the HDR image (see UltraHDRPixelFormat)
 * @param sdrData The raw SDR image data
 * @param sdrPixelFormat The pixel format of the SDR image (see UltraHDRPixelFormat)
 * @param width The width of the image
 * @param height The height of the image
 * @param quality The JPEG quality for compression (0-100)
 * @param output On success, contains the encoded UltraHDR image data
 * @return YES if encoding succeeded, NO otherwise
 */
- (BOOL)encodeFromHDRAndSDR:(NSData *)hdrData
             hdrPixelFormat:(NSInteger)hdrPixelFormat
                    sdrData:(NSData *)sdrData
             sdrPixelFormat:(NSInteger)sdrPixelFormat
                      width:(NSInteger)width
                     height:(NSInteger)height
                    quality:(NSInteger)quality
                     output:(NSMutableData **)output;

/**
 * Encodes HDR raw and SDR compressed (JPEG) images to UltraHDR format.
 *
 * @param hdrData The raw HDR image data
 * @param hdrPixelFormat The pixel format of the HDR image (see UltraHDRPixelFormat)
 * @param sdrJpegData The compressed JPEG SDR image data
 * @param width The width of the image
 * @param height The height of the image
 * @param output On success, contains the encoded UltraHDR image data
 * @return YES if encoding succeeded, NO otherwise
 */
- (BOOL)encodeFromHDRAndCompressedSDR:(NSData *)hdrData
                       hdrPixelFormat:(NSInteger)hdrPixelFormat
                          sdrJpegData:(NSData *)sdrJpegData
                                width:(NSInteger)width
                               height:(NSInteger)height
                               output:(NSMutableData **)output;

/**
 * Encodes compressed SDR (JPEG) and gain map images to UltraHDR format.
 *
 * @param sdrJpegData The compressed JPEG SDR image data
 * @param gainmapJpegData The compressed JPEG gain map image data
 * @param output On success, contains the encoded UltraHDR image data
 * @return YES if encoding succeeded, NO otherwise
 */
- (BOOL)encodeFromCompressedSDRAndGainmap:(NSData *)sdrJpegData
                          gainmapJpegData:(NSData *)gainmapJpegData
                                   output:(NSMutableData **)output;

// Decoding methods

/**
 * Decodes an UltraHDR image to HDR format.
 *
 * @param jpegrData The UltraHDR image data
 * @param outputPixelFormat The desired output pixel format (see UltraHDRPixelFormat)
 * @param maxDisplayBoost The maximum display boost (>= 1.0)
 * @param output On success, contains the decoded HDR image data
 * @param width On success, contains the width of the decoded image
 * @param height On success, contains the height of the decoded image
 * @return YES if decoding succeeded, NO otherwise
 */
- (BOOL)decodeToHDR:(NSData *)jpegrData
   outputPixelFormat:(NSInteger)outputPixelFormat
          maxDisplay:(float)maxDisplayBoost
              output:(NSMutableData **)output
               width:(NSInteger *)width
              height:(NSInteger *)height;

// Utility methods

/**
 * Checks if an image is an UltraHDR image.
 *
 * @param jpegData The JPEG image data to check
 * @return YES if the image is an UltraHDR image, NO otherwise
 */
- (BOOL)isUltraHDRImage:(NSData *)jpegData;

/**
 * Returns the last error message from the UltraHDR library.
 *
 * @return The last error message
 */
- (NSString *)lastError;

@end

// Constants for pixel formats (match UltraHDRPixelFormat in C++ code)
typedef NS_ENUM(NSInteger, UltraHDRPixelFormat) {
    UltraHDRPixelFormatRGBA8888 = 0,
    UltraHDRPixelFormatRGBA1010102 = 1,
    UltraHDRPixelFormatRGBAF16 = 2,
    UltraHDRPixelFormatYUV420 = 3,
    UltraHDRPixelFormatP010 = 4
};

NS_ASSUME_NONNULL_END 
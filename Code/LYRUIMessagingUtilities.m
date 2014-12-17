//
//  LYRUIMessagingUtilities.m
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIMessagingUtilities.h"

NSString *const LYRUIMIMETypeTextPlain = @"text/plain";
NSString *const LYRUIMIMETypeTextHTML = @"text/HTML";
NSString *const LYRUIMIMETypeImagePNG = @"image/png";
NSString *const LYRUIMIMETypeImageJPEG = @"image/jpeg";
NSString *const LYRUIMIMETypeLocation = @"location/coordinate";
NSString *const LYRUIMIMETypeDate = @"text/date";

CGFloat LYRUIMaxCellWidth()
{
    return 220;
}

CGFloat LYRUIMaxCellHeight()
{
    return 300;
}

CGSize LYRUITextPlainSize(NSString *text, UIFont *font)
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(LYRUIMaxCellWidth(), CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil];
    return rect.size;
}

CGSize LYRUIImageSize(UIImage *image)
{
    CGSize maxSize = CGSizeMake(LYRUIMaxCellWidth(), LYRUIMaxCellHeight());
    CGSize itemSize = LYRUISizeProportionallyConstrainedToSize(image.size, maxSize);
    return itemSize;
}

CGSize LYRUISizeProportionallyConstrainedToSize(CGSize nativeSize, CGSize maxSize)
{
    CGSize itemSize;
    CGFloat widthScale = maxSize.width / nativeSize.width;
    CGFloat heightScale = maxSize.height / nativeSize.height;
    if (heightScale < widthScale) {
        itemSize = CGSizeMake(nativeSize.width * heightScale, maxSize.height);
    } else {
        itemSize = CGSizeMake(maxSize.width, nativeSize.height * widthScale);
    }
    return itemSize;
}

CGRect LYRUIImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize)
{
    CGSize itemSize = LYRUISizeProportionallyConstrainedToSize(imageSize, maxSize);
    CGRect thumbRect = {0, 0, itemSize};
    return thumbRect;
}

UIImage *LYRUIAdjustOrientationForImage(UIImage *originalImage)
{
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    [originalImage drawInRect:(CGRect){0, 0, originalImage.size}];
    UIImage *fixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fixedImage;
}

LYRMessagePart *LYRUIMessagePartWithText(NSString *text)
{
    return [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

LYRMessagePart *LYRUIMessagePartWithLocation(CLLocation *location)
{
    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    return [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeLocation
                                              data:[NSJSONSerialization dataWithJSONObject: @{@"lat" : lat, @"lon" : lon} options:0 error:nil]];
}

LYRMessagePart *LYRUIMessagePartWithJPEGImage(UIImage *image)
{
    UIImage *adjustedImage = LYRUIAdjustOrientationForImage(image);
    NSData *imageData = UIImageJPEGRepresentation(adjustedImage, 1.0);
    return [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeImageJPEG
                                              data:imageData];
}

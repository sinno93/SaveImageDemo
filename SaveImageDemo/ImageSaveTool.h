//
//  ImageSaveTool.h
//  SaveImageDemo
//
//  Created by Sinno on 2017/11/20.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@class NSData;
@class PHAsset;


/**
 保存完成回调
 
 @param success YES:保存成功；NO:保存失败
 @param asset PHAsset,通过其可获取到已保存到相册中的图片
 */
typedef void (^SaveCompletion)(BOOL success,PHAsset *asset);

@interface ImageSaveTool : NSObject

/**
 使用UIImageWriteToSavedPhtosAlbum保存图片

 @param image 要保存的图片
 @param completion 完成回调，注意此方法无法获取到asset;
 */
- (void)saveImageWithUIImageWriteToSavedPhotosAlbum:(UIImage *)image completion:(SaveCompletion)completion;

/**
 使用PhotoKit框架保存图片UIImage

 @param image 要保存的图片
 @param completion 完成回调
 */
+(void)saveImageWithPhotoKit:(UIImage*)image completion:(SaveCompletion)completion;


/**
 使用PhotoKit框架保存图片(原始数据NSData)

 @param data 要保存的图片data
 @param completion 完成回调
 */
+(void)saveImageDataWithPhotoKit:(NSData*)data completion:(SaveCompletion)completion;



/**
 使用AssetsLibrary保存图片(原始数据NSData)

 @param data 要保存的图片data
 @param completion 完成回调
 */
+(void)saveImageDataWithAssetsLibrary:(NSData*)data completion:(SaveCompletion)completion;

/**
 使用AssetsLibrary保存图片(UIImage)
 
 @param image 要保存的图片
 @param completion 完成回调
 */
+(void)saveImageWithAssetsLibrary:(UIImage*)image completion:(SaveCompletion)completion;
@end

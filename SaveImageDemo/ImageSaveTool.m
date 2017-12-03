//
//  ImageSaveTool.m
//  SaveImageDemo
//
//  Created by Sinno on 2017/11/20.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import "ImageSaveTool.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ImageSaveTool()
@property(nonatomic,copy)SaveCompletion completionBlock;
@end
@implementation ImageSaveTool

- (void)saveImageWithUIImageWriteToSavedPhotosAlbum:(UIImage *)image completion:(SaveCompletion) completion{
    //保存完后调用的方法
    
    self.completionBlock = completion;
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    //保存
    UIImageWriteToSavedPhotosAlbum(image, self, selector, NULL);
}

//图片保存完后调用的方法
- (void)onCompleteCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error){
        //保存失败
        self.completionBlock(NO,nil);
    }else {
        //保存成功
        self.completionBlock(YES,nil);
    }
}

// 通过PhotoKit保存图片(原始数据NSData)
+(void)saveImageDataWithPhotoKit:(NSData*)data completion:(SaveCompletion)completion{
    [self p_saveDataWithPhtotoKit:data completion:completion];
}

// 通过PhotoKit保存图片(UIImage)
+(void)saveImageWithPhotoKit:(UIImage*)image completion:(SaveCompletion)completion{
    [self p_saveDataWithPhtotoKit:image completion:completion];
}


// 通过AssetsLibrary保存图片(原始数据NSData)
+(void)saveImageDataWithAssetsLibrary:(NSData*)data completion:(SaveCompletion)completion{
    [self p_saveDataWithAssetsLibrary:data completion:completion];
}

// 通过AssetsLibrary保存图片(UIImage)
+(void)saveImageWithAssetsLibrary:(UIImage*)image completion:(SaveCompletion)completion{
    [self p_saveDataWithAssetsLibrary:image completion:completion];
}



/**
 通过PhtotoKit保存图片，根据传入data的类型进行不同处理

 @param data 图片数据，可为UIImage/NSData类型
 @param completion 完成回调
 */
+(void)p_saveDataWithPhtotoKit:(id)data completion:(SaveCompletion)completion{
    // 判断数据是否有效：data必须为NSData 或者 UIImage类
    BOOL dataValid = data && ([data isKindOfClass:NSData.class]||[data isKindOfClass:UIImage.class]);
    if (!dataValid) {
        completion(NO,nil);
        return;
    }
    __block NSString* localIdentifier;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest *createRequest = nil;
        if ([data isKindOfClass:NSData.class]) {
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            createRequest = [PHAssetCreationRequest creationRequestForAsset];
            [createRequest addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        }else{
            createRequest = [PHAssetCreationRequest creationRequestForAssetFromImage:data];
        }
        
        localIdentifier = createRequest.placeholderForCreatedAsset.localIdentifier;
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success && localIdentifier) {
            //成功后取相册中的图片对象
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
            PHAsset* asset = [result firstObject];
            completion(success,asset);
        }else{
            completion(success,nil);
        }
        
    }];
}


/**
 通过AssetsLibrary保存图片，根据传入data的类型进行不同处理
 
 @param data 图片数据，可为UIImage/NSData类型
 @param completion 完成回调
 */
+(void)p_saveDataWithAssetsLibrary:(id)data completion:(SaveCompletion)completion{
    // 判断数据是否有效：data必须为NSData 或者 UIImage类
    BOOL dataValid = data && ([data isKindOfClass:NSData.class]||[data isKindOfClass:UIImage.class]);
    if (!dataValid) {
        completion(NO,nil);
        return;
    }
     ALAssetsLibrary *alassetsLib = [[ALAssetsLibrary alloc] init];
    if ([data isKindOfClass:NSData.class]) {
        [alassetsLib writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error||!assetURL) {
                completion(NO,nil);
            }else{
                PHFetchResult<PHAsset*> *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
                PHAsset* asset = [result firstObject];
                if (!asset) {
                    completion(NO,nil);
                }else{
                    completion(YES,asset);
                }
            }
        }];
    }else{
        UIImage *image = (UIImage*)data;
        [alassetsLib writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error||!assetURL) {
                completion(NO,nil);
            }else{
                PHFetchResult<PHAsset*> *result = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
                PHAsset* asset = [result firstObject];
                if (!asset) {
                    completion(NO,nil);
                }else{
                    completion(YES,asset);
                }
            }
        }];
    }
    
}
@end

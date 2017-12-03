//
//  ViewController.m
//  SaveImageDemo
//
//  Created by Sinno on 2017/11/20.
//  Copyright © 2017年 sinno. All rights reserved.
//

#import "ViewController.h"
#import "ImageSaveTool.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;

@property(nonatomic,strong)UIImage* image;
@property(nonatomic,strong)NSData* imageData;
@property (weak, nonatomic) IBOutlet UISwitch *saveSwitch;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self switchValueChange:self.saveSwitch];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark actions
- (IBAction)switchValueChange:(id)sender {
    UISwitch* saveSwitch = (UISwitch*)sender;
    if (saveSwitch.on) {
        self.infoLabel.text = @"保存图片原始数据NSData";
    }else{
        self.infoLabel.text = @"直接保存图片UIImage";
    }
}

// 下载网络图片
- (IBAction)downloadNetImage:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://wps.appdao.com/2016/48/5/148066121660189512438.jpg"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    self.image = [UIImage imageWithData:data];
    self.imageData = data;
    self.imageView.image = self.image;
    NSString* sizeDesc = [NSString stringWithFormat:@"图片大小:%lu(bytes)",(unsigned long)data.length];
    self.sizeLabel.text = sizeDesc;
    return;
}

// 选取相册图片
- (IBAction)selectAlbumPhoto:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// 保存图片方法一：
- (IBAction)saveImageMethod1:(id)sender {
    ImageSaveTool* tool = [[ImageSaveTool alloc]init];
    [tool saveImageWithUIImageWriteToSavedPhotosAlbum:self.image completion:^(BOOL success,PHAsset*asset) {
        if (success) {
            NSLog(@"保存图片成功-请选取相册图片选取保存的图片查看大小");
        }else{
            NSLog(@"保存图片失败");
        }
    }];
}

// 保存图片方法二:
- (IBAction)saveImageMethod2:(id)sender {
    BOOL saveOriginImageData = self.saveSwitch.on;
    NSData* imageData = self.imageData;
    UIImage* image = self.image;
    if (saveOriginImageData) {
        [ImageSaveTool saveImageDataWithPhotoKit:imageData completion:^(BOOL success,PHAsset*asset) {
            if (success) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable saveImageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"PhotoKit-保存NSData:原图大小:%lu 保存到相册中图片大小:%lu",imageData.length,saveImageData.length);
                }];
            }else{
                NSLog(@"保存图片失败");
            }
        }];
    }else{
        [ImageSaveTool saveImageWithPhotoKit:image completion:^(BOOL success, PHAsset *asset) {
            if (success) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable saveImageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"PhotoKit-保存UIImage:原图大小:%lu 保存到相册中图片大小:%lu",imageData.length,saveImageData.length);
                }];
            }else{
                NSLog(@"保存图片失败");
            }
        }];
    }
    
}

// 保存图片方法三:
- (IBAction)saveImageMethod3:(id)sender {
    BOOL saveOriginImageData = self.saveSwitch.on;
    NSData* imageData = self.imageData;
    UIImage* image = self.image;
    if (saveOriginImageData) {
        [ImageSaveTool saveImageDataWithAssetsLibrary:self.imageData completion:^(BOOL success,PHAsset*asset) {
            if (success) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable saveImageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"AssetsLibrary-保存NSData:原图大小:%lu 保存到相册中图片大小:%lu",imageData.length,saveImageData.length);
                }];
            }else{
                NSLog(@"保存图片失败");
            }
        }];
    }else{
        [ImageSaveTool saveImageWithAssetsLibrary:image completion:^(BOOL success, PHAsset *asset) {
            if (success) {
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable saveImageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSLog(@"AssetsLibrary-保存UIImage:原图大小:%lu 保存到相册中图片大小:%lu",imageData.length,saveImageData.length);
                }];
            }else{
                NSLog(@"保存图片失败");
            }
        }];
    }
    
}



#pragma mark delegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSURL *imageAssetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    PHFetchResult*result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
    
    PHAsset *asset = [result firstObject];
    
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        self.imageData = imageData;
        self.image = [UIImage imageWithData:imageData];
        self.imageView.image = self.image;
        NSString* sizeDesc = [NSString stringWithFormat:@"图片大小:%lu(bytes)",(unsigned long)imageData.length];
        self.sizeLabel.text = sizeDesc;
        
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

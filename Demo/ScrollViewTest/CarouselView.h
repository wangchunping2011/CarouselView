//
//  CustomView.h
//  ScrollViewTest
//
//  Created by 王春平 on 15/12/19.
//  Copyright © 2015年 王春平. All rights reserved.
//

//轮播图
#import <UIKit/UIKit.h>

//轮播图中图片来源，ImageSourceLocal：本地图片，ImageSourceNetwork：从网络获取图片
typedef NS_ENUM(NSInteger, ImageSource) {
    ImageSourceLocal,
    ImageSourceNetwork
};
//跳转下级界面
typedef void(^pushToDetailView)(UIGestureRecognizer *gestureRecognizer);

@interface CarouselView : UIView

//轮播图的默认图片
@property (nonatomic, strong) UIImage *placeholderImage;
//pageControl当前页渲染色
@property (nonatomic, strong) UIColor *pageControlCurrentColor;
//pageControl未选中页选染色
@property (nonatomic, strong) UIColor *pageControlColor;
@property (nonatomic, copy) pushToDetailView block;


/*
 *  imageArray:图片数组, idArray:图片id数组, imageSource:图片来源。 
    imageSource为ImageSourceLocal时，IdArray可赋值为nil，imageArray中元素应为UIImage对象；
    imageSource为ImageSourceNetwork时，IdArray中元素应为网络图片id字符串，imageArray中元素应为网络图片地址URL字符串。
 */
- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSMutableArray *)imageArray idArray:(NSMutableArray *)idArray imageSource:(ImageSource)imageSource;

//从外部传入block
- (void)getBlockFromOutSpace:(pushToDetailView)block;

@end

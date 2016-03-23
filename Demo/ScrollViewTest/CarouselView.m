//
//  CustomView.m
//  ScrollViewTest
//
//  Created by 王春平 on 15/12/19.
//  Copyright © 2015年 王春平. All rights reserved.
//

#import "CarouselView.h"

/*
 *  计时器MSWeakTimer详解：http://www.jianshu.com/p/846f8486a9d0
 */

@interface CarouselView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) MSWeakTimer *timer;

@end

@implementation CarouselView

/*
 *  数组添加元素，设数组array: @[a1, a2, a3, a4];
    添加元素后，array: @[a4, a1, a2, a3, a4, a1];
 */
- (void)addObjectToArray:(NSMutableArray *)array {
    id lastObject = [array lastObject];
    [array addObject:[array firstObject]];
    [array insertObject:lastObject atIndex:0];
}

- (instancetype)initWithFrame:(CGRect)frame imageArray:(NSMutableArray *)imageArray idArray:(NSMutableArray *)idArray imageSource:(ImageSource)imageSource {
    self = [super initWithFrame:frame];
    if (self) {
        self.timer = [MSWeakTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerAction) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];

        //向数据源中添加元素
        [self addObjectToArray:imageArray];
        [self addObjectToArray:idArray];
        
        //布局scrollView
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.contentSize = CGSizeMake(imageArray.count * frame.size.width, frame.size.height);
        self.scrollView.backgroundColor = [UIColor whiteColor];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(frame.size.width, 0);
        [self addSubview:self.scrollView];
        
        //添加imageView到scrollView上
        for (NSUInteger i = 0; i < imageArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width * i, 0, frame.size.width, frame.size.height)];
            imageView.userInteractionEnabled = YES;
                        [self.scrollView addSubview:imageView];
            if (ImageSourceLocal == imageSource) {
                imageView.image = imageArray[i];
            } else {
                //将图片的id赋值给imageView的tag,便于跳转下级界面的传值操作
                imageView.tag = [idArray[i] integerValue];
                [imageView setImageWithURL:[NSURL URLWithString:imageArray[i]] placeholderImage:self.placeholderImage];
            }
            //添加轻拍手势
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
            [imageView addGestureRecognizer:tapGestureRecognizer];
        }
        [self setupPageControlWithPageCount:imageArray.count];
    }
    return self;
}

//布局pageControl
- (void)setupPageControlWithPageCount:(NSUInteger)pageCount {
    //布局pageControl
    self.pageControl = [[UIPageControl alloc] init];
    //因imageArray.count = 轮播图展示图片个数 + 2
    self.pageControl.numberOfPages = pageCount - 2;
    self.pageControl.currentPageIndicatorTintColor = [UIColor cyanColor];
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    //        [self.pageControl addTarget:self action:@selector(handlePageControl:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    //给pageControl添加约束
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-10);
        make.height.mas_equalTo(20 * SizeScale);
        make.width.equalTo(self.mas_width);
    }];
}

#pragma mark - setter action

- (void)setPageControlCurrentColor:(UIColor *)pageControlCurrentColor {
    self.pageControl.currentPageIndicatorTintColor = pageControlCurrentColor;
}

- (void)setPageControlColor:(UIColor *)pageControlColor {
    self.pageControl.pageIndicatorTintColor = pageControlColor;
}

#pragma mark - handel action

- (void)timerAction {
    CGFloat x = self.scrollView.contentOffset.x;
    if (x > self.scrollView.frame.size.width * (self.scrollView.subviews.count - 3)) {
        self.pageControl.currentPage = 0;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    } else {
        self.scrollView.contentOffset = CGPointMake(x + self.scrollView.frame.size.width, 0);
        //scrollView的初始偏移量为scrollView.frame.size.width，self.pageControl.currentPage初始为0
        self.pageControl.currentPage = self.scrollView.contentOffset.x / self.scrollView.frame.size.width - 1;
    }
}

- (void)handleTapAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.block) {
        self.block(tapGestureRecognizer);
    }
}

/*
 - (void)handlePageControl:(UIPageControl *)pageControl {
 [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * pageControl.currentPage, 0) animated:YES];
 }
 */

//将外界传入的block赋值给self.block
- (void)getBlockFromOutSpace:(pushToDetailView)block {
    self.block = block;
}

#pragma mark - UIScrollViewDelegate

//在此方法中处理手动滑动scrollView效果
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width - 1;
    if (scrollView.contentOffset.x < scrollView.frame.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * (scrollView.subviews.count - 2), 0);
        self.pageControl.currentPage = scrollView.subviews.count - 3;
    }
    if (scrollView.contentOffset.x > scrollView.frame.size.width * (scrollView.subviews.count - 2)) {
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0);
        self.pageControl.currentPage = 0;
    }
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

@end

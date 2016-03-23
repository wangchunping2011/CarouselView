//
//  ViewController.m
//  ScrollViewTest
//
//  Created by 王春平 on 15/12/21.
//  Copyright © 2015年 王春平. All rights reserved.
//

#import "ViewController.h"
#define ImageNamePrefix @"Image-"

@interface ViewController ()
{
    CGFloat _top;
}

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *idArray;

@end

@implementation ViewController

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        self.imageArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _imageArray;
}

- (NSMutableArray *)idArray {
    if (!_idArray) {
        self.idArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _idArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _top = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
}

//本地图片
- (IBAction)localAction:(UIButton *)sender {
    [self getLoaclData];
}

//网络图片
- (IBAction)networkAction:(UIButton *)sender {
    [self getRequestData];
}

- (void)getLoaclData {
    [self.imageArray removeAllObjects];
    for (NSInteger i = 0; i < 4; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%d", ImageNamePrefix, i+ 1]];
        [self.imageArray addObject:image];
    }
    CarouselView *view = [[CarouselView alloc] initWithFrame:CGRectMake(0, _top, self.view.frame.size.width, self.view.frame.size.height / 3) imageArray:self.imageArray idArray:nil imageSource:ImageSourceLocal];
    [self.view addSubview:view];
}

- (void)getRequestData {
    [self.imageArray removeAllObjects];
    [self.idArray removeAllObjects];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://a2m.duotin.com/recommend?mobile_key=0039203a-hVbU72UYQlFSNvqeKMqxMg&platform=iOS&version=2.2.2" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress: %@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:1];
        for (NSDictionary *tempDic in responseObject[@"data"][@"category_list"]) {
            [newArray addObject:tempDic[@"category"]];
        }
        for (NSDictionary *tempDic in newArray) {
            [self.imageArray addObject:tempDic[@"image_path"]];
            [self.idArray addObject:tempDic[@"id"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CarouselView *view = [[CarouselView alloc] initWithFrame:CGRectMake(0, _top, self.view.frame.size.width, self.view.frame.size.height / 3) imageArray:self.imageArray idArray:self.idArray imageSource:ImageSourceNetwork];
//            view.pageControlCurrentColor = [UIColor redColor];
//            view.pageControlColor = [UIColor grayColor];
            [view getBlockFromOutSpace:^(UIGestureRecognizer *gestureRecognizer) {
                NSLog(@"tag:%d", gestureRecognizer.view.tag);
            }];
            [self.view addSubview:view];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"AFHttp error:%d", error.code);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && self.view.window) {
        self.view = nil;
    }
}

@end

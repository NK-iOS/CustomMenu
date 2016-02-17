//
//  NKConst.h
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import <UIKit/UIKit.h>

// 获取屏幕尺寸
#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height
#define screenBounds [UIScreen mainScreen].bounds
#define iOSVersion [[[UIDevice currentDevice] systemVersion] floatValue]

#ifdef DEBUG
#define NKLog(...) NSLog(__VA_ARGS__)
#else
#define NKLog(...)
#endif

// 随机颜色
#define RandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]
#define ColorWithRGB(R, G, B) [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha:1]

// 常量字符串
extern NSString *const kTagCollectionViewCellIdentifier;
extern NSString *const kPageCollectionViewCellIdentifier;
extern NSString *const kCachedTime;
extern NSString *const kCachedVCName;
// 选中指示器的高度
extern CGFloat const kSelectionIndicatorHeight;

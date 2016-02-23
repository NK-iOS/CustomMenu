//
//  NKScrollPageController.h
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NKConst.h"

@interface NKScrollPageController : UIViewController
@property (nonatomic, strong) UIFont *normalTitleFont; // 正常标签字体, 默认14
@property (nonatomic, strong) UIFont *selectedTitleFont; // 选中状态字体 默认 加粗14

@property (nonatomic, strong) UIColor *normalTitleColor; // 正常状态标签颜色 默认为黑色
@property (nonatomic, strong) UIColor *selectedTitleColor; // 选中状态标签颜色 默认蓝色

@property (nonatomic, strong) UIColor *selectedIndicatorColor; // 下方滑块的颜色

/**
 如果tag设置了tagItemSize，则宽度默认跟tagItemSize宽度相同，高度为2（也可手动更改）
 如果tag使用自由文本宽度，则默认与第一个标签宽度相同，高度为2，而且宽度会随选中的标签文本宽度改变
 */
@property (nonatomic, assign) CGSize selectedIndicatorSize;

@property (nonatomic, assign) CGSize tagItemSize; // 每个tag便签的size，如果不设置则会根据文本长度计算

// 由于性能方面，设置定时器每十秒监测一次缓存，所以如需使用该属性，请尽量设置较大值
@property (nonatomic, assign) NSTimeInterval graceTime; // 控制器缓存时间，如果在该段时间内缓存的控制器依旧没有被展示，则会从内存中销毁，默认不设置，即默认在内存中缓存所有展示过的控制器

@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, assign) BOOL gapAnimated; // 跨越多个标签进行切换时，page是否动画，默认为NO，建议不开启，开启后中间过渡的控制器都会加载

// method
// 必须调用
- (instancetype)initWithTagViewHeight:(CGFloat)tagViewHeight;

// 刷新界面数据
- (void)reloadDataWith:(NSArray *)titleArray andSubviewDisplayClassed:(NSArray *)classes;

// 可以传递参数的刷新方法
- (void)reloadDataWith:(NSArray *)titleArray andSubviewDisplayClassed:(NSArray *)classes andParams:(NSArray *)params;

// 指定选中index位置的标签
- (void)selectTagByIndex:(NSInteger)index animated:(BOOL)animated;

@end

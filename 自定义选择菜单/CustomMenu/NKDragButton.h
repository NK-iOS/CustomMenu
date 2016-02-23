//
//  NKDragButton.h
//  自定义选择菜单
//
//  Created by 聂宽 on 16/1/12.
//  Copyright © 2016年 聂宽. All rights reserved.
//

#import <UIKit/UIKit.h>

#define screenW [[UIScreen mainScreen] bounds].size.width
#define screenH [[UIScreen mainScreen] bounds].size.height

@class NKDragButton;
@protocol NKDragButtonDelegate <NSObject>

// 拖拽按钮响应事件
- (void)dragButton:(NKDragButton *)dragButton dragButtons:(NSArray *)dragButtons;

@end

@interface NKDragButton : UIButton

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *tagStr;

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, assign) BOOL isShow;

// 声明代理变量
@property (nonatomic, weak) id<NKDragButtonDelegate> delegate;

// 存放需要拖拽的数组
@property (nonatomic, strong) NSMutableArray *btnArray;

// 按钮正在被拖拽时的颜色
@property (nonatomic, strong) UIColor *dragColor;

// 一排按钮的个数
@property (nonatomic, assign) NSUInteger lineCount;
@end

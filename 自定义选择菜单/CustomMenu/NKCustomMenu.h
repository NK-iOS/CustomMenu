//
//  NKCustomMenu.h
//  自定义选择菜单
//
//  Created by 聂宽 on 16/2/22.
//  Copyright © 2016年 聂宽. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NKCumtomMenuDelegate <NSObject>

// 当菜单view隐藏时，调用代理方法
- (void)customMenuDidHidden;

@end

@interface NKCustomMenu : UIScrollView
// 当前已经选中的项目
@property (nonatomic, strong) NSArray *selectedArr;

// 代理变量
@property (nonatomic, weak) id<NKCumtomMenuDelegate> menuDelegate;
@end

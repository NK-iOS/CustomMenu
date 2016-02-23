//
//  NKTagTitleModel.h
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NKTagTitleModel : NSObject

@property (nonatomic, copy) NSString *tagTitle; // 标签名
@property (nonatomic, strong) UIFont *normalTitleFont; // 正常标签字体
@property (nonatomic, strong) UIFont *selectedTitleFont; // 选中状态标签字体
@property (nonatomic, strong) UIColor *normalTitleColor; // 正常标签字体颜色
@property (nonatomic, strong) UIColor *selectedTitleColor; // 选中状态标签字体颜色

+ (NKTagTitleModel *)modelWithTagTitle:(NSString *)title
                    andNormalTitleFont:(UIFont *)normalTitleFont
                  andSelectedTitleFont:(UIFont *)selectedTitleFont
                   andNormalTitleColor:(UIColor *)normalTitleColor
                 andSelectedTitleColor:(UIColor *)selectedTitleColor;

@end

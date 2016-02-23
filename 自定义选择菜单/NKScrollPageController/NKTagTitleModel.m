//
//  NKTagTitleModel.m
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import "NKTagTitleModel.h"

@implementation NKTagTitleModel

+ (NKTagTitleModel *)modelWithTagTitle:(NSString *)title andNormalTitleFont:(UIFont *)normalTitleFont andSelectedTitleFont:(UIFont *)selectedTitleFont andNormalTitleColor:(UIColor *)normalTitleColor andSelectedTitleColor:(UIColor *)selectedTitleColor
{
    NKTagTitleModel *tagModel = [[self alloc] init];
    tagModel.tagTitle = title;
    tagModel.normalTitleFont = normalTitleFont;
    tagModel.selectedTitleFont = selectedTitleFont;
    tagModel.normalTitleColor = normalTitleColor;
    tagModel.selectedTitleColor = selectedTitleColor;
    return tagModel;
}
@end

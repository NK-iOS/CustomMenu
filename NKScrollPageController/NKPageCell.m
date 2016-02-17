//
//  NKPageCell.m
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import "NKPageCell.h"

@implementation NKPageCell

- (void)configCellWithController:(UIViewController *)controller
{
    controller.view.frame = self.bounds;
    [self.contentView addSubview:controller.view];
}
@end

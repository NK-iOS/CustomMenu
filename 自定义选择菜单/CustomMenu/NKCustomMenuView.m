//
//  NKCustomMenuView.m
//  自定义选择菜单
//
//  Created by 聂宽 on 16/1/8.
//  Copyright © 2016年 聂宽. All rights reserved.
//

#import "NKCustomMenuView.h"

@interface NKCustomMenuView ()

@property (nonatomic, strong) UICollectionView *menuCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *menuCollectionViewFlowLayout;

@end

@implementation NKCustomMenuView

- (instancetype)init
{
    if (self = [super init]) {
        _menuCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        
    }
    return self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.4 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

@end

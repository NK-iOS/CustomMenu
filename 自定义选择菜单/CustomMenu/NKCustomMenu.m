//
//  NKCustomMenu.m
//  自定义选择菜单
//
//  Created by 聂宽 on 16/2/22.
//  Copyright © 2016年 聂宽. All rights reserved.
//

#import "NKCustomMenu.h"
#import "NKDragButton.h"

// 每行放几个item
static NSUInteger lineCount = 4;
// 每个item的间距
static CGFloat itemMargin = 1;
@interface NKCustomMenu ()<NKDragButtonDelegate>
// 存放所有的栏目数组
@property (nonatomic, strong) NSMutableArray *allMutArr;

// 存放已选栏目数组
@property (nonatomic, strong) NSMutableArray *array;

// 存放未选栏目数组
@property (nonatomic, strong) NSMutableArray *moreArray;

@property (nonatomic, assign) CGFloat btnHeight;

// 当前scrollview内容的最大Y值
@property (nonatomic, assign) CGFloat maxY;
@end

@implementation NKCustomMenu

- (instancetype)init
{
    if (self = [super init]) {
        _allMutArr = [NSMutableArray array];
        _array = [NSMutableArray array];
        _moreArray = [NSMutableArray array];
        
        self.btnHeight = 80;
    }
    return self;
}

- (void)setSelectedArr:(NSArray *)selectedArr
{
    _selectedArr = selectedArr;
    
    NSArray *title = @[@"励志",@"美食",@"科技",@"娱乐",@"财经",@"动态",@"感情",@"社会",@"人人",@"QQ",@"腾讯",@"百度"];
    
    for (int i = 0; i < title.count; i ++) {
        NKDragButton *dragBtn = [NKDragButton buttonWithType:UIButtonTypeCustom];
        dragBtn.titleStr = title[i];
        dragBtn.tagStr = [NSString stringWithFormat:@"%d", 10 + i];
        dragBtn.isShow = [self.selectedArr containsObject:title[i]] ? YES:NO;
        
        [_allMutArr addObject:dragBtn];
    }
    
    for (int i = 0; i < _allMutArr.count; i ++) {
        NKDragButton *dragBtn = _allMutArr[i];
        if (dragBtn.isShow) {
            [_array addObject:dragBtn];
        }else
        {
            [_moreArray addObject:dragBtn];
        }
    }
    
    // 初始化scrollview
    [self settingScrollView];
}

- (void)settingScrollView
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    // 已选栏目 label
    UILabel *selLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenW, 40)];
    selLabel.backgroundColor = [UIColor lightGrayColor];
    selLabel.text = @"  已选栏目";
    selLabel.textColor = [UIColor orangeColor];
    [self addSubview:selLabel];
    
    self.maxY = CGRectGetMaxY(selLabel.frame);
    
    // 隐藏按钮
    UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [hideBtn setImage:[UIImage imageNamed:@"01Line-Icon-Set_03"] forState:UIControlStateNormal];
    hideBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    hideBtn.frame = CGRectMake(screenW - 80, 0, 80, 40);
    [hideBtn addTarget:self action:@selector(hideBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hideBtn];
    // 已选栏目
    CGFloat width = ([[UIScreen mainScreen] bounds].size.width - (lineCount * itemMargin + itemMargin)) / lineCount;
    for (NSInteger index = 0; index < _array.count; index ++) {
        NKDragButton *dragBtn = _array[index];
        NSInteger row = index / lineCount;
        NSInteger col = index % lineCount;
        dragBtn.backgroundColor = [UIColor brownColor];
        dragBtn.tag = dragBtn.tagStr.integerValue;
        dragBtn.lineCount = lineCount;
        dragBtn.dragColor = [UIColor orangeColor];
        dragBtn.delegate = self;
        [dragBtn setTitle:dragBtn.titleStr forState:UIControlStateNormal];
        [dragBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dragBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        dragBtn.frame = CGRectMake(col * (width + itemMargin) + itemMargin, row * (_btnHeight + itemMargin) + self.maxY, width, _btnHeight);
        [self addSubview:dragBtn];
        
        dragBtn.btnArray = _array;
    }
    
    NSInteger scrollRow = ceilf(self.array.count * 1.0 / lineCount);
    self.maxY = self.maxY + scrollRow * (self.btnHeight + itemMargin);
    
    // 待选栏目 label
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.maxY, screenW, 40)];
    moreLabel.backgroundColor = [UIColor lightGrayColor];
    moreLabel.text = @"  点击添加更多栏目";
    moreLabel.textColor = [UIColor orangeColor];
    [self addSubview:moreLabel];
    
    self.maxY = CGRectGetMaxY(moreLabel.frame);
    // 待选栏目
    for (NSInteger index = 0; index < _moreArray.count; index ++) {
        NKDragButton *dragBtn = _moreArray[index];
        NSInteger row = index / lineCount;
        NSInteger col = index % lineCount;
        dragBtn.backgroundColor = [UIColor brownColor];
        dragBtn.tag = dragBtn.tagStr.integerValue;
        dragBtn.lineCount = lineCount;
        dragBtn.dragColor = [UIColor orangeColor];
        dragBtn.delegate = self;
        [dragBtn setTitle:dragBtn.titleStr forState:UIControlStateNormal];
        [dragBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dragBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        dragBtn.frame = CGRectMake(col * (width + itemMargin) + itemMargin, row * (_btnHeight + itemMargin) + self.maxY, width, _btnHeight);
        [self addSubview:dragBtn];
        
        dragBtn.btnArray = _moreArray;
    }
    
    NSInteger moreScrollRow = ceilf(self.moreArray.count * 1.0 / lineCount);
    self.maxY = self.maxY + moreScrollRow * (self.btnHeight + itemMargin);
}

// remove 告诉我们是否重新排序，移动到不同分组直接加在后面要保持排序不变
- (void)changeFrame:(BOOL)remove
{
    if (remove) {
        [_array removeAllObjects];
        [_moreArray removeAllObjects];
        for (int i = 0; i < _allMutArr.count; i++) {
            NKDragButton *dragBtn = _allMutArr[i];
            if (dragBtn.isShow) {
                [_array addObject:dragBtn];
            }else
            {
                [_moreArray addObject:dragBtn];
            }
        }
    }else
    {
        [self chanArr];
    }
    
    [self settingScrollView];
}


- (void)clickAction:(NKDragButton *)button
{
    button.isShow = !button.isShow;
    [self changeFrame:YES];
    
    // 重新调整位置
    [self chanArr];
    
    [self settingScrollView];
}

- (void)chanArr
{
    [_allMutArr removeAllObjects];
    for (int i = 0; i < _array.count; i ++) {
        [_allMutArr addObject:_array[i]];
    }
    for (int i = 0; i < _moreArray.count; i ++) {
        [_allMutArr addObject:_moreArray[i]];
    }
}

#pragma mark - NKDragButtonDelegate
- (void)dragButton:(NKDragButton *)dragButton dragButtons:(NSArray *)dragButtons
{
    // 这里dragButtons 与 _array指向的是同一块内存空间，地址一样
    [self changeFrame:NO];
}

- (void)hideBtnClick
{
    // 将已选栏目存入偏好设置中
    NSMutableArray *seletedArr = [NSMutableArray array];
    for (NKDragButton *dragBtn in _array) {
        NSDictionary *dict = @{@"titleStr":dragBtn.titleStr, @"tag":dragBtn.tagStr};
        [seletedArr addObject:dict];
    }
    NSUserDefaults *userDefaules = [NSUserDefaults standardUserDefaults];
    [userDefaules setObject:seletedArr forKey:@"columnArr"];
    [userDefaules synchronize];
    
    [UIView animateWithDuration:0.4 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    
    if ([self.menuDelegate respondsToSelector:@selector(customMenuDidHidden)]) {
        [self.menuDelegate customMenuDidHidden];
    }
}
@end

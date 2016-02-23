//
//  NKCustomMenuView.m
//  自定义选择菜单
//
//  Created by 聂宽 on 16/1/8.
//  Copyright © 2016年 聂宽. All rights reserved.
//

#import "NKCustomMenuView.h"
#import "NKDragButton.h"

// 每行放几个item
static NSUInteger lineCount = 4;
// 每个item的间距
static CGFloat itemMargin = 1;
@interface NKCustomMenuView ()<NKDragButtonDelegate>
// 已选择选项
@property (nonatomic, strong) NSMutableArray *array;
// 未选择选项
@property (nonatomic, strong) NSMutableArray *moreArray;
// 存放全部的选项
@property (nonatomic, strong) NSMutableArray *allMutArr;

// 已选择选项的scrollview
@property (nonatomic, strong) UIScrollView *scrollView;
// 未选中选项的scrollview
@property (nonatomic, strong) UIScrollView *moreScrollView;

@property (nonatomic, assign) CGFloat btnHeight;

// 待选栏目 label
@property (nonatomic, strong) UILabel *moreLabel;
@end

@implementation NKCustomMenuView

- (instancetype)init
{
    if (self = [super init]) {
        _array = [NSMutableArray array];
        _moreArray = [NSMutableArray array];
        _allMutArr = [NSMutableArray array];
        
        self.btnHeight = 80;
    }
        return self;
}

- (void)setSelectedArr:(NSArray *)selectedArr
{
    _selectedArr = selectedArr;
    
    NSArray *title = @[@"励志",@"美食",@"科技",@"娱乐",@"财经",@"动态",@"感情",@"社会"];
    
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
    
    [self changeScrollView];
}

- (void)settingScrollView
{
    // 已选栏目 label
    UILabel *selLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenW, 40)];
    selLabel.backgroundColor = [UIColor lightGrayColor];
    selLabel.text = @"  已选栏目";
    selLabel.textColor = [UIColor orangeColor];
    [self addSubview:selLabel];
    
    // scrollView
    NSInteger scrollRow = ceilf(self.selectedArr.count * 1.0 / lineCount);
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(selLabel.frame), screenW, _btnHeight * scrollRow)];
    self.scrollView.bounces = NO;
    self.scrollView.scrollEnabled = NO;
    [self addSubview:self.scrollView];
    
    // 待选栏目 label
    self.moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), screenW, 40)];
    self.moreLabel.backgroundColor = [UIColor lightGrayColor];
    self.moreLabel.text = @"  点击添加更多栏目";
    self.moreLabel.textColor = [UIColor orangeColor];
    [self addSubview:self.moreLabel];

    // moreScrollView
    NSInteger moreScrollRow = ceilf(self.moreArray.count * 1.0 / lineCount);
    self.moreScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moreLabel.frame), screenW, moreScrollRow * _btnHeight)];
    self.moreScrollView.bounces = NO;
    self.moreScrollView.scrollEnabled = NO;
    [self addSubview:self.moreScrollView];
}

- (void)changeScrollView
{
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.moreScrollView.subviews) {
        [view removeFromSuperview];
    }
    
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
        dragBtn.frame = CGRectMake(col * (width + itemMargin) + itemMargin, row * (_btnHeight + itemMargin), width, _btnHeight);
        [self.scrollView addSubview:dragBtn];
        
        dragBtn.btnArray = _array;
    }
    
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
        dragBtn.frame = CGRectMake(col * (width + itemMargin) + itemMargin, row * (_btnHeight + itemMargin), width, _btnHeight);
        [self.moreScrollView addSubview:dragBtn];
        
        dragBtn.btnArray = _moreArray;
    }

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
    
    [self changeScrollView];
    
    [self updateFrame];
}

- (void)updateFrame
{
    // scrollView
    NSInteger scrollRow = ceilf(self.array.count * 1.0 / lineCount);
    CGRect frame = self.scrollView.frame;
    CGFloat scrollViewHeight = scrollRow * _btnHeight;
    frame.size.height = scrollViewHeight;
    self.scrollView.frame = frame;
    
    // 待选栏目 label
    self.moreLabel.frame = CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), screenW, 40);
    
    // moreScrollView
    NSInteger moreScrollRow = ceilf(self.moreArray.count * 1.0 / lineCount);
    self.moreScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.moreLabel.frame), screenW, moreScrollRow * _btnHeight);
}

- (void)clickAction:(NKDragButton *)button
{
    button.isShow = !button.isShow;
    [self changeFrame:YES];
    
    // 重新调整位置
    [self chanArr];
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


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.4 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

@end

//
//  NKDragButton.m
//  自定义选择菜单
//
//  Created by 聂宽 on 16/1/12.
//  Copyright © 2016年 聂宽. All rights reserved.
//

#import "NKDragButton.h"

static CGFloat kDuration = .2f;
static CGFloat kBaseDuration = .4f;
@interface NKDragButton ()

@property (nonatomic, assign) NSInteger dragIndex;
@property (nonatomic, assign) CGPoint dragCenter;
@property (nonatomic, strong) UIColor *bgColor;

@property (nonatomic, strong) NSMutableArray *dragButtons;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) NSUInteger startIndex;

@property (nonatomic, strong) UIView *displayView;
@property (nonatomic, strong) UIButton *topView, *bottomView;

@end

@implementation NKDragButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPanPressed:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)setBtnArray:(NSMutableArray *)btnArray
{
    _btnArray = btnArray;
    for (NKDragButton *btn in btnArray) {
        // 每个按钮都有一个dragButtons的数组
        btn.dragButtons = btnArray;
    }
}

#pragma mark - 手势响应，并判断状态
- (void)buttonPanPressed:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self touchesBegan:panGestureRecognizer];
    }else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        [self touchesMoved:panGestureRecognizer];
    }else
    {
        [self touchesEnded:panGestureRecognizer];
    }
}

// 拖拽开始
- (void)touchesBegan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.superview bringSubviewToFront:self];
    self.startPoint = [panGestureRecognizer locationInView:self];
    self.bgColor = self.backgroundColor;
    self.dragCenter = self.center;
    self.dragIndex = [self.dragButtons indexOfObject:self];
    self.startIndex = [self.dragButtons indexOfObject:self];
    
    [UIView animateWithDuration:kDuration animations:^{
        self.backgroundColor = self.dragColor ? self.dragColor : self.bgColor;
        self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

// 拖拽移动
- (void)touchesMoved:(UIPanGestureRecognizer *)panGestureRecognizer
{
    // 调整被拖拽按钮的center， 保证它跟手指一起移动
    CGPoint newPoint = [panGestureRecognizer locationInView:self];
    CGFloat deltaX = newPoint.x - self.startPoint.x;
    CGFloat deltaY = newPoint.y - self.startPoint.y;
    
    self.center = CGPointMake(self.center.x + deltaX, self.center.y + deltaY);
    
    for (NSInteger index = 0; index < self.dragButtons.count; index ++) {
        UIButton *button = self.dragButtons[index];
        
        if (self.dragIndex != index) {
            if (CGRectContainsPoint(button.frame, self.center)) {
                // 调整按钮的排序
                [self adjustButtons:self index:index];
            }
        }
    }
}

// 拖拽停止
- (void)touchesEnded:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [UIView animateWithDuration:kDuration animations:^{
        self.backgroundColor = self.bgColor;
        self.transform = CGAffineTransformIdentity;
        self.center = self.dragCenter;
    }];

    // 判断按钮位置是否已经改变，如果发生了改变通过代理通知父视图
    if (self.startIndex != self.dragIndex) {
        if ([self.delegate respondsToSelector:@selector(dragButton:dragButtons:)]) {
            [self.delegate dragButton:self dragButtons:self.dragButtons];
        }
    }
}

// 重新调整按钮位置
- (void)adjustButtons:(NKDragButton *)btn index:(NSInteger)index
{
    UIButton *moveBtn = self.dragButtons[index];
    CGPoint moveCenter = moveBtn.center;
    
    __block CGPoint oldCenter = self.dragCenter;
    __block CGPoint nextCenter = CGPointZero;
    
    if (index < self.dragIndex) {
        // 将靠前的按钮移动到靠后的位置
        for (NSInteger num = self.dragIndex - 1; num >= index; num --) {
            // 将上一个按钮的位置赋值给当前按钮
            [UIView animateWithDuration:kDuration animations:^{
                UIButton *nextBtn = [self.dragButtons objectAtIndex:num];
                nextCenter = nextBtn.center;
                nextBtn.center = oldCenter;
                oldCenter = nextCenter;
            }];
        }
        
        // 调整顺序
        [self.dragButtons insertObject:btn atIndex:index];
        // 将old位置上的item删除
        [self.dragButtons removeObjectAtIndex:self.dragIndex + 1];
    }else
    {
        // 将靠后的按钮移动到前面
        for (NSInteger num = self.dragIndex + 1; num <= index; num ++) {
            // 将上一个按钮的位置赋值给当前按钮
            [UIView animateWithDuration:kDuration animations:^{
                UIButton *nextBtn = [self.dragButtons objectAtIndex:num];
                nextCenter = nextBtn.center;
                nextBtn.center = oldCenter;
                oldCenter = nextCenter;
            }];
        }
        
        // 调整顺序
        [self.dragButtons insertObject:btn atIndex:index + 1];
        // 删除old位置上的item
        [self.dragButtons removeObjectAtIndex:self.dragIndex];
    }
    
    self.dragIndex = index;
    self.dragCenter = moveCenter;
}
@end

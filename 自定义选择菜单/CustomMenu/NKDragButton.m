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
    [[self superview] bringSubviewToFront:self];
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
    
}

// 重新调整按钮位置
- (void)adjustButtons:(NKDragButton *)btn index:(NSInteger)index
{
    
}
@end

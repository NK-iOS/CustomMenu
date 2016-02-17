//
//  ViewController.m
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/30.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import "ViewController.h"
#import "NKViewController.h"
#import "NKCustomMenuView.h"

@interface ViewController ()

@property (nonatomic, strong) NKCustomMenuView *customMenuView;

@end

@implementation ViewController

- (NKCustomMenuView *)customMenuView
{
    if (_customMenuView == nil) {
        _customMenuView = [[NKCustomMenuView alloc] init];
        _customMenuView.frame = CGRectMake(0, screenH, screenW, screenH - 64);
        [self.view addSubview:_customMenuView];
    }
    return _customMenuView;
}

- (instancetype)init
{
    if (self = [super initWithTagViewHeight:49]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义菜单";
    
    self.backgroundColor = [UIColor whiteColor];
    //设置自定义属性
    self.tagItemSize = CGSizeMake(110, 49);
    self.gapAnimated = YES;
    NSArray *titleArray = @[
                            @"image",
                            @"tableView",
                            @"collectionView",
                            @"image",
                            @"tableView",
                            @"collectionView",
                            ];
    
    NSArray *classNames = @[
                            [NKViewController class],
                            ];
    
    NSArray *params = @[
                        @"XBParamImage",
                        @"TableView",
                        @"CollectionView",
                        @"XBParamImage",
                        @"TableView",
                        @"CollectionView"
                        ];
    [self reloadDataWith:titleArray andSubviewDisplayClassed:classNames andParams:params];
    
    [self test];

}

- (void)test
{
    // 添加自定义菜单按钮
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    addBtn.backgroundColor = [UIColor greenColor];
    addBtn.frame = CGRectMake(screenW - 49 + 5, 2.5, 49 - 5, 49 - 5);
    addBtn.layer.shadowOffset = CGSizeMake(0, 0);
    addBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    addBtn.layer.shadowOpacity = 0.3;
//    addBtn.layer.shadowRadius = 10;
    addBtn.alpha = 0.8;
    [addBtn addTarget:self action:@selector(addMenuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = addBtn.bounds.size.width;
    float height = addBtn.bounds.size.height;
    float x = addBtn.bounds.origin.x;
    float y = addBtn.bounds.origin.y;
    float addWH = 10;
    
    CGPoint topLeft      = addBtn.bounds.origin;
    CGPoint topMiddle = CGPointMake(x+(width/2),y-addWH);
    CGPoint topRight     = CGPointMake(x+width,y);
    
    CGPoint rightMiddle = CGPointMake(x+width+addWH,y+(height/2));
    
    CGPoint bottomRight  = CGPointMake(x+width,y+height);
    CGPoint bottomMiddle = CGPointMake(x+(width/2),y+height+addWH);
    CGPoint bottomLeft   = CGPointMake(x,y+height);
    
    
    CGPoint leftMiddle = CGPointMake(x-addWH,y+(height/2));
    
    [path moveToPoint:topLeft];
    
    // 添加四个二元曲线
    // endPoint:曲线的终点
    // controlPoint:画曲线的基准点
    [path addQuadCurveToPoint:topRight controlPoint:topMiddle];
    [path addQuadCurveToPoint:bottomRight controlPoint:rightMiddle];
    [path addQuadCurveToPoint:bottomLeft controlPoint:bottomMiddle];
    [path addQuadCurveToPoint:topLeft controlPoint:leftMiddle];
    //设置阴影路径  
    addBtn.layer.shadowPath = path.CGPath;
}

- (void)addMenuBtnClick
{
    self.customMenuView.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.5 animations:^{
        self.customMenuView.transform = CGAffineTransformMakeTranslation(0, - screenH);
    } completion:^(BOOL finished) {
        
    }];
}
@end

//
//  NKScrollPageController.m
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import "NKScrollPageController.h"
#import "NKTagTitleCell.h"
#import "NKPageCell.h"
#import "NKTagTitleModel.h"

@interface NKScrollPageController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
// 标签高度
@property (nonatomic, assign) CGFloat tagViewHeight;

// 标签view
@property (nonatomic, strong) UICollectionView *tagCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *tagFlowLayout;

// 页面展示view
@property (nonatomic, strong) UICollectionView *pageCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *pageFlowLayout;

// 标题模型数组
@property (nonatomic, strong) NSMutableArray *tagTitleModelArray;

// 记录tag当前选中的cell索引
@property (nonatomic, assign) NSInteger selectedIndex;

// 要展示的字控制器名，如果只传一个则表示重复使用该控制器类
@property (nonatomic, strong) NSArray *displayClasses;

// 控制器缓存
@property (nonatomic, strong) NSMutableDictionary *viewControllerCaches;

// size缓存
@property (nonatomic, strong) NSMutableArray *frameCaches;

// 可供传递的参数
@property (nonatomic, strong) NSArray *params;

@property (nonatomic, strong) NSTimer *graceTimer;

// 选择指示器，下方的小滑块
@property (nonatomic, strong) UIView *selectedIndicator;
@end

@implementation NKScrollPageController

- (instancetype)initWithTagViewHeight:(CGFloat)tagViewHeight
{
    if (self = [super init]) {
        self.tagViewHeight = tagViewHeight;
        
        // 设置tag的默认值
        [self setupDefaultProperties];
        
        // 初始化两个collectionView
        [self setupCollectionView];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // 初始化选中第一项
    if (self.tagTitleModelArray.count != 0) {
        [self resetSelectedIndex];
    }
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tagCollectionView.frame = CGRectMake(0, 0, screenW - self.tagViewHeight, self.tagViewHeight);
    self.pageCollectionView.frame = CGRectMake(0, self.tagViewHeight, screenW, self.view.frame.size.height - self.tagViewHeight);
}

- (void)dealloc
{
    if (self.graceTime != 0) {
        [self.graceTimer invalidate];
        self.graceTimer = nil;
    }
}

- (void)setupDefaultProperties
{
    self.normalTitleFont = [UIFont systemFontOfSize:14];
    self.selectedTitleFont = [UIFont boldSystemFontOfSize:15];
    
    self.normalTitleColor = [UIColor blackColor];
    self.selectedTitleColor = [UIColor blueColor];
    
    self.selectedIndicatorColor = [UIColor blueColor];
    self.tagItemSize = CGSizeZero;
    
    self.selectedIndex = -1;
}

// 设置tag的view，page的view
- (void)setupCollectionView
{
    // 初始化标签布局
    UICollectionViewFlowLayout *tagFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    tagFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    tagFlowLayout.minimumLineSpacing = 0;
    tagFlowLayout.minimumInteritemSpacing = 0;
    self.tagFlowLayout = tagFlowLayout;
    
    // 初始化标签view
    UICollectionView *tagCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:tagFlowLayout];
    [tagCollectionView registerClass:[NKTagTitleCell class] forCellWithReuseIdentifier:kTagCollectionViewCellIdentifier];
    tagCollectionView.backgroundColor = [UIColor whiteColor];
    tagCollectionView.showsHorizontalScrollIndicator = NO;
    tagCollectionView.dataSource = self;
    tagCollectionView.delegate = self;
    self.tagCollectionView = tagCollectionView;
    [self.view addSubview:self.tagCollectionView];
    
    // 初始化页面布局
    UICollectionViewFlowLayout *pageFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    pageFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    pageFlowLayout.minimumInteritemSpacing = 0;
    pageFlowLayout.minimumLineSpacing = 0;
    self.pageFlowLayout = pageFlowLayout;
    
    // 初始化页面view
    UICollectionView *pageCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:pageFlowLayout];
    [pageCollectionView registerClass:[NKPageCell class] forCellWithReuseIdentifier:kPageCollectionViewCellIdentifier];
    pageCollectionView.backgroundColor = [UIColor whiteColor];
    pageCollectionView.showsHorizontalScrollIndicator = NO;
    pageCollectionView.delegate = self;
    pageCollectionView.dataSource = self;
    pageCollectionView.pagingEnabled = YES;
    self.pageCollectionView = pageCollectionView;
    [self.view addSubview:self.pageCollectionView];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tagTitleModelArray.count != 0 ? self.tagTitleModelArray.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item;
    if ([self isTagView:collectionView]) {
        // 如果是tag的view
        NKTagTitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTagCollectionViewCellIdentifier forIndexPath:indexPath];
        NKTagTitleModel *tagTitleModel = self.tagTitleModelArray[index];
        cell.tagTitleModel = tagTitleModel;
        cell.backgroundColor = self.backgroundColor;
        return cell;
    }else
    {
        NKPageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPageCollectionViewCellIdentifier forIndexPath:indexPath];
        // 更新page状态
        Class dispalyClass = (self.displayClasses.count == 1) ? [self.displayClasses firstObject] : self.displayClasses[indexPath.item];
        
        // 取缓存
        UIViewController *cachedViewController = [self getCachedVCByIndexPath:indexPath];
        if (cachedViewController == nil) {
            cachedViewController = [[dispalyClass alloc] init];
        }
        
        // 更新缓存
        [self saveCachedVC:cachedViewController byIndexPath:indexPath];
        
        // 设置参数
        if (self.params.count != 0) {
            if (![cachedViewController valueForKeyPath:@"paramVC"]) {
                [cachedViewController setValue:self.params[indexPath.item] forKeyPath:@"paramVC"];
            }
        }
        
        // 添加子控制器
        [self addChildViewController:cachedViewController];
        cachedViewController.view.backgroundColor = RandomColor;
        // 子控制器的view加到cell的contentView上
        [cell configCellWithController:cachedViewController];
        return cell;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item;
    NKTagTitleModel *tagTitleModel = self.tagTitleModelArray[index];
    if ([self isTagView:collectionView]) {
        if (CGSizeEqualToSize(CGSizeZero, self.tagItemSize)) {
            // 没有手动设置tagSize
            NSString *title = tagTitleModel.tagTitle;
            CGSize titleSize = [self sizeForTitle:title withFont:((tagTitleModel.normalTitleFont.pointSize >= tagTitleModel.selectedTitleFont.pointSize) ? tagTitleModel.normalTitleFont : tagTitleModel.selectedTitleFont)];
            return CGSizeMake(titleSize.width, self.tagViewHeight);
        }else
        {
            return self.tagItemSize;
        }
    }else
    {
        return collectionView.frame.size;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self isTagView:collectionView]) {
        // 选中某个tag
        // 取消当前选中的cell
        [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] animated:YES];
        NSInteger gap = indexPath.item - self.selectedIndex;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (!cell) {
            if (CGSizeEqualToSize(CGSizeZero, self.tagItemSize)) {
                // 没有设置tagItemSize，就根据标题内容计算
                NKLog(@"%@",cell);
                NKTagTitleModel *tagTitleModel = self.tagTitleModelArray[0];
                
                CGSize tagSize = [self sizeForTitle:tagTitleModel.tagTitle withFont:((tagTitleModel.normalTitleFont.pointSize >= tagTitleModel.selectedTitleFont.pointSize) ? tagTitleModel.normalTitleFont : tagTitleModel.selectedTitleFont)];
                
                CGRect frame = self.selectedIndicator.frame;
                frame.size.width = tagSize.width;
                self.selectedIndicator.frame = frame;
            }else
            {
                CGRect frame = self.selectedIndicator.frame;
                frame.size.width = self.tagItemSize.width;
                self.selectedIndicator.frame = frame;
            }
        }else if (self.selectedIndicator.center.x != cell.center.x)
        {
            [UIView animateKeyframesWithDuration:0.4 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
                    CGRect frame = self.selectedIndicator.frame;
                    frame.origin.x = cell.frame.origin.x;
                    frame.size.width = cell.frame.size.width;
                    self.selectedIndicator.frame = frame;
                }];
                
//                [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
//                    CGRect frame = self.selectedIndicator.frame;
//                    frame.size.width = cell.frame.size.width;
//                    self.selectedIndicator.frame = frame;
//                }];
            } completion:^(BOOL finished) {
                
            }];
        }
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        [self.pageCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:(labs(gap) > 1 ? self.gapAnimated : YES)];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isTagView:collectionView]) {
        // tag
    }else
    {
        // page
        // 从缓存中取出实例Controller
        UIViewController *cachedViewController = [self getCachedVCByIndexPath:indexPath];
        if (!cachedViewController) {
            return;
        }
        // 更新缓存时间
        [self saveCachedVC:cachedViewController byIndexPath:indexPath];
        
        // 从父控制器中移除
        [cachedViewController.view removeFromSuperview];
        [cachedViewController removeFromParentViewController];
    }
}

#pragma mark - UIScrollViewDelegate
// 结束拖拽时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 如果拖拽的事pageView
    if (scrollView == self.pageCollectionView) {
        int index = scrollView.contentOffset.x / self.pageCollectionView.frame.size.width;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [self collectionView:self.tagCollectionView didSelectItemAtIndexPath:indexPath];
    }
}

// 当scrollview滚动时调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pageCollectionView.isDragging) {
       
        if (!CGSizeEqualToSize(CGSizeZero, self.tagItemSize)) {
            CGRect frame = self.selectedIndicator.frame;
            frame.origin.x = scrollView.contentOffset.x / screenW * self.tagItemSize.width;
            self.selectedIndicator.frame = frame;
        }else
        {
            
            
            [UIView animateKeyframesWithDuration:0.2 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
                
                UICollectionViewCell *cell = [self.tagCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:(scrollView.contentOffset.x + screenW * 0.5) / screenW inSection:0]];
                CGRect frame = self.selectedIndicator.frame;
                frame.origin.x = cell.frame.origin.x;
                frame.size.width = cell.frame.size.width;
                self.selectedIndicator.frame = frame;
            } completion:^(BOOL finished) {
                
            }];
        }
        
    }
}

#pragma - mark PublicMethod
- (void)reloadDataWith:(NSArray *)titleArray andSubviewDisplayClassed:(NSArray *)classes
{
    [self convertKeyValueToModel:titleArray];
    self.displayClasses = classes;
    [self.tagCollectionView reloadData];
    [self.pageCollectionView reloadData];
    
    [self resetSelectedIndex];
}

- (void)reloadDataWith:(NSArray *)titleArray andSubviewDisplayClassed:(NSArray *)classes andParams:(NSArray *)params
{
    [self convertKeyValueToModel:titleArray];
    self.displayClasses = classes;
    [self.tagCollectionView reloadData];
    [self.pageCollectionView reloadData];
    self.params = params;
    
    // 默认选中第一个tag
    [self resetSelectedIndex];
}

- (void)selectTagByIndex:(NSInteger)index animated:(BOOL)animated
{
    self.selectedIndex = index;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tagCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:animated scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        
        [self.pageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:animated];
    });
}

// 设置默认选中第一个tag
- (void)resetSelectedIndex
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self collectionView:self.tagCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    });
}

// 取缓存控制器
- (UIViewController *)getCachedVCByIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cachedDict = [self.viewControllerCaches objectForKey:@(indexPath.item)];
    UIViewController *cachedVC = [cachedDict objectForKey:kCachedVCName];
    return cachedVC;
}
         
// 更新缓存
- (void)saveCachedVC:(UIViewController *)vc byIndexPath:(NSIndexPath *)indexPath
{
    NSDate *newTime = [NSDate date];
    NSDictionary *newCacheDict = @{kCachedTime : newTime, kCachedVCName : vc};
    [self.viewControllerCaches setObject:newCacheDict forKey:@(indexPath.item)];
}

// 定时更新缓存控制器
- (void)updateViewControllersCaches
{
    NSDate *currentDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *tempDict = self.viewControllerCaches;
    
    [self.viewControllerCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSDictionary *obj, BOOL * stop) {
        UIViewController *vc = [obj objectForKey:kCachedVCName];
        NSDate *cachedTime = [obj objectForKey:kCachedTime];
        NSInteger keyInteger = [key integerValue];
        NSInteger selectionInteger = weakSelf.selectedIndex;
        
        if (keyInteger != selectionInteger) {
            // 不是当前正在展示的cell
            NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:cachedTime];
            if (timeInterval >= weakSelf.graceTime) {
                // 销毁控制器
                [tempDict removeObjectForKey:key];
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
            }
        }
    }];
    self.viewControllerCaches = tempDict;
}

// 判断是否为tagView
- (BOOL)isTagView:(UICollectionView *)collectionView
{
    if (self.tagCollectionView == collectionView) {
        return YES;
    }
    return NO;
}

// 更新tagTitleModelArray中的数据
- (void)convertKeyValueToModel:(NSArray *)titleArray
{
    [self.tagTitleModelArray removeAllObjects];
    for (int i = 0; i < titleArray.count; i ++) {
        NKTagTitleModel *tagTitleModel = [NKTagTitleModel modelWithTagTitle:titleArray[i] andNormalTitleFont:self.normalTitleFont andSelectedTitleFont:self.selectedTitleFont andNormalTitleColor:self.normalTitleColor andSelectedTitleColor:self.selectedTitleColor];
        [self.tagTitleModelArray addObject:tagTitleModel];
    }
}

- (CGSize)sizeForTitle:(NSString *)title withFont:(UIFont *)font
{
    CGSize titleSize = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    return titleSize;
}

#pragma - mark 懒加载
- (NSMutableArray *)tagTitleModelArray
{
    if (!_tagTitleModelArray) {
        _tagTitleModelArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _tagTitleModelArray;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.tagCollectionView.backgroundColor = backgroundColor;
}

- (NSMutableDictionary *)viewControllerCaches
{
    if (!_viewControllerCaches) {
        _viewControllerCaches = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _viewControllerCaches;
}

- (void)setGraceTime:(NSTimeInterval)graceTime
{
    _graceTime = graceTime;
    [self.graceTimer setFireDate:[NSDate distantPast]];
}

- (NSTimer *)graceTimer
{
    if (!_graceTimer) {
        _graceTimer = [NSTimer timerWithTimeInterval:5.f target:self selector:@selector(updateViewControllersCaches) userInfo:nil repeats:YES];
        [_graceTimer setFireDate:[NSDate distantFuture]];
        [[NSRunLoop mainRunLoop] addTimer:_graceTimer forMode:NSDefaultRunLoopMode];
    }
    return _graceTimer;
}

- (NSMutableArray *)frameCaches
{
    if (!_frameCaches) {
        _frameCaches = [NSMutableArray arrayWithCapacity:0];
    }
    return _frameCaches;
}

- (UIView *)selectedIndicator
{
    if (!_selectedIndicator) {
        _selectedIndicator = [[UIView alloc] init];
        _selectedIndicator.backgroundColor = [UIColor clearColor];
        
        // 使用固定的tagItemSize
        if (!CGSizeEqualToSize(CGSizeZero, self.tagItemSize)) {
            if (CGSizeEqualToSize(CGSizeZero, self.selectedIndicatorSize)) {
                self.selectedIndicatorSize = CGSizeMake(self.tagItemSize.width, 2);
            }
            _selectedIndicator.frame = CGRectMake(0, self.tagViewHeight - self.selectedIndicatorSize.height, self.tagItemSize.width, self.selectedIndicatorSize.height);
        }else
        {
            // 使用自由文本宽度，默认设为第一个自由文本的size
            NKTagTitleModel *tagTitleModel = self.tagTitleModelArray[0];
            
            CGSize tagSize = [self sizeForTitle:tagTitleModel.tagTitle withFont:((tagTitleModel.normalTitleFont.pointSize >= tagTitleModel.selectedTitleFont.pointSize) ? tagTitleModel.normalTitleFont : tagTitleModel.selectedTitleFont)];
            
            
            if (CGSizeEqualToSize(CGSizeZero, self.selectedIndicatorSize)) {
                self.selectedIndicatorSize = CGSizeMake(tagSize.width, 2);
            }
            
            _selectedIndicator.frame = CGRectMake(0, self.tagViewHeight - self.selectedIndicatorSize.height, tagSize.width, self.selectedIndicatorSize.height);
        }
        UIView *sub = [[UIView alloc] init];
        sub.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        sub.backgroundColor = self.selectedIndicatorColor;
        sub.frame = CGRectMake(0, 0, self.selectedIndicatorSize.width, self.selectedIndicatorSize.height);
        
        CGPoint subCenter = sub.center;
        CGPoint selectedIndicatorCenter = _selectedIndicator.center;
        subCenter.x = selectedIndicatorCenter.x;
        sub.center = subCenter;
        
        [_selectedIndicator addSubview:sub];
        [self.tagCollectionView addSubview:_selectedIndicator];
    }
    return _selectedIndicator;
}
@end

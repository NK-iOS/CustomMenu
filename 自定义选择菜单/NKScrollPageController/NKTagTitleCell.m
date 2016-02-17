//
//  NKTagTitleCell.m
//  自定义选择菜单
//
//  Created by 聂宽 on 15/12/31.
//  Copyright © 2015年 聂宽. All rights reserved.
//

#import "NKTagTitleCell.h"
#import "NKTagTitleModel.h"

@interface NKTagTitleCell ()
// 标签label
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation NKTagTitleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

/*
 这两个方法一个是设置cell的高亮状态，另一个是设置cell的选中状态，我们只需要在这两个方法里面打印信息就可以看出点击cell时这些状态是怎么变化的了。当我们点击cell的时候，其实是先设置cell的高亮状态为YES，然后松手的时候再将cell的高亮状态设置为NO，接着才是设置cell的选中状态为YES，最后才会去调用delegate中的tableview:didSelectRowAtIndexPath:方法
 */
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.titleLabel.font = self.tagTitleModel.selectedTitleFont;
        self.titleLabel.textColor = self.tagTitleModel.selectedTitleColor;
    }else
    {
        self.titleLabel.font = self.tagTitleModel.normalTitleFont;
        self.titleLabel.textColor = self.tagTitleModel.normalTitleColor;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.titleLabel.font = self.tagTitleModel.selectedTitleFont;
        self.titleLabel.textColor = self.tagTitleModel.selectedTitleColor;
    }else
    {
        self.titleLabel.font = self.tagTitleModel.normalTitleFont;
        self.titleLabel.textColor = self.tagTitleModel.normalTitleColor;
    }
}

- (void)setTagTitleModel:(NKTagTitleModel *)tagTitleModel
{
    _tagTitleModel = tagTitleModel;
    self.titleLabel.text = self.tagTitleModel.tagTitle;
    self.titleLabel.font = self.tagTitleModel.normalTitleFont;
    self.titleLabel.textColor = self.tagTitleModel.normalTitleColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
}

@end

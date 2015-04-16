//
//  ImgTButton.m
//  GITestDemo
//
//  Created by Femto03 on 14/12/2.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "ImgTButton.h"

@implementation ImgTButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
        
    }
    return self;
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initSubViews];
}


- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    _imgView.image = [UIImage imageNamed:_imageName];
}

- (void)setTitext:(NSString *)titext
{
    _titext = titext;
    
    _tLabel.text = _titext;
}


- (void)initSubViews
{
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(23, 10, 60, 60)];
    _imgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_imgView];
    
    _tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imgView.bottom, self.width, 20)];
    _tLabel.backgroundColor = [UIColor clearColor];
    _tLabel.font = [UIFont systemFontOfSize:16];
    _tLabel.textColor = [UIColor darkGrayColor];
    _tLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_tLabel];
    
}


@end

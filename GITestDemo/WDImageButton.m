//
//  WDImageButton.m
//  GITestDemo
//
//  Created by 吴狄 on 15/6/27.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "WDImageButton.h"

@interface WDImageButton (){
    
    UIImageView *_imgView;
    UILabel *_label;
}

@end

@implementation WDImageButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    [self _initSubViews];
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self _initSubViews];
    }
    
    return self;
}

-(void)setImageName:(NSString *)imageName{

    _imageName = imageName;
    _imgView.image = [UIImage imageNamed:imageName];
}

-(void)setText:(NSString *)text{
    _text = text;
    _label.text = text;
}

-(void)_initSubViews{
    
    NSLog(@"%@",self);
    _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 30, 30)];
    
    _imgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_imgView];
    _imgView.center = CGPointMake(self.width/2, self.height/2-10);
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake(0, _imgView.bottom, self.width, 20)];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont systemFontOfSize:10];
    _label.textColor = [UIColor darkGrayColor];
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_label];
    
}


@end

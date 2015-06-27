//
//  WDCalculator.m
//  GITestDemo
//
//  Created by 吴狄 on 15/6/26.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import "WDCalculator.h"
#define Interval 1
#define BtBackgroundColor rgb(229,229,229,1)
@interface WDCalculator (){
    
    float _btWidth;
    float _btHeight;
}

@end

@implementation WDCalculator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self _initData];
    }
    
    return self;
}

-(void)_initData{
    
    _btWidth = (self.frame.size.width - 2 * Interval)/3;
    _btHeight = (self.frame.size.height - 5 * Interval)/4;
    //self.backgroundColor = [UIColor redColor];
    [self _initSubViews];
}


-(void)_initSubViews{
    //1-9
    for (int i = 0; i< 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((Interval + _btWidth)*j, Interval + (Interval + _btHeight)*i,_btWidth, _btHeight);
            
            NSString *num = [NSString stringWithFormat:@"%d.png",i*3+j+1];
            button.backgroundColor = BtBackgroundColor;
            [button setImage:[UIImage imageNamed:num] forState:UIControlStateNormal];
            //button setTitle:num forState:<#(UIControlState)#>
            
            [self addSubview:button];
        }
    }
    
    //C
    UIButton *clearBt = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBt.frame = CGRectMake(0, Interval+(Interval + _btHeight)*3, _btWidth, _btHeight);
    clearBt.backgroundColor = BtBackgroundColor;
    [clearBt setImage:[UIImage imageNamed:@"c"] forState:UIControlStateNormal];
    [self addSubview:clearBt];
    
    //0
    UIButton *zeroBt = [UIButton buttonWithType:UIButtonTypeCustom];
    zeroBt.frame = CGRectMake((Interval + _btWidth), Interval+(Interval + _btHeight)*3, _btWidth, _btHeight);
    zeroBt.backgroundColor = BtBackgroundColor;
    [zeroBt setImage:[UIImage imageNamed:@"0"] forState:UIControlStateNormal];
    [self addSubview:zeroBt];
    
    //+
    UIButton *plusBt = [UIButton buttonWithType:UIButtonTypeCustom];
    plusBt.frame = CGRectMake((Interval + _btWidth)*2, Interval+(Interval + _btHeight)*3, _btWidth, _btHeight);
    plusBt.backgroundColor = BtBackgroundColor;
    [plusBt setImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];
    [self addSubview:plusBt];
}
@end

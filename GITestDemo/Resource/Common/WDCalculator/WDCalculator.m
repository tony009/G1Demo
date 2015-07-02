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
    self.num = 0;
    self.totalNum = 0;
    [self _initSubViews];
}


-(void)_initSubViews{
    //1-9
    for (int i = 0; i< 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((Interval + _btWidth)*j, Interval + (Interval + _btHeight)*i,_btWidth, _btHeight);
            NSString *num = [NSString stringWithFormat:@"%d",i*3+j+1];
            button.backgroundColor = BtBackgroundColor;
            [button setImage:[UIImage imageNamed:num] forState:UIControlStateNormal];
            button.tag = i*3+j+1;
            [button addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
    }
    
    //C
    UIButton *clearBt = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBt.frame = CGRectMake(0, Interval+(Interval + _btHeight)*3, _btWidth, _btHeight);
    clearBt.backgroundColor = BtBackgroundColor;
    [clearBt setImage:[UIImage imageNamed:@"c"] forState:UIControlStateNormal];
    clearBt.tag = 10;
    [clearBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearBt];
    
    //0
    UIButton *zeroBt = [UIButton buttonWithType:UIButtonTypeCustom];
    zeroBt.frame = CGRectMake((Interval + _btWidth), Interval+(Interval + _btHeight)*3, _btWidth, _btHeight);
    zeroBt.backgroundColor = BtBackgroundColor;
    [zeroBt setImage:[UIImage imageNamed:@"0"] forState:UIControlStateNormal];
    zeroBt.tag = 0;
    [zeroBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zeroBt];
    
    //+
    UIButton *plusBt = [UIButton buttonWithType:UIButtonTypeCustom];
    plusBt.frame = CGRectMake((Interval + _btWidth)*2, Interval+(Interval + _btHeight)*3, _btWidth, _btHeight);
    plusBt.backgroundColor = BtBackgroundColor;
    [plusBt setImage:[UIImage imageNamed:@"+"] forState:UIControlStateNormal];
    plusBt.tag = 11;
    [plusBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:plusBt];
}


-(void)btAction:(UIButton *)button{
    
    if (button.tag == 10) { //清零
        
        if (self.num == 0) {
            
            self.totalNum = 0;
            
        }else{
            self.totalNum -= self.num;
            self.num  = 0;
        }

    }else if (button.tag == 11) { //+
        self.num =  0;
    }else {
        
        self.totalNum -= self.num;
        self.num = self.num * 10 + button.tag*0.01;
        if (self.num >999999.99) {
            self.num = 999999.99;
        }
        self.totalNum +=self.num;
        if (self.totalNum > 9999999.99) {
            self.totalNum = 9999999.99;
        }
        
    }
    
    
    
    if ([self.delegate respondsToSelector:@selector(WDCalculatorDidClick:)]) {
        [self.delegate WDCalculatorDidClick:self];
    }
    
}
@end

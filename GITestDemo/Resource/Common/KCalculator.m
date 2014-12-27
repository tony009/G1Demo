//
//  KCalculator.m
//  CalculatorTest
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import "KCalculator.h"
#define kMarg 2


@implementation KCalculator

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
        NSLog(@"awakeFromNib:self.frame.size.width:%f,self.frame.size.height:%f",self.frame.size.width,self.frame.size.height);
    [self _initData];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self _initData];
    }
    
    return self;
}

- (void)_initData
{
    btWith = (self.frame.size.width-5*kMarg)/4;
    btHeight = (self.frame.size.height - 6*kMarg)/5;
    proNumArray = [[NSMutableArray alloc] init];
    proNum = [[NSMutableArray alloc] init];
    needNumber = YES;
    [self _initSubViews];
}

- (void)_initSubViews
{
    //清零
    UIButton *clearBt = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBt.frame = CGRectMake(kMarg, kMarg, btWith, btHeight);
    clearBt.backgroundColor = [UIColor lightGrayColor];
    [clearBt setTitle:@"C" forState:UIControlStateNormal];
    [clearBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clearBt];
    
    
    //删除
    UIButton *delBt = [UIButton buttonWithType:UIButtonTypeCustom];
    delBt.frame = CGRectMake(kMarg*2+btWith, kMarg, btWith, btHeight);
    delBt.backgroundColor = [UIColor lightGrayColor];
    [delBt setTitle:@"DEL" forState:UIControlStateNormal];
    [delBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:delBt];
    
    
    //除
    UIButton *divisionBt = [UIButton buttonWithType:UIButtonTypeCustom];
    divisionBt.frame = CGRectMake(kMarg*3+btWith*2, kMarg, btWith, btHeight);
    divisionBt.backgroundColor = [UIColor lightGrayColor];
    [divisionBt setTitle:@"/" forState:UIControlStateNormal];
    [divisionBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:divisionBt];
    
    //乘
    UIButton *mulBt = [UIButton buttonWithType:UIButtonTypeCustom];
    mulBt.frame = CGRectMake(kMarg*4+btWith*3, kMarg, btWith, btHeight);
    mulBt.backgroundColor = [UIColor lightGrayColor];
    [mulBt setTitle:@"x" forState:UIControlStateNormal];
    [mulBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mulBt];
    
    //1-9
    for (int i = 0; i< 3; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(kMarg+(kMarg+btWith)*j, (btHeight+kMarg*2)+(kMarg+btHeight)*i, btWith, btHeight);
            button.backgroundColor = [UIColor lightGrayColor];
            [button setTitle:[NSString stringWithFormat:@"%d",i*3+j+1] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
  
    }
    
    //-
    UIButton *minusBt = [UIButton buttonWithType:UIButtonTypeCustom];
    minusBt.frame = CGRectMake(kMarg*4+btWith*3, kMarg*2+btHeight, btWith, btHeight);
    minusBt.backgroundColor = [UIColor lightGrayColor];
    [minusBt setTitle:@"-" forState:UIControlStateNormal];
    [minusBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:minusBt];
    
    //+
    UIButton *plusBt = [UIButton buttonWithType:UIButtonTypeCustom];
    plusBt.frame = CGRectMake(kMarg*4+btWith*3, kMarg*3+btHeight*2, btWith, btHeight);
    plusBt.backgroundColor = [UIColor lightGrayColor];
    [plusBt setTitle:@"+" forState:UIControlStateNormal];
    [plusBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:plusBt];
    
    //=
    UIButton *inequalityBt = [UIButton buttonWithType:UIButtonTypeCustom];
    inequalityBt.frame = CGRectMake(kMarg*4+btWith*3, kMarg*4+btHeight*3, btWith, btHeight*2+kMarg);
    inequalityBt.backgroundColor = [UIColor lightGrayColor];
    [inequalityBt setTitle:@"=" forState:UIControlStateNormal];
    [inequalityBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:inequalityBt];
    
    //0
    UIButton *zeroBt = [UIButton buttonWithType:UIButtonTypeCustom];
    zeroBt.frame = CGRectMake(kMarg, kMarg*5+btHeight*4, btWith*2+kMarg, btHeight);
    zeroBt.backgroundColor = [UIColor lightGrayColor];
    [zeroBt setTitle:@"0" forState:UIControlStateNormal];
    [zeroBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:zeroBt];
    
    
    //.
    UIButton *pointBt = [UIButton buttonWithType:UIButtonTypeCustom];
    pointBt.frame = CGRectMake(kMarg*3+btWith*2, kMarg*5+btHeight*4, btWith, btHeight);
    pointBt.backgroundColor = [UIColor lightGrayColor];
    [pointBt setTitle:@"." forState:UIControlStateNormal];
    [pointBt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:pointBt];
}


- (void)btAction:(UIButton *)button
{
    
    NSString *btTitle = button.titleLabel.text;
    
    if ([self isCorrectNumber:btTitle]) { //0-9
        needNumber = NO;
        [proNum addObject:btTitle];
    }
    
    if ([btTitle isEqualToString:@"C"]) { //清零
        self.sumString = nil;
        needNumber = YES;
        [proNumArray removeAllObjects];
        [proNum removeAllObjects];
        lastMark = nil;
        
        
    }
    
    if ([btTitle isEqualToString:@"DEL"]) { //删除
        
        if (lastMark == nil) {
            return;
        }
        
        if (proNum.count == 0 && proNumArray.count == 0 ) {
            return;
        }
        
        if ([lastMark isEqualToString:@"/"] || [lastMark isEqualToString:@"x"] || [lastMark isEqualToString:@"+"] || [lastMark isEqualToString:@"-"]) {
            if (proNumArray.count > 0) {
                [proNumArray removeLastObject];
                NSString *string = [proNumArray lastObject];
                lastMark = [string substringFromIndex:string.length-1];
                needNumber = NO;
                
            }
        } else {
            
            if (proNum.count > 0) {
                [proNum removeLastObject];
                
                if (proNum.count > 0) {
                    lastMark = proNum.lastObject;
                } else {
                    if (proNumArray.count > 0) {
                        lastMark = [proNumArray lastObject];
                    } else {
                        lastMark = nil;
                    }
                }
            }
        }
        
       
        
        
    }
    
    
    if ([btTitle isEqualToString:@"/"] || [btTitle isEqualToString:@"x"] || [btTitle isEqualToString:@"-"] || [btTitle isEqualToString:@"+"]) { //加减乘除
        
        if (needNumber) {
            return;
        }
        
        if (proNum.count != 0) {
            [proNumArray addObject:[self stringByArray:proNum]];
        }
        
        [proNumArray addObject:btTitle];
        
        [proNum removeAllObjects];
        
        needNumber = YES;
        
      
        
    }
    
    
//    
//    if ([btTitle isEqualToString:@"x"]) { //乘
//        pointEnter = NO;
//        lastMark = btTitle;
//        [proMarkArray addObject:btTitle];
//        NSNumber *num = [self numberByArray:proNum];
//        [proNum addObject:num];
//        [proNum removeAllObjects];
//    }
//    
//    
//    if ([btTitle isEqualToString:@"-"]) { //减
//        pointEnter = NO;
//        lastMark = btTitle;
//        [proMarkArray addObject:btTitle];
//        NSNumber *num = [self numberByArray:proNum];
//        [proNumArray addObject:num];
//        [proNum removeAllObjects];
//        
//    }
//    
//    if ([btTitle isEqualToString:@"+"]) { //加
//        pointEnter = NO;
//        lastMark = btTitle;
//        [proMarkArray addObject:btTitle];
//        
//        NSNumber *num = [self numberByArray:proNum];
//        [proNumArray addObject:num];
//        [proNum removeAllObjects];
//    }
    
    
    if ([btTitle isEqualToString:@"."]) { //点
        if (needNumber) {
            return;
        }
        
        [proNum addObject:btTitle];
        
        needNumber = YES;
        
    }
    
    
    
    
    //记录过程数据
    NSMutableString *string = [[NSMutableString alloc] init];
    if (proNumArray.count > 0) {
        for (int i = 0; i<proNumArray.count; i++) {
            [string appendString:[proNumArray objectAtIndex:i]];
        }
    }
    
    if (proNum.count > 0) {
        [string appendString:[self stringByArray:proNum]];
    }
    
    self.progressString = string;

    
    
    if ([btTitle isEqualToString:@"="]) { //等于

        if (needNumber) {
            if ([lastMark isEqualToString:@"."]) {
                [proNum removeLastObject];
            } else {
                [proNumArray removeLastObject];
            }
        }
        
        if (proNum.count > 0) {
            [proNumArray addObject:[self stringByArray:proNum]];
            [proNum removeAllObjects];
        }
        
        
        //乘除法
        for (int i = 0; i < proNumArray.count; i++) {
            NSString *str = [proNumArray objectAtIndex:i];
            if ([str isEqualToString:@"x"]) {
                float beforNum = [[proNumArray objectAtIndex:i-1] floatValue];
                float laterNum = [[proNumArray objectAtIndex:i+1] floatValue];
                float sum = beforNum*laterNum;
                
                [proNumArray replaceObjectAtIndex:i-1 withObject:@"0"];
                [proNumArray replaceObjectAtIndex:i withObject:@"+"];
                [proNumArray replaceObjectAtIndex:i+1 withObject:[NSString stringWithFormat:@"%f",sum]];
            }
            
            
            if ([str isEqualToString:@"/"]) {
                float beforNum = [[proNumArray objectAtIndex:i-1] floatValue];
                float laterNum = [[proNumArray objectAtIndex:i+1] floatValue];
                float sum = beforNum/laterNum;
                
                [proNumArray replaceObjectAtIndex:i-1 withObject:@"0"];
                [proNumArray replaceObjectAtIndex:i withObject:@"+"];
                [proNumArray replaceObjectAtIndex:i+1 withObject:[NSString stringWithFormat:@"%f",sum]];
            }
            

            
        }
        
        //加减法
        for (int i = 0; i < proNumArray.count; i++) {
            
            NSString *str = [proNumArray objectAtIndex:i];
            if ([str isEqualToString:@"+"]) {
                float beforNum = [[proNumArray objectAtIndex:i-1] floatValue];
                float laterNum = [[proNumArray objectAtIndex:i+1] floatValue];
                float sum = beforNum+laterNum;
                
                [proNumArray replaceObjectAtIndex:i-1 withObject:@"0"];
                [proNumArray replaceObjectAtIndex:i withObject:@"+"];
                [proNumArray replaceObjectAtIndex:i+1 withObject:[NSString stringWithFormat:@"%f",sum]];
            }
            
            
            if ([str isEqualToString:@"-"]) {
                float beforNum = [[proNumArray objectAtIndex:i-1] floatValue];
                float laterNum = [[proNumArray objectAtIndex:i+1] floatValue];
                float sum = beforNum-laterNum;
                
                [proNumArray replaceObjectAtIndex:i-1 withObject:@"0"];
                [proNumArray replaceObjectAtIndex:i withObject:@"+"];
                [proNumArray replaceObjectAtIndex:i+1 withObject:[NSString stringWithFormat:@"%f",sum]];
            }
        }
        
        allSum = [[proNumArray lastObject] floatValue];
        
        
        [proNumArray removeAllObjects];
        [proNumArray addObject:[NSString stringWithFormat:@"%.1f",allSum]];
        self.progressString = [NSString stringWithFormat:@"%@=",self.progressString];
        self.sumString = [NSString stringWithFormat:@"%.1f",allSum];
        NSLog(@"allSum = %f",allSum);
        
    }
    
    
    if (proNumArray.count == 0 && proNum.count > 0) {
        self.sumString = @"";
        for (int i =0;  i < proNum.count; i++) {
            self.sumString = [NSString stringWithFormat:@"%@%@",self.sumString,proNum[i]];
        }
        
        
    }

    
    NSLog(@"proNumArray = %@",proNumArray);

    if (![btTitle isEqualToString:@"DEL"] && ![btTitle isEqualToString:@"C"]) {
         lastMark = btTitle;
    }
    
    
    [self outputAction];
    
    
   
}


- (BOOL)isCorrectNumber:(NSString*)numer
{
    const char *str = numer.UTF8String;
    int len = numer.length;
    
    if(len<=0)
        return FALSE;
    
    for(int i=0;i<len;i++)
    {
        if(str[i]<'0'||str[i]>'9')
        {
            return FALSE;
        }
    }
    
    return TRUE;
}


- (NSString *)stringByArray:(NSArray *)array
{
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i = 0; i < array.count; i++) {
        [str appendString:array[i]];
    }
    
//    NSNumber *number = [NSNumber numberWithFloat:[str floatValue]];
    return str;
}


- (void)outputAction
{
    
    if ([self.delegate respondsToSelector:@selector(kCalculatorDidClick:)]) {
        [self.delegate kCalculatorDidClick:self];
    }

}


@end

//
//  KCalculator.h
//  CalculatorTest
//
//  Created by Femto03 on 14/11/26.
//  Copyright (c) 2014年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KCalculator;
@protocol kCalculatorDelegate <NSObject>

- (void)kCalculatorDidClick:(KCalculator *)kCalculator;

@end


@interface KCalculator : UIView
{
    NSMutableArray *proNumArray;
    NSMutableArray *proNum;
    
    float allSum;
    
    NSString *lastMark;
    
    
    BOOL needNumber;
    
    float btWith;
    float btHeight;
}


@property (nonatomic, copy) NSString *progressString;
@property (nonatomic, copy) NSString *sumString;
@property (nonatomic,  assign) id <kCalculatorDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

@end

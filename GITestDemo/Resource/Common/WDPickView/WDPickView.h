//
//  WDPickView.h
//  GITestDemo
//
//  Created by 吴狄 on 15/4/17.
//  Copyright (c) 2015年 Kyson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  WDPickView;
@protocol WDPickViewDelegate <NSObject>

@optional
-(void)toolBarDoneBtnHaveClicked:(WDPickView *)pickView resultString:(NSString *)resultString;

@end

@interface WDPickView : UIView

@property(nonatomic,weak) id<WDPickViewDelegate> delegate;

/**
 *   移除本控件
 */
-(void)remove;
/**
 *  显示本控件
 */
-(void)show;


-(instancetype)initPickViewWithPlistName:(NSString *)plistName;

@end

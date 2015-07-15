//
//  ImgTButton.h
//  GITestDemo
//
//  Created by wudi on 15/07/15.
//  Copyright (c) 2015年 Yogia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgTButton : UIButton
{
    
    UIImageView *_imgView;
    UILabel *_tLabel;
    
}

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *titext;


@end

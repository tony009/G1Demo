//
//  ImgTButton.h
//  GITestDemo
//
//  Created by Femto03 on 14/12/2.
//  Copyright (c) 2014年 Kyson. All rights reserved.
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

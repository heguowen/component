//
//  UIOutlinedButton.h
//  fonttest
//
//  Created by neil on 2017/2/28.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAOutlinedButton : UIButton

@property (nonatomic, assign) CGFloat letterSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;


@property (nonatomic, assign) IBInspectable CGFloat strokeSize;
@property (nonatomic, strong) IBInspectable UIColor *strokeColor;

@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, assign) BOOL automaticallyAdjustTextInsets;


@property (nonatomic) UIImageView *firstImgView;
@property (nonatomic) UIImageView *secondImgView;
@property (nonatomic) UIImageView *thirdImgView;
@property (nonatomic) UIImageView *clipImgView;


@end

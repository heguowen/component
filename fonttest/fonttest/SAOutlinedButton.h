//
//  UIOutlinedButton.h
//  fonttest
//
//  Created by neil on 2017/2/28.
//  Copyright © 2017年 neil. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAOutlinedButton : UIButton

@property (nonatomic, assign) IBInspectable CGFloat strokeSize;
@property (nonatomic, strong) IBInspectable UIColor *strokeColor;

@end

//
//  SAFontStyle.h
//  GRFoundation
//
//  Created by neil on 2017/2/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SAFontStyle : NSObject


+ (instancetype)defaultStyle;


- (void)registerFont;
//- (BOOL)supportFontCustom;

- (UIFont *)fontWithSize:(CGFloat)fontSize;


//+ (void)printAllFonts;

@end

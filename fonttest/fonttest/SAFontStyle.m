//
//  SAFontStyle.m
//  GRFoundation
//
//  Created by neil on 2017/2/13.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "SAFontStyle.h"
#import <CoreText/CoreText.h>
//方正艺黑简体
static NSString *FZYiHei_Simple = @"FZYiHei-M20S";

@interface SAFontStyle ()
{
    BOOL _supportFontCustom;
    NSBundle *_bundle;
    UIFont *_font;
}
@end

@implementation SAFontStyle

+ (instancetype)defaultStyle {
    static SAFontStyle *style;
    if (!style) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            style = [[SAFontStyle alloc] init];
        });
    }
    return style;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _bundle = [NSBundle mainBundle];
        _supportFontCustom = NO;
    }
    return self;
}


- (void)registerFont {

    
    NSString *fontPath = [_bundle pathForResource:@"FZYiHei_Simple" ofType:@".TTF"];
    NSData *fontData = [NSData dataWithContentsOfFile:fontPath];
    if (!fontData) {
        return;
    }
    CFErrorRef error;
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontData);
    CGFontRef fontRef = CGFontCreateWithDataProvider(providerRef);
    if (!CTFontManagerRegisterGraphicsFont(fontRef, &error)) {
        //注册失败
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    } else {
        CFStringRef fontNameRef = CGFontCopyPostScriptName(fontRef);
        UIFont *font = [UIFont fontWithName:(__bridge NSString *)fontNameRef size:12];
        _font = font;
        
        CFRelease(fontNameRef);
        
        //上面所有异常检查都通过的话，就说明支持自定义字体
    }
    _supportFontCustom = YES;

    
    CFRelease(fontRef);
    CFRelease(providerRef);
}


- (BOOL)supportFontCustom {
    return _supportFontCustom;
}

- (UIFont *)fontWithSize:(CGFloat)fontSize {
//    if (![self supportFontCustom] || !_font) {
//        return [UIFont systemFontOfSize:fontSize];
//    }
//    return [_font fontWithSize:fontSize];
    
    UIFont *font = [UIFont fontWithName:FZYiHei_Simple size:fontSize];
    //判断前面字体注册是否成功
    BOOL fontLoadSuccess = font && ([font.familyName isEqualToString:FZYiHei_Simple] || [font.fontName isEqualToString:FZYiHei_Simple]);
    if (fontLoadSuccess) {
        return font;
    }
    return [UIFont systemFontOfSize:fontSize];
}

//+ (void)printAllFonts
//{
//    NSArray *fontFamilies = [UIFont familyNames];
//    for (NSString *fontFamily in fontFamilies)
//    {
//        NSArray *fontNames = [UIFont fontNamesForFamilyName:fontFamily];
//        NSLog (@"%@: %@", fontFamily, fontNames);
//    }
//}

@end

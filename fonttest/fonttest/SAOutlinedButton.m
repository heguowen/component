//
//  UIOutlinedButton.m
//  fonttest
//
//  Created by neil on 2017/2/28.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "SAOutlinedButton.h"
#import <CoreText/CoreText.h>

@interface SAOutlinedButton ()
@property (nonatomic, assign) CGFloat letterSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, assign) BOOL automaticallyAdjustTextInsets;

@end

@implementation SAOutlinedButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    [self setNeedsDisplay];
}
static NSMutableDictionary *imageBufferDict;

- (void)setDefaults {
    
    if (!imageBufferDict) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            imageBufferDict = [NSMutableDictionary dictionaryWithCapacity:8];
        });
    }
    
    self.clipsToBounds = YES;
    self.letterSpacing = 0.0;
    self.automaticallyAdjustTextInsets = YES;
}

#pragma mark - Accessors and Mutators
- (void)setTextInsets:(UIEdgeInsets)textInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(self.textInsets, textInsets)) {
        _textInsets = textInsets;
        [self setNeedsDisplay];
    }
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    if (!self.titleLabel.text || [self.titleLabel.text isEqualToString:@""]) {
        return;
    }

    UIImage *imageCache = [imageBufferDict objectForKey:self.titleLabel.text];
    if (imageCache) {
        [super setTitle:nil forState:self.state];
        [self setImage:imageCache forState:self.state];
        return;
    }
    
    //加了描边之后，之前label的宽度要稍微加宽
    CGFloat fontWidth = [self.titleLabel.text boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.titleLabel.font} context:nil].size.width;
    
    CGRect labelRect = self.titleLabel.frame;
    CGSize size = labelRect.size;
    size.width = fontWidth + self.strokeSize * 2;
    labelRect.size = size;
    
    UIGraphicsBeginImageContextWithOptions(labelRect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return;
    }
    
    CGRect textRect;
    CTFrameRef frameRef = [self frameRefFromSize:labelRect.size textRectOutput:&textRect];
    
    //Core Graphic坐标系和ios的不一样，要做旋转
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(labelRect));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //得到原始字体
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    CGContextSetLineWidth(context, self.strokeSize * 2);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    [[UIColor clearColor] setStroke];
    CTFrameDraw(frameRef, context);
    CGContextRestoreGState(context);

    //得到原始字体的图片
    CGContextSaveGState(context);
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    CGImageRef image = NULL;
    image = CGBitmapContextCreateImage(context);

    //得到描边图片
    labelRect.origin = CGPointZero;
    CGImageRef strokeImage = [self strokeImageWithRect:labelRect frameRef:frameRef strokeSize:self.strokeSize*2  strokeColor:self.strokeColor];
    
    //将描边图片绘制到上下文中
    CGContextDrawImage(context, labelRect, strokeImage);
    
    //将原始字体绘制到上下文中
    CGContextDrawImage(context, labelRect, image);
    
    CGImageRelease(strokeImage);
    CGImageRelease(image);
        
    CGContextRestoreGState(context);
    
    //取出上下文中的组合图片，也就是原始字体和描边字体的组合
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //由于UIButton的title和background Image会挡住绘制的部分，所以这里直接将描边的字体设置为图片
    if (resultImage) {
        [imageBufferDict setObject:resultImage forKey:self.titleLabel.text];
        [super setTitle:nil forState:self.state];
        [self setImage:resultImage forState:self.state];
    }
    
    CFRelease(frameRef);
}

- (CTFrameRef)frameRefFromSize:(CGSize)size textRectOutput:(CGRect *)textRectOutput CF_RETURNS_RETAINED {
    // Set up font.
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.titleLabel.font.fontName, self.titleLabel.font.pointSize, NULL);
    CTTextAlignment alignment = NSTextAlignmentToCTTextAlignment(NSTextAlignmentLeft);
    CTLineBreakMode lineBreakMode = (CTLineBreakMode)self.titleLabel.lineBreakMode;
    CGFloat lineSpacing = self.lineSpacing;
    CTParagraphStyleSetting paragraphStyleSettings[] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &alignment},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
        {kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof(CGFloat), &lineSpacing}
    };
    CTParagraphStyleRef paragraphStyleRef = CTParagraphStyleCreate(paragraphStyleSettings, 3);
    CFNumberRef kernRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberCGFloatType, &_letterSpacing);
    
    // Set up attributed string.
    CFStringRef keys[] = {kCTFontAttributeName, kCTParagraphStyleAttributeName, kCTForegroundColorAttributeName, kCTKernAttributeName};
    CFTypeRef values[] = {fontRef, paragraphStyleRef, self.currentTitleColor.CGColor, kernRef};
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void **)&keys, (const void **)&values, sizeof(keys) / sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFRelease(fontRef);
    CFRelease(paragraphStyleRef);
    CFRelease(kernRef);
    
    CFStringRef stringRef = (CFStringRef)CFBridgingRetain(self.titleLabel.text);
    CFAttributedStringRef attributedStringRef = CFAttributedStringCreate(kCFAllocatorDefault, stringRef, attributes);
    CFRelease(stringRef);
    CFRelease(attributes);
    
    // Set up frame.
    CTFramesetterRef framesetterRef = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRelease(attributedStringRef);
    
    if (self.automaticallyAdjustTextInsets) {
        self.textInsets = [self fittingTextInsets];
    }
    CGRect contentRect = [self contentRectFromSize:size withInsets:self.textInsets];
    CGRect textRect = [self textRectFromContentRect:contentRect framesetterRef:framesetterRef];
    if (textRectOutput) {
        *textRectOutput = textRect;
    }
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, NULL, textRect);
    
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetterRef, CFRangeMake(0, self.titleLabel.text.length), pathRef, NULL);
    CFRelease(framesetterRef);
    CGPathRelease(pathRef);
    return frameRef;
}

- (CGRect)contentRectFromSize:(CGSize)size withInsets:(UIEdgeInsets)insets {
    CGRect contentRect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    // Apply insets.
    contentRect.origin.x += insets.left;
    contentRect.origin.y += insets.top;
    contentRect.size.width -= insets.left + insets.right;
    contentRect.size.height -= insets.top + insets.bottom;
    
    return contentRect;
}

- (CGRect)textRectFromContentRect:(CGRect)contentRect framesetterRef:(CTFramesetterRef)framesetterRef {
    CGSize suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, self.titleLabel.text.length), NULL, contentRect.size, NULL);
    if (CGSizeEqualToSize(suggestedTextRectSize, CGSizeZero)) {
        suggestedTextRectSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetterRef, CFRangeMake(0, self.titleLabel.text.length), NULL, CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX), NULL);
    }
    CGRect textRect = CGRectMake(0.0, 0.0, ceilf(suggestedTextRectSize.width), ceilf(suggestedTextRectSize.height));
    
    // Horizontal alignment.
    switch (self.titleLabel.textAlignment) {
        case NSTextAlignmentCenter:
            textRect.origin.x = floorf(CGRectGetMinX(contentRect) + (CGRectGetWidth(contentRect) - CGRectGetWidth(textRect)) / 2.0);
            break;
            
        case NSTextAlignmentRight:
            textRect.origin.x = floorf(CGRectGetMinX(contentRect) + CGRectGetWidth(contentRect) - CGRectGetWidth(textRect));
            break;
            
        default:
            textRect.origin.x = floorf(CGRectGetMinX(contentRect));
            break;
    }
    
    // Vertical alignment. Top and bottom are upside down, because of inverted drawing.
    switch (self.contentMode) {
        case UIViewContentModeTop:
        case UIViewContentModeTopLeft:
        case UIViewContentModeTopRight:
            textRect.origin.y = floorf(CGRectGetMinY(contentRect) + CGRectGetHeight(contentRect) - CGRectGetHeight(textRect));
            break;
            
        case UIViewContentModeBottom:
        case UIViewContentModeBottomLeft:
        case UIViewContentModeBottomRight:
            textRect.origin.y = floorf(CGRectGetMinY(contentRect));
            break;
            
        default:
            textRect.origin.y = floorf(CGRectGetMinY(contentRect) + floorf((CGRectGetHeight(contentRect) - CGRectGetHeight(textRect)) / 2.0));
            break;
    }
    
    return textRect;
}

- (UIEdgeInsets)fittingTextInsets {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(self.strokeSize, self.strokeSize, self.strokeSize, self.strokeSize);
    return edgeInsets;
}

#pragma mark - Image Functions
- (CGImageRef)strokeImageWithRect:(CGRect)rect frameRef:(CTFrameRef)frameRef strokeSize:(CGFloat)strokeSize strokeColor:(UIColor *)strokeColor CF_RETURNS_RETAINED {
    // Create context.
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Draw clipping mask.
    CGContextSetLineWidth(context, strokeSize);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    [[UIColor whiteColor] setStroke];
    CTFrameDraw(frameRef, context);
    
    // Save clipping mask.
    CGImageRef clippingMask = CGBitmapContextCreateImage(context);
    // Clear the content.
    CGContextClearRect(context, rect);
    // Draw stroke.
    CGContextClipToMask(context, rect, clippingMask);
    CGContextTranslateCTM(context, 0.0, CGRectGetHeight(rect));
    CGContextScaleCTM(context, 1.0, -1.0);
    [strokeColor setFill];
    UIRectFill(rect);
    
    // Clean up and return image.
    CGImageRelease(clippingMask);
    CGImageRef image = CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    return image;
}

@end

//
//  UIOutlinedLabel.m
//  fonttest
//
//  Created by neil on 2017/2/14.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "UIOutlinedLabel.h"

@interface UIOutlinedLabel ()

@property (nonatomic, assign) CGFloat outlineWidth;
@property (nonatomic, strong) UIColor *outlineColor;

@end

@implementation UIOutlinedLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.outlineWidth = 4;
        self.outlineColor = [UIColor blackColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.outlineWidth = 4;
        self.outlineColor = [UIColor redColor];
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    NSDictionary *strokeTextAttributes = @{NSStrokeColorAttributeName : _outlineColor,
                                           NSStrokeWidthAttributeName : @(-1 * _outlineWidth),};
    self.attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:strokeTextAttributes];
    [super drawTextInRect:rect];
}

@end

//
//  ViewController.m
//  fonttest
//
//  Created by neil on 2017/2/13.
//  Copyright © 2017年 neil. All rights reserved.
//

#import "ViewController.h"
#import "SAFontStyle.h"
#import "SAOutlinedButton.h"

static NSString *FZYiHei_Simple = @"FZYiHei-M20S";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *codeFontLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clipImgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [[SAFontStyle defaultStyle] registerFont];
    
    SAOutlinedButton *button = [SAOutlinedButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 69, 40);
    [button setTitle:@"故事的开头" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    button.strokeColor = [UIColor blackColor];
    button.strokeSize = 1;
    button.firstImgView = self.firstImageView;
    button.secondImgView = self.secondImageView;
    button.thirdImgView = self.thirdImageView;
    button.clipImgView = self.clipImgView;
    [self.view addSubview:button];
}

- (IBAction)onButtonClick:(id)sender {
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

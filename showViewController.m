//
//  showViewController.m
//  TestEmoDemo
//
//  Created by Bizapper VM MacOS  on 15/11/11.
//  Copyright (c) 2015年 Bizapper VM MacOS . All rights reserved.
//

#import "showViewController.h"

@interface showViewController ()

@end

@implementation showViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view .backgroundColor = [UIColor whiteColor];
    //  [self.view addSubview:self.textBackImageView];
    self.emojiLabel = _lab;
    self.emojiLabel.frame = CGRectMake(50, 100, 250, 100);
    [_emojiLabel sizeToFit];
    
    CGRect backFrame = self.emojiLabel.frame;
    backFrame.origin.x -= 18;
    backFrame.size.width += 18+10+5;
    backFrame.origin.y -= 13;
    backFrame.size.height += 13+13+7;
    //self.textBackImageView.frame = backFrame;
    _emojiLabel.backgroundColor = [UIColor greenColor];
    
    [self initEmojiLabel];
}
- (MLEmojiLabel *)emojiLabel
{
    if (!_emojiLabel) {
        _emojiLabel = [[MLEmojiLabel alloc]init];
        _emojiLabel.numberOfLines = 0;
        _emojiLabel.font = [UIFont systemFontOfSize:14.0f];
        NSLog(@"%f",_emojiLabel.font.lineHeight);
        _emojiLabel.emojiDelegate = self;
        _emojiLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _emojiLabel.isNeedAtAndPoundSign = YES;
        
        _emojiLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
//        _emojiLabel.customEmojiPlistName = @"expression.plist";
            _emojiLabel.customEmojiPlistName = @"_expression_cn.plist";

        [_emojiLabel setEmojiText:@""];
    }
    else{
        _emojiLabel.frame = CGRectMake(35, 100, 250, 30);
    }
    return _emojiLabel;
}

-(void)initEmojiLabel{
    
    [self emojiLabel];
    [_emojiLabel setEmojiText:_contents];
    //得到值以后要重新设置label的大小（根据值来设定）
    [_emojiLabel sizeToFit];
    // [self.view addSubview:_emojiLabel];
}
#pragma MLEmojiLabel

//背景图
- (UIImageView *)textBackImageView
{
    if (!_textBackImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = [[UIImage imageNamed:@"chatBubble_Sending_Solid@2x.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(28, 18, 25, 10)] ;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.clipsToBounds = YES;
        
        _textBackImageView = imageView;
    }
    return _textBackImageView;
}

@end

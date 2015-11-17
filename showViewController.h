//
//  showViewController.h
//  TestEmoDemo
//
//  Created by Bizapper VM MacOS  on 15/11/11.
//  Copyright (c) 2015年 Bizapper VM MacOS . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"
@interface showViewController : UIViewController <MLEmojiLabelDelegate>
@property(nonatomic,strong)MLEmojiLabel *emojiLabel;

@property (weak, nonatomic) IBOutlet MLEmojiLabel *lab;
@property (nonatomic, strong) UIImageView *textBackImageView;

@property(nonatomic,strong) NSString *contents;

@end

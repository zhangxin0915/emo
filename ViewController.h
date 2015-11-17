//
//  ViewController.h
//  TestEmoDemo
//
//  Created by Bizapper VM MacOS  on 15/11/11.
//  Copyright (c) 2015年 Bizapper VM MacOS . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageListCell.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *messageListView;
@property (weak, nonatomic) IBOutlet UIButton *boardBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIView *toolBar;

@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)clickBoardBtn:(UIButton *)sender;
- (IBAction)clickPhotoBtn:(UIButton *)sender;
- (IBAction)clickSendBtn:(UIButton *)sender;

@property (nonatomic, retain) IBOutlet MessageListCell *tmpCell;

@property (nonatomic, retain) UINib *cellNib;

@end


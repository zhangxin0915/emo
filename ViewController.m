//
//  ViewController.m
//  TestEmoDemo
//
//  Created by Bizapper VM MacOS  on 15/11/11.
//  Copyright (c) 2015年 Bizapper VM MacOS . All rights reserved.
//
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define keyBoardHeight 256

#import "ViewController.h"
#import "FaceBoard.h"
#import "FaceButton.h"
#import "MessageListCell.h"
#import "showViewController.h"




@interface ViewController () <UITableViewDataSource,UITableViewDelegate,FaceBoardDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextViewDelegate>
{
    BOOL isFirstShowKeyboard;
    
    BOOL isButtonClicked;
    
    BOOL isKeyboardShowing;
    
    BOOL isSystemBoardShow;
    
    
     FaceBoard *faceBoard;
    
    CGFloat keyboardHeight;
    
    NSMutableArray *messageList; // 消息内容数组
    
    NSMutableDictionary *sizeList; // 字典


}
@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    CGRect frame = _messageListView.frame;
    frame.size.height = self.view.frame.size.height - 64;
    _messageListView.frame = frame;
    
    frame = _toolBar.frame;
    frame.origin.y = self.view.frame.size.height - 64;
    _toolBar.frame = frame;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ( !faceBoard) {
        faceBoard = [[FaceBoard alloc] init];
        faceBoard.delegate = self;
        faceBoard.inputTextView = self.textView;
    }
    if ( !messageList ) {
        
        messageList = [[NSMutableArray alloc] init];
    }
    if ( !sizeList ) {
        
        sizeList = [[NSMutableDictionary alloc] init];
    }
    
    self.cellNib = [UINib nibWithNibName:@"MessageListCell" bundle:nil];
    
    [_textView.layer setCornerRadius:6];
    [_textView.layer setMasksToBounds:YES];
    
    isFirstShowKeyboard = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - buttonEvent
- (IBAction)clickBoardBtn:(UIButton *)sender {
    
    isButtonClicked = YES;
    
    if ( isKeyboardShowing ) {
        
        [self.textView resignFirstResponder];
    }
    else {
        
        if ( isFirstShowKeyboard ) {
            
            isFirstShowKeyboard = NO;
            
            isSystemBoardShow = NO;
        }
        
        if ( !isSystemBoardShow ) {
            
            self.textView.inputView = faceBoard;
        }
        
        [self.textView becomeFirstResponder];
    }

}

- (IBAction)clickPhotoBtn:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择图片" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (IBAction)clickSendBtn:(UIButton *)sender {
    /*下页
    showViewController *showVC =[[showViewController alloc]initWithNibName:@"showViewController" bundle:nil];
    showVC.contents = _textView.text;
    [self.navigationController pushViewController:showVC animated:YES];
     */
    
    BOOL needReload = NO;
    if ( ![_textView.text isEqualToString:@""] ) {
        
        needReload = YES;
        
        NSMutableArray *messageRange = [[NSMutableArray alloc] init];
        [self getMessageRange:_textView.text :messageRange];
        [messageList addObject:messageRange];

    }
    
    _textView.text = nil;
    [self textViewDidChange:_textView];
    
    [_textView resignFirstResponder];
    
    isFirstShowKeyboard = YES;
    
    isButtonClicked = NO;
    
    _textView.inputView = nil;
    
    [_boardBtn setImage:[UIImage imageNamed:@"board_emoji"]
                    forState:UIControlStateNormal];
    
    if ( needReload ) {
        
        [_messageListView reloadData];
        
        [_messageListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList.count - 1
                                                                   inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:NO];
    }

}

/**
 * 解析输入的文本
 *
 * 根据文本信息分析出哪些是表情，哪些是文字
 */
- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
    NSRange range = [message rangeOfString:FACE_NAME_HEAD];
    
    //判断当前字符串是否存在表情的转义字符串
    if ( range.length > 0 ) {
        
        if ( range.location > 0 ) {
            
            [array addObject:[message substringToIndex:range.location]];
            
            message = [message substringFromIndex:range.location];
            
            if ( message.length > FACE_NAME_LEN ) {
                
                [array addObject:[message substringToIndex:FACE_NAME_LEN]];
                
                message = [message substringFromIndex:FACE_NAME_LEN];
                [self getMessageRange:message :array];
            }
            else
                // 排除空字符串
                if ( message.length > 0 ) {
                    
                    [array addObject:message];
                }
        }
        else {
            
            if ( message.length > FACE_NAME_LEN ) {
                
                [array addObject:[message substringToIndex:FACE_NAME_LEN]];
                
                message = [message substringFromIndex:FACE_NAME_LEN];
                [self getMessageRange:message :array];
            }
            else
                // 排除空字符串
                if ( message.length > 0 ) {
                    
                    [array addObject:message];
                }
        }
    }
    else {
        
        [array addObject:message];
    }
}

/**
 *  获取文本尺寸
 */
- (void)getContentSize:(NSIndexPath *)indexPath {
    
    @synchronized ( self ) {
        
        
        CGFloat upX;
        
        CGFloat upY;
        
        CGFloat lastPlusSize;
        
        CGFloat viewWidth;
        
        CGFloat viewHeight;
        
        BOOL isLineReturn;
        
        if (messageList.count > 0) { //  有数据
            
            NSArray *messageRange = [messageList objectAtIndex:indexPath.row];
            
            NSDictionary *faceMap = [[NSUserDefaults standardUserDefaults] objectForKey:@"FaceMap"];
            
            UIFont *font = [UIFont systemFontOfSize:16.0f];
            
            isLineReturn = NO;
            
            upX = VIEW_LEFT;
            upY = VIEW_TOP;
            
            for (int index = 0; index < [messageRange count]; index++) {
                
                NSString *str = [messageRange objectAtIndex:index];
                if ( [str hasPrefix:FACE_NAME_HEAD] ) {
                    
                    //NSString *imageName = [str substringWithRange:NSMakeRange(1, str.length - 2)];
                    
                    NSArray *imageNames = [faceMap allKeysForObject:str];
                    NSString *imageName = nil;
                    NSString *imagePath = nil;
                    
                    if ( imageNames.count > 0 ) {
                        
                        imageName = [imageNames objectAtIndex:0];
                        imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
                    }
                    
                    if ( imagePath ) {
                        
                        if ( upX > ( VIEW_WIDTH_MAX - KFacialSizeWidth ) ) {
                            
                            isLineReturn = YES;
                            
                            upX = VIEW_LEFT;
                            upY += VIEW_LINE_HEIGHT;
                        }
                        
                        upX += KFacialSizeWidth;
                        
                        lastPlusSize = KFacialSizeWidth;
                    }
                    else {
                        
                        for ( int index = 0; index < str.length; index++) {
                            
                            NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                            
                            CGSize size = [character sizeWithFont:font
                                                constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                            
                            if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                                
                                isLineReturn = YES;
                                
                                upX = VIEW_LEFT;
                                upY += VIEW_LINE_HEIGHT;
                            }
                            
                            upX += size.width;
                            
                            lastPlusSize = size.width;
                        }
                    }
                }
                else {
                    
                    for ( int index = 0; index < str.length; index++) {
                        
                        NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                        
                        CGSize size = [character sizeWithFont:font
                                            constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                        
                        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                            
                            isLineReturn = YES;
                            
                            upX = VIEW_LEFT;
                            upY += VIEW_LINE_HEIGHT;
                        }
                        
                        upX += size.width;
                        
                        lastPlusSize = size.width;
                    }
                }
            }
            
            if ( isLineReturn ) {
                
                viewWidth = VIEW_WIDTH_MAX + VIEW_LEFT * 2;
            }
            else {
                
                viewWidth = upX + VIEW_LEFT;
            }
            
            viewHeight = upY + VIEW_LINE_HEIGHT + VIEW_TOP;
            
            NSValue *sizeValue = [NSValue valueWithCGSize:CGSizeMake( viewWidth, viewHeight )];
            [sizeList setObject:sizeValue forKey:indexPath];
        }
    }
    
}

#pragma mark -tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (messageList.count > 0) {
        return messageList.count;
    }
    return 10;
}
/** ################################ UITableViewDelegate ################################ **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSValue *sizeValue = (NSValue *)[sizeList objectForKey:indexPath];
    if ( !sizeValue ) {
        
        [self getContentSize:indexPath];
        sizeValue = (NSValue *)[sizeList objectForKey:indexPath];
    }
    
    CGSize size = [sizeValue CGSizeValue];
    
    CGFloat span = size.height - MSG_VIEW_MIN_HEIGHT;
    CGFloat height = MSG_CELL_MIN_HEIGHT + span;
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *identifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    
//    }
//    return cell;
    
    static NSString *CellIdentifier = @"MessageListCell";
    MessageListCell *cell = (MessageListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        
        if ( cell == nil ) {
            
            [self.cellNib instantiateWithOwner:self options:nil];
            cell = _tmpCell;
            self.tmpCell = nil;
        }

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (messageList.count > 0) {
        
        NSMutableArray *message = [messageList objectAtIndex:indexPath.row];
        NSValue *sizeValue = [sizeList objectForKey:indexPath];
        CGSize size = [sizeValue CGSizeValue];
        
        if ( indexPath.row % 2 == 0 ) {
            
            [cell refreshForOwnMsg:message withSize:size];
        }
        else {
            
            [cell refreshForFrdMsg:message withSize:size];
        }

    }
    
    return cell;

}

/** ################################ UIKeyboardNotification ################################ **/

- (void)keyboardWillShow:(NSNotification *)notification {
    
    isKeyboardShowing = YES;
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                       
                         CGRect frame = _messageListView.frame;
                         frame.size.height += keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         _messageListView.frame = frame;
                         
                         frame = _toolBar.frame;
                         frame.origin.y += keyboardHeight;
                         frame.origin.y -= keyboardRect.size.height;
                         _toolBar.frame = frame;
                         
                         keyboardHeight = keyboardRect.size.height;
                     }];
    
    
    
    if ( isFirstShowKeyboard ) {
        
        isFirstShowKeyboard = NO;
        
        isSystemBoardShow = !isButtonClicked;
    }
    
    if ( isSystemBoardShow ) {
        
        [_boardBtn setImage:[UIImage imageNamed:@"board_emoji"]
                        forState:UIControlStateNormal];
    }
    else {
        
        [_boardBtn setImage:[UIImage imageNamed:@"board_system"]
                        forState:UIControlStateNormal];
    }
    
//    if ( messageList.count ) {
//        
//        [messageListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList.count - 1
//                                                                   inSection:0]
//                               atScrollPosition:UITableViewScrollPositionBottom
//                                       animated:NO];
//    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = _messageListView.frame;
                         frame.size.height += keyboardHeight;
                         _messageListView.frame = frame;
                         
                         frame = _toolBar.frame;
                         frame.origin.y += keyboardHeight;
                         _toolBar.frame = frame;
                         
                         keyboardHeight = 0;
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    isKeyboardShowing = NO;
    
    if ( isButtonClicked ) {
        
        isButtonClicked = NO;
        
        if ( ![_textView.inputView isEqual:faceBoard] ) {
            
            isSystemBoardShow = NO;
            
            _textView.inputView = faceBoard;
        }
        else {
            
            isSystemBoardShow = YES;
            
            _textView.inputView = nil;
        }
        
        [_textView becomeFirstResponder];
    }
}

/** ################################ ViewController ################################ **/
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
}



#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self openPicLibrary];
    }
}

-(void)addCarema{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)openPicLibrary{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:^{
        }];
    }
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
       
    
    
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** ################################ UITextViewDelegate ################################ **/
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //点击了非删除键
    if( [text length] == 0 ) {
        
        if ( range.length > 1 ) {
            
            return YES;
        }
        else {
            
            [faceBoard backFace];
            
            return NO;
        }
    }
    else {
        
        return YES;
    }
}

-(void)textViewDidChange:(UITextView *)textView{
    CGSize size = textView.contentSize;
    size.height -= 2;
    if ( size.height >= 68 ) {
        
        size.height = 68;
    }
    else if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
    if ( size.height != textView.frame.size.height ) {
        
        CGFloat span = size.height - textView.frame.size.height;
        
        CGRect frame = _toolBar.frame;
        frame.origin.y -= span;
        frame.size.height += span;
        _toolBar.frame = frame;
        
        CGFloat centerY = frame.size.height / 2;
        
        frame = textView.frame;
        frame.size = size;
        textView.frame = frame;
        
        CGPoint center = textView.center;
        center.y = centerY;
        textView.center = center;
        
        center = _boardBtn.center;
        center.y = centerY;
        _boardBtn.center = center;
        
        center = _sendBtn.center;
        center.y = centerY;
        _sendBtn.center = center;
    }
}
/** ################################ UITableViewDataSource ################################ **/



@end

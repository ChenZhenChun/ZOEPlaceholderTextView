//
//  ZOEPlaceholderTextView.m
//  AiyoyiuCocoapods
//
//  Created by aiyoyou on 16/4/7.
//  Copyright © 2016年 zoenet. All rights reserved.
//

#import "ZOEPlaceholderTextView.h"

@interface ZOEPlaceholderTextView()
{
    NSInteger     oldLength;
}
@property (nonatomic,strong) UILabel *placeHolderLabel;
@property (nonatomic,assign) NSInteger limit;
@property (nonatomic,strong) UILabel *countLabelTemp;//计数
@property (nonatomic,copy) void (^MyBlock)(void);
@end

@implementation ZOEPlaceholderTextView
@synthesize countLabel = _countLabel;


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initConfig];
}

- (void)initConfig {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    _textViewContainerInset = UIEdgeInsetsMake(8,4,8,4);
    [self setTextContainerInset:_textViewContainerInset];
}

- (void)setTextViewContainerInset:(UIEdgeInsets)textViewContainerInset {
    _textViewContainerInset = textViewContainerInset;
    [self setTextContainerInset:textViewContainerInset];
    if (_placeHolderLabel) {
        _placeHolderLabel.frame = CGRectMake(_textViewContainerInset.left+4,
                                             _textViewContainerInset.top,
                                             [UIScreen mainScreen].bounds.size.width-2*_textViewContainerInset.left,
                                             0);
        [_placeHolderLabel sizeToFit];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeHolderLabel.text = self.placeholder;
    [self.placeHolderLabel sizeToFit];
}

- (UILabel *)placeHolderLabel {
    if (!_placeHolderLabel) {
        _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(_textViewContainerInset.left+4,
                                                                      _textViewContainerInset.top,
                                                                      [UIScreen mainScreen].bounds.size.width-2*_textViewContainerInset.left,
                                                                      0)];
        _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _placeHolderLabel.numberOfLines = 0;
        _placeHolderLabel.font = self.font;
        _placeHolderLabel.backgroundColor = [UIColor clearColor];
        _placeHolderLabel.textColor = [UIColor lightGrayColor];
        _placeHolderLabel.alpha = 1;
        _placeHolderLabel.tag = 999;
        [self addSubview:_placeHolderLabel];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    return _placeHolderLabel;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if(text.length == 0 && self.placeHolderLabel.text.length > 0) {
        [[self viewWithTag:999] setAlpha:1];
    }
    [self textChanged:nil];
}

- (UILabel *)countLabelTemp {
    if (!_countLabelTemp) {
        _countLabelTemp = [[UILabel alloc]init];
        _countLabelTemp.text = [NSString stringWithFormat:@"%d/%ld",(int)floor([self charNumber]/2.0),(long)_limit];
        _countLabelTemp.frame = CGRectMake(CGRectGetMinX(self.frame),
                                           CGRectGetMaxY(self.frame),
                                           self.frame.size.width-8,
                                           20);
        _countLabelTemp.textColor = [UIColor grayColor];
        _countLabelTemp.backgroundColor = [UIColor clearColor];
        _countLabelTemp.font = [UIFont systemFontOfSize:12];
        _countLabelTemp.textAlignment = NSTextAlignmentRight;
    }
    return _countLabelTemp;
}

- (void)textChanged:(NSNotification *)notification {
    if (self.textDidChange) {
        self.textDidChange();
    }
    if(self.placeHolderLabel.text.length != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            if(self.text.length == 0) {
                [[self viewWithTag:999] setAlpha:1];
            }else {
                [[self viewWithTag:999] setAlpha:0];
            }
        }];
    }
    //过滤emoji表情输入
    if ([ZOEPlaceholderTextView stringContainsEmoji:self.text] && !_isSupportEmoji) {
        self.text = [self.text substringToIndex:oldLength];
        return;
    }
    if (!self.limit||!_MyBlock)return;
    if (_charVerifyType == Char) {
        if ([self charNumber]/2.0>self.limit && !self.markedTextRange) {
            _MyBlock();
            self.text = [self.text substringToIndex:oldLength];
        }else {
            if(!self.markedTextRange) {
                oldLength = self.text.length;
                self.countLabelTemp.text = [NSString stringWithFormat:@"%d/%ld",(int)floor([self charNumber]/2.0),(long)_limit];
            }
        }
    }else if (_charVerifyType == Length) {
        if (self.text.length>self.limit && !self.markedTextRange) {
            _MyBlock();
            self.text = [self.text substringToIndex:oldLength];
        }else {
            if(!self.markedTextRange) {
                oldLength = self.text.length;
                self.countLabelTemp.text = [NSString stringWithFormat:@"%ld/%ld",(long)oldLength,(long)_limit];
            }
        }
    }
}

- (UILabel *)countLabel {
    return _countLabelTemp;
}

- (void)ZOEPlaceholderTextViewLimit:(NSInteger)limit completed:(void (^)(void))block {
    self.limit = limit;
    self.MyBlock = block;
    [self countLabelTemp];
};


//计算字符串字符个数
- (int)charNumber {
    int strlength = 0;
    char* p = (char*)[self.text cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[self.text lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
        
    }
    return strlength;
    
    //    NSData* da = [self dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    //    return [da length];
}

//是否包含emoji表情
+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f9dc) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3 || ls == 0xfe0f) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

@end

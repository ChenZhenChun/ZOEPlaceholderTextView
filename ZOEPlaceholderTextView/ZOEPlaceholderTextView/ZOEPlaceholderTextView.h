//
//  ZOEPlaceholderTextView.m
//  AiyoyiuCocoapods
//
//  Created by aiyoyou on 16/4/7.
//  Copyright © 2016年 zoenet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface ZOEPlaceholderTextView : UITextView

@property (nonatomic,strong) NSString *placeholder;

/**
 输入的字数限制

 @param limit 现在多少字
 @param block 字数超限block回调
 */
- (void)ZOEPlaceholderTextViewLimit:(NSInteger)limit completed:(void(^)())block;

//计数(采用懒加载方式初始化，必须先调用XJPlaceholderTextViewLimit:completed:才能够被初始化)
@property (nonatomic,readonly,assign) UILabel *countLabel;
@property (nonatomic,assign)  BOOL  isSupportEmoji;//Default is no。
@property (nonatomic,assign) UIEdgeInsets textViewContainerInset;//内容内边距

@end

//
//  DDMenu.h
//  DDMenu
//
//  Created by Denis Dovgan on 9/5/14.
//  Copyright (c) 2014 Drop-Down Menu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDMenu : UIView

// Height for all rows
@property (nonatomic, assign, readonly) CGFloat rowHeight;

// By default is zero
@property (nonatomic, assign, readonly) NSUInteger currentIndex;

// By default the text is 'Black'
@property (nonatomic, strong) UIColor *titleTextColor;

// By default is 'YES'
@property (nonatomic, assign, getter = isTranslucent) BOOL translucent;

// By default is 'White'
@property (nonatomic, strong) UIColor *backgroundColor;

// By default is 'NO'
@property (nonatomic, assign) BOOL shouldUseFullScreen;

// By default is 0.4f
@property (nonatomic, assign) NSTimeInterval openMenuAnimationTime;

// By default is 0.2f
@property (nonatomic, assign) NSTimeInterval closeMenuAnimationTime;

// By default is 'NSTextAlignmentLeft'
@property (nonatomic, assign) NSTextAlignment textAlignment;

// By default is 'nil'
@property (nonatomic, strong) UIFont *customFont;

// By default is 'NO'
@property (nonatomic, assign) BOOL shouldUseSeparators;

// By default is '0.783922 0.780392 0.8 1'
@property (nonatomic, strong) UIColor *separatorColor;


+ (instancetype)menuWithFrame:(CGRect)frame titles:(NSArray *)titles;
+ (instancetype)menuWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight titles:(NSArray *)titles;

- (void)open;
- (void)close;
- (BOOL)isOpened;

- (BOOL)selectWithHitPoint:(CGPoint)point;
- (void)selectWithRowIndex:(NSUInteger)rowIndex;

- (void)setOnSelectBlock:(void (^)(NSUInteger idx, NSString *title))onSelectBlock;
- (void)setOnStateChangeBlock:(void (^)(BOOL isOpened))onChangeStateBlock;

@end

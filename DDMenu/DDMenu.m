//
//  DDMenu.m
//  DDMenu
//
//  Created by Denis Dovgan on 9/5/14.
//  Copyright (c) 2014 Drop-Down Menu. All rights reserved.
//

#import "DDMenu.h"


@interface DDMenu () <UITableViewDataSource, UITableViewDelegate> {
	UITableView *_tableView;
	NSArray *_titles;
	NSArray *_datasource;
	
	CGFloat _internalDynamicSelectedRowHeight;
	
	BOOL _isOpened;
	
	void (^_onSelectBlock)(NSUInteger idx, NSString *title);
	void (^_onChangeStateBlock)(BOOL isOpened);
	
	UIToolbar *_canvasView;
	CGFloat _maxHeight;
	NSTextAlignment _textAlignment;
}

@end


@implementation DDMenu


#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight titles:(NSArray *)titles {
	if (maxHeight > 0) {
		NSParameterAssert(maxHeight > frame.size.height);
	}
	NSParameterAssert(titles.count > 0);

    self = [super initWithFrame:frame];
    if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.userInteractionEnabled = YES;
		
		_canvasView = [UIToolbar.alloc initWithFrame:self.bounds];
		_canvasView.barStyle = UIBarStyleBlack;
		_canvasView.translucent = YES;
		_canvasView.opaque = NO;
		_canvasView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		[self addSubview:_canvasView];
				
		_tableView	= [UITableView.alloc initWithFrame:self.bounds style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView.separatorInset = UIEdgeInsetsZero;
		_tableView.scrollEnabled = NO;
		_tableView.backgroundColor = UIColor.clearColor;
		_tableView.dataSource = self;
		_tableView.delegate = self;
		
		[self addSubview:_tableView];
		
		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self addGestureRecognizer:tapGesture];

		_titles = [NSArray arrayWithArray:titles];
		_maxHeight = maxHeight;
		
		[self configureAsDefault];
		[self updateDatasourceAndReloadData];
    }
    return self;
}

+ (instancetype)menuWithFrame:(CGRect)frame titles:(NSArray *)titles {
	return [self.alloc initWithFrame:frame maxHeight:.0f titles:titles];
}

+ (instancetype)menuWithFrame:(CGRect)frame maxHeight:(CGFloat)maxHeight titles:(NSArray *)titles {
	return [self.alloc initWithFrame:frame maxHeight:maxHeight titles:titles];
}

- (void)configureAsDefault {
	_isOpened = NO;
	_rowHeight = self.frame.size.height;
	_internalDynamicSelectedRowHeight = _rowHeight;
	
	self.titleTextColor = UIColor.blackColor;
	self.backgroundColor = UIColor.whiteColor;
	
	self.translucent = YES;
	self.shouldUseFullScreen = NO;
	self.shouldUseSeparators = NO;
	self.separatorColor = nil;
	self.customFont = nil;
	
	self.openMenuAnimationTime = .4;
	self.closeMenuAnimationTime = .2;
	
	_textAlignment = NSTextAlignmentLeft;
}


#pragma mark - Common code

- (void)open {
	NSParameterAssert(!_isOpened);
	_isOpened = YES;
	
	[self updateDatasourceAndReloadData];
	
	[UIView animateWithDuration:self.openMenuAnimationTime animations:^{
		CGRect openedMenuFrame = self.frame;
		openedMenuFrame.size.height = self.shouldUseFullScreen ?
			(_maxHeight > 0 ? _maxHeight : self.superview.frame.size.height) : [self menuHeight];
		
		self.frame = openedMenuFrame;
	}];
	
	if (_onChangeStateBlock != nil) {
		_onChangeStateBlock(_isOpened);
	}
}

- (void)close {
	[self closeWithFinishBlock:nil];
}

- (void)closeWithFinishBlock:(void (^)(void))finishBlock; {
	NSParameterAssert(_isOpened);
	_isOpened = NO;
	
	// Calculating a path for the dynamic row height
	__block CGFloat path = _rowHeight * _currentIndex;
	_internalDynamicSelectedRowHeight = path * 2 + _rowHeight;
	
	[self updateDatasourceAndReloadData];
	
	[UIView animateWithDuration:self.closeMenuAnimationTime animations:^{
		
		CGRect closedMenuFrame = self.frame;
		closedMenuFrame.size.height = _rowHeight;
		self.frame = closedMenuFrame;
		
		// We don't need to animate the first row
		if (_currentIndex != 0) {
			_internalDynamicSelectedRowHeight = self.frame.size.height;
			
			[_tableView beginUpdates];
			[_tableView endUpdates];
		}
		
	} completion:^(BOOL finished) {
		if (finishBlock != nil) {
			finishBlock();
		}
	}];

	if (_onChangeStateBlock != nil) {
		_onChangeStateBlock(_isOpened);
	}
}

- (BOOL)selectWithHitPoint:(CGPoint)point {
	NSIndexPath *ip = [_tableView indexPathForRowAtPoint:point];
	
	if (ip != nil) {
		[self selectWithIndexPath:ip];
	}
	
	return ip != nil;
}

- (void)selectWithRowIndex:(NSUInteger)rowIndex {
	NSParameterAssert(rowIndex < _datasource.count);
	
	NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:0];
	[self selectWithIndexPath:selectedIndexPath];
}

- (void)selectWithIndexPath:(NSIndexPath *)ip {
	NSParameterAssert(ip != nil);
	
	[self tableView:_tableView didSelectRowAtIndexPath:ip];
}

- (void)updateDatasourceAndReloadData {
	_datasource = _isOpened ? _titles : @[_titles[_currentIndex]];
	[_tableView reloadData];
}

- (BOOL)isOpened {
	return _isOpened;
}


#pragma mark - Setters

- (CGFloat)menuHeight {
	return _rowHeight * _titles.count;
}

- (void)setOnSelectBlock:(void (^)(NSUInteger, NSString *))onSelectBlock {
	_onSelectBlock = onSelectBlock;
}

- (void)setOnStateChangeBlock:(void (^)(BOOL isOpened))onChangeStateBlock {
	_onChangeStateBlock = onChangeStateBlock;
}

- (void)setTranslucent:(BOOL)menuTranslucent {
	_canvasView.alpha = menuTranslucent ? .8f : 1.f;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
	_canvasView.barTintColor = backgroundColor;
}

- (void)setAlpha:(CGFloat)alpha {
}

- (void)setShouldUseSeparators:(BOOL)shouldUseSeparators {
	_tableView.separatorStyle =  shouldUseSeparators ?
		UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
	if (_textAlignment != textAlignment) {
		_textAlignment = textAlignment;
		[_tableView reloadData];
	}
}

- (BOOL)shouldUseSeparators {
	return _tableView.separatorStyle == UITableViewCellSeparatorStyleSingleLine;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
	_tableView.separatorColor = separatorColor;
}

- (UIColor *)separatorColor {
	return _tableView.separatorColor;
}

- (void)setCustomFont:(UIFont *)customFont {
	if (_customFont != customFont) {
		_customFont = customFont;
		[_tableView reloadData];
	}
}


#pragma mark - UIGestureRecognizer

- (void)handleTap:(UIGestureRecognizer *)recognizer {
	CGPoint hitPoint = [recognizer locationInView:recognizer.view];
	
	[self selectWithHitPoint:hitPoint];
}


#pragma mark - <UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *const cellReuseId = @"MenuCellReuseIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseId];
	if (cell == nil)
	{
		cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseId];
		cell.backgroundColor = UIColor.clearColor;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	// Dynamic values
	cell.textLabel.font = self.customFont != nil ? self.customFont : [UIFont systemFontOfSize:14.0];
	cell.textLabel.textAlignment = self.textAlignment;
	
	cell.textLabel.text = _datasource[indexPath.row];
	cell.textLabel.textColor = self.titleTextColor == nil ? UIColor.blackColor : self.titleTextColor;
	
	return cell;
}


#pragma mark - <UITableViewDelegate> Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return _isOpened ? _rowHeight : _internalDynamicSelectedRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (_currentIndex == indexPath.row && _isOpened) {
		[self close];
		return;
	}
	
	if (_isOpened) {
		_currentIndex = indexPath.row;
		[self close];
		if (_onSelectBlock != nil) {
			_onSelectBlock(_currentIndex, _titles[_currentIndex]);
		}
	}
	else {
		[self open];
	}
}

@end

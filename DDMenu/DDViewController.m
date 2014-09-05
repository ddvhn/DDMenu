//
//  DDViewController.m
//  DDMenu
//
//  Created by Denis Dovgan on 9/5/14.
//  Copyright (c) 2014 Drop-Down Menu. All rights reserved.
//

#import "DDViewController.h"
#import "DDMenu.h"


#define STR(format, ...) ([NSString stringWithFormat:format, ##__VA_ARGS__])


@interface DDViewController () {
	DDMenu *_menu;
}

@end


@implementation DDViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	backgroundView.image = [[UIImage imageNamed:@"background-wood"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
	
	[self.view addSubview:backgroundView];
	
	NSMutableArray *titles = [NSMutableArray array];
	for (NSInteger i = 0; i < 10; i++) {
		[titles addObject:STR(@"Title %d", i+1)];
	}
	
	_menu = [DDMenu menuWithFrame:CGRectMake(0.f, 20.f, self.view.bounds.size.width, 44.f) titles:titles];
	_menu.backgroundColor = [UIColor lightGrayColor];
	_menu.titleTextColor = [UIColor whiteColor];
	_menu.shouldUseSeparators = YES;
	_menu.textAlignment = NSTextAlignmentCenter;

	[_menu setOnSelectBlock:^(NSUInteger idx, NSString *title) {
		NSLog(@"Selected index: %d title:%@", idx, title);
	}];
	[_menu setOnStateChangeBlock:^(BOOL isOpened) {
		NSLog(@"Menu has been %@", isOpened ? @"opened" : @"closed");
	}];
	
	[self.view addSubview:_menu];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

@end

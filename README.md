DDMenu
======
**Installation**
--------------------

Just copy DDMenu.h and DDMenu.m to your project.

**Example:**
--------------------
```objc
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	DDMenu *menu = [DDMenu menuWithFrame:CGRectMake(0.f, 0.f, self.view.bounds.size.width, 44.f) titles:titles];
	menu.backgroundColor = [UIColor lightGrayColor];
	menu.titleTextColor = [UIColor whiteColor];
	menu.shouldUseSeparators = YES;
	menu.textAlignment = NSTextAlignmentCenter;

	[menu setOnSelectBlock:^(NSUInteger idx, NSString *title) {
		NSLog(@"Selected index: %d title:%@", idx, title);
	}];
	[menu setOnStateChangeBlock:^(BOOL isOpened) {
		NSLog(@"Menu has been %@", isOpened ? @"opened" : @"closed");
	}];
	
	[self.view addSubview:menu];
}
```

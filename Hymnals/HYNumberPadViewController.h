//
//  HYNumberPadViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/18/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYNumberPadViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSMutableString *codeString;

@property (nonatomic, strong) NSArray *resultsArray;

- (IBAction)dialButtonTouched:(UIButton*)sender;
- (IBAction)backspaceButtonTouched;
- (IBAction)goButtonTouched;

@end

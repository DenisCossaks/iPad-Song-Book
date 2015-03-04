//
//  HYHymnalCollectionView.h
//  Hymnals
//
//  Created by Stephen Bradley on 5/7/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYHymnalCollectionView;
@protocol HYHymnalCollectionViewDelegate <NSObject>

- (void)hymnalCollectionViewSelected:(HYHymnalCollectionView *)hymnalCollectionView;

@end


@interface HYHymnalCollectionView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet id delegate;

@end

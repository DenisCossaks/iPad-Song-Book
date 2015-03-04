//
//  HYHymnalCollectionCell.h
//  Hymnals
//
//  Created by Stephen Bradley on 5/10/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYHymnalCollectionView.h"

@class HYHymnalCollectionCell;
@protocol HYHymnalCollectionCellDelegate <NSObject>

- (void)hymnalCollectionCell:(HYHymnalCollectionCell *)hymnalCollectionCell selectedCollection:(NSArray *)collection;

@end


@interface HYHymnalCollectionCell : UITableViewCell

@property (nonatomic, strong) IBOutletCollection(HYHymnalCollectionView) NSArray *collectionViews;

@property (nonatomic, strong) NSArray *collectionArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id delegate;

- (void)reloadCell;

@end
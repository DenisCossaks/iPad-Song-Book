//
//  HYHymnalCollectionCell.h
//  Hymnals
//
//  Created by Stephen Bradley on 5/7/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYHymnalCollectionView.h"

@class HYHymnalCell;
@protocol HYHymnalCellDelegate <NSObject>

- (void)hymnalCell:(HYHymnalCell *)hymnalCell selectedHymnal:(NSDictionary *)hymnal;

@end


@interface HYHymnalCell : UITableViewCell

@property (nonatomic, strong) IBOutletCollection(HYHymnalCollectionView) NSArray *collectionViews;

@property (nonatomic, strong) NSArray *hymnalArray;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id delegate;

- (void)reloadCell;

@end

//
//  HYHymnalCollectionCell.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/10/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymnalCollectionCell.h"
#import "UIImage+CachingExtensions.h"

@implementation HYHymnalCollectionCell

@synthesize collectionViews;

@synthesize collectionArray;
@synthesize indexPath;
@synthesize delegate;

#pragma mark - loading
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    collectionViews = [collectionViews sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tag" ascending:YES]]];
}

- (void)reloadCell {
    NSInteger lcv = 0;
    for (HYHymnalCollectionView *collectionView in collectionViews) {
        if (collectionArray.count > (indexPath.row * lcv) + lcv) {
            NSArray *collection = [collectionArray objectAtIndex:(indexPath.row * lcv) + lcv];
            collectionView.hidden = NO;
            collectionView.nameLabel.text = [collection.lastObject objectForKey:@"hymnal_group"];
            
            collectionView.coverImageView.image = nil;
            if ([[collection.lastObject objectForKey:@"cover_url"] isKindOfClass:[NSString class]]) {
                NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
                    UIImage *image = [UIImage cachedImageNamed:[[collection.lastObject objectForKey:@"cover_url"] lastPathComponent] atURL:[NSURL URLWithString:[collection.lastObject objectForKey:@"cover_url"]]];
                    [collectionView.coverImageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
                }];
                [blockop performSelectorInBackground:@selector(start) withObject:nil];
            }
        }
        else {
            collectionView.hidden = YES;
        }
        lcv++;
    }
}

#pragma mark - collectionview
- (void)hymnalCollectionViewSelected:(HYHymnalCollectionView *)hymnalCollectionView {
    if ([delegate respondsToSelector:@selector(hymnalCollectionCell:selectedCollection:)]) {
        [delegate hymnalCollectionCell:self selectedCollection:[collectionArray objectAtIndex:(indexPath.row * hymnalCollectionView.tag) + hymnalCollectionView.tag]];
    }
}


@end

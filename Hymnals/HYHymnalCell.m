//
//  HYHymnalCollectionCell.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/7/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymnalCell.h"
#import "UIImage+CachingExtensions.h"

@implementation HYHymnalCell

@synthesize collectionViews;

@synthesize hymnalArray;
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
        if (hymnalArray.count > (indexPath.row * lcv) + lcv) {
            NSDictionary *hymnalDict = [hymnalArray objectAtIndex:(indexPath.row * lcv) + lcv];
            collectionView.hidden = NO;
            collectionView.nameLabel.text = [hymnalDict objectForKey:@"hymnal_name"];
            
            collectionView.coverImageView.image = nil;
            if ([[hymnalDict objectForKey:@"cover_url"] isKindOfClass:[NSString class]]) {
                NSBlockOperation *blockop = [NSBlockOperation blockOperationWithBlock:^{
                    UIImage *image = [UIImage cachedImageNamed:[[hymnalDict objectForKey:@"cover_url"] lastPathComponent] atURL:[NSURL URLWithString:[hymnalDict objectForKey:@"cover_url"]]];
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
    if ([delegate respondsToSelector:@selector(hymnalCell:selectedHymnal:)]) {
        [delegate hymnalCell:self selectedHymnal:[hymnalArray objectAtIndex:(indexPath.row * hymnalCollectionView.tag) + hymnalCollectionView.tag]];
    }
}

@end

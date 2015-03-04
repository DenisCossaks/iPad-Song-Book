//
//  HYHymnalCollectionView.m
//  Hymnals
//
//  Created by Stephen Bradley on 5/7/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymnalCollectionView.h"

@implementation HYHymnalCollectionView

@synthesize coverImageView;
@synthesize nameLabel;

@synthesize delegate;

- (IBAction)collectionViewButtonTouched {
    if ([delegate respondsToSelector:@selector(hymnalCollectionViewSelected:)]) {
        [delegate hymnalCollectionViewSelected:self];
    }
}

@end

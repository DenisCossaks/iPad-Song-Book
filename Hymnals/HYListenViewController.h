//
//  HYListenViewController.h
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HYListenViewController : UIViewController

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) MPMoviePlayerController *playerController;

@property (nonatomic, strong) NSString *audioFileString;
@property (nonatomic, strong) NSString *itunesString;

@property (nonatomic, strong) NSTimer *timer;

- (id)initWithHymnAudioFile:(NSString*)audioFile itunes:(NSString*) itunes;

@end

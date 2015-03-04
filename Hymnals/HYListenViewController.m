//
//  HYListenViewController.m
//  Hymnals
//
//  Created by Stephen Bradley on 4/20/12.
//  Copyright (c) 2012 SKB Software. All rights reserved.
//

#import "HYListenViewController.h"
#import "UIDevice-Hardware.h"

@implementation HYListenViewController

@synthesize progressView;

@synthesize playerController;
@synthesize audioFileString;
@synthesize timer;

#pragma mark - loading
- (id)initWithHymnAudioFile:(NSString*)audioFile itunes:(NSString*) itunes {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.contentSizeForViewInPopover = CGSizeMake(400, 0);
        self.audioFileString = audioFile;
        self.itunesString = itunes;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Listen - Viewed"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerPlaybackDidFinishNotification:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerLoadStateDidChangeNotification:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://services.giamusic.com/hymnals_mp3s/%@", audioFileString]]];    
//    playerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://c1824532.cdn.cloudfiles.rackspacecloud.com/%@", audioFileString]]];
    playerController.movieSourceType = MPMovieSourceTypeFile;
    if ([[UIDevice currentDevice] shouldBeIPadAir]) { // note: [playerController respondsToSelector:@selector(setUseApplicationAudioSession:)] returns false even tho it's deprecated
        playerController.useApplicationAudioSession = NO;
    }
    playerController.shouldAutoplay = NO;
    [playerController prepareToPlay];
    
    progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.frame = CGRectMake(0, 0, 300, progressView.frame.size.height);
    
    UIButton * btnItunes = [UIButton buttonWithType:UIButtonTypeCustom];
    btnItunes.frame = CGRectMake(0, 0, 95, 30);
    [btnItunes setImage:[UIImage imageNamed:@"button-itunes.png"] forState:UIControlStateNormal];
    [btnItunes addTarget:self action:@selector(onclickItunes) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator startAnimating];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.titleView = progressView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnItunes];
    
}

-(void) onclickItunes
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.itunesString]];
}


#pragma mark - orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - notifcations
- (void)moviePlayerPlaybackDidFinishNotification:(NSNotification*)notifcation {
    if([[[notifcation userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackEnded) {
        [timer invalidate];
    }
}

- (void)moviePlayerLoadStateDidChangeNotification:(NSNotification*)notification {
    //NSLog(@"%i", playerController.loadState);
    
    if(playerController.loadState == MPMovieLoadStatePlayable) {
        [self actionButtonTouched];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-pause"] style:UIBarButtonItemStyleBordered target:self action:@selector(actionButtonTouched)];
        NSLog(@"MPMovieLoadStatePlayable");
    }
    else if(playerController.loadState == MPMovieLoadStatePlaythroughOK) {
        NSLog(@"MPMovieLoadStatePlaythroughOK");
    }
}

#pragma mark - actions
- (void)actionButtonTouched {
    if(playerController.playbackState != MPMoviePlaybackStatePlaying) {
        [Flurry logEvent:@"Listen - Play" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:audioFileString, @"File Name", nil]];
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"button-pause"];
        [playerController play];
        if(!timer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:.05 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        }
    }
    else {
        [Flurry logEvent:@"Listen - Pause" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:audioFileString, @"File Name", nil]];
        self.navigationItem.leftBarButtonItem.image = [UIImage imageNamed:@"button-play"];
        [playerController pause];
    }
}

- (void)updateProgress {
    if(playerController.duration) {
        progressView.progress = playerController.currentPlaybackTime / playerController.duration;
    }
}

#pragma mark - cleanup
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [playerController stop];
    [timer invalidate];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.progressView = nil;
    
    self.playerController = nil;
    self.audioFileString = nil;
    self.timer = nil;
}

@end

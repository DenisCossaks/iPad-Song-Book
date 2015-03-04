//
//  HYDefinitions.h
//  Hymnals
//
//  Created by christopher ngo on 6/20/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#ifndef Hymnals_HYDefinitions_h
#define Hymnals_HYDefinitions_h

#define ShowAlert(x, y) [[[UIAlertView alloc] initWithTitle:x message:y delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
#define ShowFixMeAlert(x) ShowAlert(@"FIX ME", x)
#define Stringify(x) x ? [x description] : @""

#define NSLog2(x) NSLog(@"\n\n%@\n\n",x);

#define IsIOS7OrNewer (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)

#endif

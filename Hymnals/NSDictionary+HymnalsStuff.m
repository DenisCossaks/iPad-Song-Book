//
//  NSDictionary+HymnalsStuff.m
//  Hymnals
//
//  Created by christopher ngo on 11/14/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "NSDictionary+HymnalsStuff.h"

@implementation NSDictionary (HymnalsStuff)

- (NSDictionary *)dictionaryByFilteringHymnValuesForFlurry { // flurry limits 10 values in the dict param
    NSArray *keys = @[@"audio_file",
                      @"file_version",
                      @"hymnal_code",
                      @"hymnal_name",
                      @"hymnal_number",
                      @"hymnal_shortname",
                      @"id",
                      @"pdf_file",
                      @"sort",
                      @"title"];
    NSMutableDictionary *mutableSelf = [NSMutableDictionary dictionaryWithCapacity:10];
    for (NSString *key in keys) {
        [mutableSelf setObject:self[key] forKey:key];
    }
    return [[NSDictionary alloc] initWithDictionary:mutableSelf copyItems:NO];
}
@end

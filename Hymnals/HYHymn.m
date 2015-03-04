//
//  HYHymnal.m
//  Hymnals
//
//  Created by christopher ngo on 6/17/13.
//  Copyright (c) 2013 SKB Software. All rights reserved.
//

#import "HYHymn.h"

#import "HYHymnIdentifier.h"
#import "HYHymnPDF.h"

@implementation HYHymn {
    HYHymnIdentifier *_hymnIdentifier;
}

static NSString * const kIDKey = @"id";
static NSString * const kHymnalCodeKey = @"hymnal_code";
static NSString * const kNumberKey = @"hymnal_number";

#pragma mark - Class Methods
+ (NSArray *)arrayOfHymnsWithServiceListID:(NSNumber *)serviceID {
    return [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT hymnals.hymnal_number, hymnals.hymnal_name, hymnals.hymnal_code, hymnals.title, hymnals.version, servicelist_hymnals.display_order, servicelist_hymnals.id, servicelist_hymnals.name FROM servicelist_hymnals, hymnals WHERE servicelist_hymnals.servicelist_id = %@ AND servicelist_hymnals.hymnal_id = hymnals.id ORDER BY servicelist_hymnals.display_order", serviceID];
}
+ (NSArray *)arrayOfHymnsWithServiceListID2:(NSNumber *)serviceID {
    NSArray *hymnals = [HYHymn arrayOfHymnsWithServiceListID:serviceID];
    NSMutableArray *mutableHymnals = [NSMutableArray arrayWithCapacity:hymnals.count];
    for (NSDictionary *hymnalDict in hymnals) {
        [mutableHymnals addObject:[[HYHymn alloc] initWithDictionary:hymnalDict]];
    }
    return [[NSArray alloc] initWithArray:mutableHymnals copyItems:NO];
}
+ (NSArray *)arrayOfAvailableHymnIdentifiers {
    NSArray *hymnIDs = nil;
    @autoreleasepool {
        NSArray *values = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT id, hymnal_number, hymnal_code FROM hymnals"];
        NSMutableArray *mutableHymnIDs = [NSMutableArray arrayWithCapacity:values.count];
        for (NSDictionary *value in values) {
            [mutableHymnIDs addObject:[[HYHymnIdentifier alloc] initWithHymnalCode:value[kHymnalCodeKey] number:value[kNumberKey] idNumber:value[kIDKey]]];
        }
        hymnIDs = [[NSArray alloc] initWithArray:mutableHymnIDs copyItems:NO];
    }
    //NSLog2(hymnIDs)
    return hymnIDs;
}
+ (NSArray *)arrayOfHymnPDFsThatShouldBeDownloaded {
    NSArray *pdfs = nil;
    @autoreleasepool {
        NSArray *values = [[HYDatabase sharedDatabase] executeSimpleQuery:@"SELECT pdf_file, hymnal_code FROM hymnals WHERE hymnal_code != 'SH' and hymnal_code != 'IM' and isDownloaded = 1"]; // SH is bundled with the app
        NSMutableArray *mutableFilenames = [NSMutableArray arrayWithCapacity:values.count];
        for (NSDictionary *value in values) {
            [mutableFilenames addObject:[[HYHymnPDF alloc] initWithFilename:value[@"pdf_file"] hymnalCode:value[@"hymnal_code"]]];
        }
        pdfs = [[NSArray alloc] initWithArray:mutableFilenames copyItems:NO];
    }
    return pdfs;
}
+ (NSString *)importedMusicName {
    return @"Imported Music";
}
+ (NSString *)importedMusicCode {
    return @"IM";
}
#pragma mark -
- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        [self setDisplayOrder:dictionary[@"display_order"]];
        [self setHymnalCode:dictionary[kHymnalCodeKey]];
        [self setHymnalName:dictionary[@"hymnal_name"]];
        [self setNumber:dictionary[kNumberKey]];
        [self setIdAsNumber:dictionary[kIDKey]];
        [self setTitle:dictionary[@"title"]];
        [self setName:dictionary[@"name"]];
        [self setVersion:dictionary[@"version"]];
        // note: skipping name and version keys
    }
    return self;
}
- (NSString *)version2 {
    return @"1.0";
}
- (NSString *)displayText {
    if(![[self name] isKindOfClass:[NSNull class]]) {
        return [self name];
    }
    else if([[self version] isKindOfClass:[NSNull class]]) {
        return [NSString stringWithFormat:@"%@ #%@ - %@", self.hymnalCode, self.number, self.title];
    }
    else {
        return [NSString stringWithFormat:@"%@ #%@ %@ - %@", self.hymnalCode, self.number, self.version, self.title];
    }
}
- (BOOL)isImportedMusic {
    return [self.hymnalCode isEqualToString:[HYHymn importedMusicCode]];
}
- (HYHymnIdentifier *)hymnIdentifier {
    if(!_hymnIdentifier) {
        _hymnIdentifier = [[HYHymnIdentifier alloc] initWithHymnalCode:self.hymnalCode number:self.number idNumber:self.idAsNumber];
    }
    return _hymnIdentifier;
}
@end

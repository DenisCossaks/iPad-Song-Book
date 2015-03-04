//
//  UIApplication+Things.m
//
//
//  Created by  on 7/10/11.
//  Copyright 2011 . All rights reserved.
//

#import "UIApplication+Things.h"

@implementation UIApplication (FilePaths)

+ (NSString *)syncAttemptsDirectory {
    return [UIApplication createPathIfNeeded:[[UIApplication documentsDirectory] stringByAppendingPathComponent:@"sync_attempts"]];
}

+ (NSString *)applicationSupportDirectory {
    return [UIApplication createPathIfNeeded:[UIApplication pathToUserDomain:NSApplicationSupportDirectory]];
}

+ (NSString *)documentsDirectory {
    return [UIApplication createPathIfNeeded:[UIApplication pathToUserDomain:NSDocumentDirectory]];
}

+ (NSString *)cachesDirectory {
    return [UIApplication createPathIfNeeded:[UIApplication pathToUserDomain:NSCachesDirectory]];
}

+ (NSString *)pathToUserDomain:(NSSearchPathDirectory)domainID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(domainID, NSUserDomainMask, YES);
    return [paths count] ? [paths objectAtIndex:0] : nil;
}

+ (NSString *)createPathIfNeeded:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error = nil;
        BOOL dirCreationSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (!dirCreationSuccess) {
            NSLog(@"Could not create needed application directory: %@\n%@", path, error);
        }
    }

    return path;
}

+ (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
+ (NSString *)applicationVersion {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleShortVersionString"]];
}

+ (NSString *)applicationVersionAndBuild {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@.%@", [info objectForKey:@"CFBundleShortVersionString"], [info objectForKey:@"CFBundleVersion"]];
}

+ (NSString *)applicationBundleID {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
}

@end

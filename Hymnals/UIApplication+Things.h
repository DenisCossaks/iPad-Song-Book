//
//  UIApplication+Things.h
//
//
//  Created by  on 7/10/11.
//  Copyright 2011 . All rights reserved.
//

@interface UIApplication (Things)

+ (NSString *)syncAttemptsDirectory;
+ (NSString *)applicationSupportDirectory;
+ (NSString *)documentsDirectory;
+ (NSString *)cachesDirectory;
+ (NSURL *)applicationDocumentsDirectory;

+ (NSString *)pathToUserDomain:(NSSearchPathDirectory)domainID;
+ (NSString *)createPathIfNeeded:(NSString *)path;
+ (NSString *)applicationVersion;
+ (NSString *)applicationVersionAndBuild;
+ (NSString *)applicationBundleID;

@end

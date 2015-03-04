//
//  SqliteWrapper.m
//
#import "SqliteWrapper.h"
#import "SqliteWrapperProtectedMethods.h"
#import "NSString+CaseInsensitiveExtensions.h"

@interface SqliteWrapper(PrivateMethods)

@end

@implementation SqliteWrapper
#pragma mark -
#pragma mark Class Methods

#pragma mark -
#pragma mark Object Lifecycle Methods
- (id)init {
	if (self = [super init]) {
		
	}
	return self;
}
#pragma mark -
#pragma mark Private Instance Methods

#pragma mark -
#pragma mark Protected Instance Methods
- (void)openDatabase {
	[databaseLock lock];
	if (sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
		sqlite3_close(database);
		NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_exec(database, "PRAGMA foreign_keys = ON", NULL, NULL, NULL);
	[databaseLock unlock];
}
#pragma mark -
#pragma mark Other Public Instance Methods
- (NSMutableArray *)executeSimpleQuery:(NSString *)query, ... {
	[databaseLock lock];
	if (!database) {
		return nil;
	}
    va_list argumentList;
    va_start(argumentList, query);
	NSString *formattedQuery = [[NSString alloc] initWithFormat:query arguments:argumentList];
    va_end(argumentList);
	
	NSMutableArray *results = nil;
	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [formattedQuery UTF8String], -1, &statement, NULL) != SQLITE_OK)
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	BOOL success = NO;
	NSUInteger columnCount = sqlite3_column_count(statement);
	if (columnCount) {
		results = [NSMutableArray array];
		NSUInteger *columnType = malloc(columnCount * sizeof(NSUInteger));
		for (NSUInteger i = 0; i < columnCount; i++) {
			const char *columnTypeCString = sqlite3_column_decltype(statement, i);
			NSString *columnTypeString = nil;
			if (columnTypeCString) {
				columnTypeString = [NSString stringWithCString:columnTypeCString encoding:NSUTF8StringEncoding];
			}
			if (!columnTypeString) {
				columnType[i] = 0;
			}
			else if ([columnTypeString caseInsensitiveIsEqualToString:@"TEXT"]) {
				columnType[i] = 0;
			}
			else if ([columnTypeString caseInsensitiveIsEqualToString:@"REAL"]) {
				columnType[i] = 1;
			}
			else if ([columnTypeString caseInsensitiveIsEqualToString:@"FLOAT"]) {
				columnType[i] = 1;
			}
			else if ([columnTypeString caseInsensitiveIsEqualToString:@"NUMERIC"]) {
				columnType[i] = 1;
			}
			else if ([columnTypeString caseInsensitiveIsEqualToString:@"INTEGER"]) {
				columnType[i] = 2;
			}
			else if ([columnTypeString caseInsensitiveIsEqualToString:@"BOOL"]) {
				columnType[i] = 3;
			}
			else if ([columnTypeString caseInsensitiveHasPrefix:@"DECIMAL"]) {
				columnType[i] = 1;
			}
			else if ([columnTypeString caseInsensitiveHasPrefix:@"VARCHAR"]) {
				columnType[i] = 0;
			}
			else {
				columnType[i] = 0;
			}
		}
		while ((success = sqlite3_step(statement)) == SQLITE_ROW) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:columnCount];
			for (NSUInteger i = 0; i < columnCount; i++) {
				NSString *columnName = [NSString stringWithCString:sqlite3_column_name(statement, i) encoding:NSUTF8StringEncoding];
				switch (columnType[i]) {
					case 0: {
						const char *cString = (const char *)sqlite3_column_text(statement, i);
						if (cString) {
							NSString *stringValue = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
							[dict setObject:stringValue forKey:columnName];
						}
						else {
							[dict setObject:[NSNull null] forKey:columnName];
						}
						break;
					}
					case 1: {
						NSNumber *floatValue = [NSNumber numberWithDouble:sqlite3_column_double(statement, i)];
						[dict setObject:floatValue forKey:columnName];
						break;
					}
					case 2: {
						NSNumber *intValue = [NSNumber numberWithInteger:sqlite3_column_int(statement, i)];
						[dict setObject:intValue forKey:columnName];
						break;
					}
					case 3: {
						NSNumber *intValue = [NSNumber numberWithBool:sqlite3_column_int(statement, i)];
						[dict setObject:intValue forKey:columnName];
						break;
					}
					default:
						break;
				}
			}
			[results addObject:dict];
		}
		free(columnType);
	}
	else {
		success = sqlite3_step(statement);
	}
	sqlite3_finalize(statement);
	if (success == SQLITE_ERROR)
		NSAssert1(0, @"Error: failed to query database with message '%s'.", sqlite3_errmsg(database));
	[databaseLock unlock];
	
	return results;
}
- (void)executeNonQuery:(NSString *)query, ... {
	[databaseLock lock];
	if (!database) {
		return;
	}
    va_list argumentList;
    va_start(argumentList, query);
	NSString *formattedQuery = [[NSString alloc] initWithFormat:query arguments:argumentList];
    va_end(argumentList);
	
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(database, [formattedQuery UTF8String], -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	BOOL success = sqlite3_step(statement);
	sqlite3_finalize(statement);
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to query database with message '%s'.", sqlite3_errmsg(database));
	}
	[databaseLock unlock];
	return;
}
- (NSUInteger)lastInsertedRowId {
	[databaseLock lock];
	if (!database) {
		return NSUIntegerMax;
	}
	NSUInteger lastRowId = sqlite3_last_insert_rowid(database);
	[databaseLock unlock];
	return lastRowId;
}
#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
    sqlite3_close(database);
    database = NULL;
}
@end
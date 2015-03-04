//
//  SqliteWrapper.h
//
#import <sqlite3.h>
#import "NSString+SQLEscapeExtensions.h"

@interface SqliteWrapper : NSObject {
    sqlite3 *database;
	NSRecursiveLock *databaseLock;
	NSString *databasePath;
}
- (NSMutableArray *)executeSimpleQuery:(NSString *)query, ...;
- (void)executeNonQuery:(NSString *)query, ...;
- (NSUInteger)lastInsertedRowId;
@end

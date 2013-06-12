//
//  InsertNoTransactionTest.h
//  SQLCipherSpeed
//
//  Created by Stephen Lombardo on 5/30/09.
//  Copyright 2009 Zetetic LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SqlTest.h"
#import "IteratedSqlTest.h"
#import "IteratedTest.h"

@interface PragmaKeyTest : SqlTest { 
    NSInteger pageSize;
}
@property (nonatomic) NSInteger pageSize;
@end

@interface CreateTableTest : SqlTest { }
@end

@interface InsertNoTransactionTest :  IteratedSqlTest{ }
@end

@interface InsertWithTransactionTest : IteratedSqlTest { }
@end

@interface SelectWithoutIndexTest : IteratedSqlTest { }
@end

@interface SelectOnStringCompareTest : IteratedSqlTest { }
@end

@interface CreateIndexTest : SqlTest { }
@end

@interface SelectWithIndexTest : IteratedSqlTest { }
@end

@interface UpdateWithoutIndexTest : IteratedSqlTest { }
@end

@interface UpdateWithIndexTest : IteratedSqlTest { }
@end

@interface InsertFromSelectTest : SqlTest { }
@end

@interface DeleteWithoutIndexTest : SqlTest { }
@end

@interface DeleteWithIndexTest : SqlTest { }
@end

@interface BigInsertAfterDeleteTest : SqlTest { }
@end

@interface ManyInsertsAfterDeleteTest : IteratedSqlTest { }
@end

@interface DropTableTest : SqlTest { }
@end


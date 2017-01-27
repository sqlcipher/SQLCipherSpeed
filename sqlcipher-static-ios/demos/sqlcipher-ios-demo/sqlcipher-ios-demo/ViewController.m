//
//  ViewController.m
//  sqlcipher-ios-demo
//
//  Copyright © 2016 Zetetic. All rights reserved.
//

#import "ViewController.h"

sqlite3* db;
char* password = "Password1!";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)runDemo:(id)sender {
    NSLog(@"Running SQLCipher demo");
    if(db == NULL){
        [self initializeSQLCipher];
    }
    [self insertData];
    [self displayData];
}

- (IBAction)clearDemo:(id)sender {
    NSLog(@"Clearning demo content");
    int rc;
    if(db == NULL){
        [self initializeSQLCipher];
    }
    sqlite3_stmt *stmt;
    sqlite3_prepare(db, "delete from t1;", -1, &stmt, NULL);
    rc = sqlite3_step(stmt);
    if(rc != SQLITE_DONE){
        NSLog(@"Failed to delete data");
    }
    [self displayData];
}

-(void) initializeSQLCipher {
    int rc;
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                              stringByAppendingPathComponent: @"sqlcipher.db"];
    rc = sqlite3_open([databasePath UTF8String], &db);
    if(rc != SQLITE_OK){
        NSLog(@"Failed to open database");
        return;
    }
    rc = sqlite3_key(db, password, (int)strlen(password));
    if(rc != SQLITE_OK){
        NSLog(@"Failed to key database");
        return;
    }
    rc = sqlite3_exec(db, "create table if not exists t1(a,b);", NULL, NULL, NULL);
    if(rc != SQLITE_OK){
        NSLog(@"Failed to create table");
        return;
    }
}

- (void)insertData {
    int rc;
    sqlite3_stmt *stmt;
    sqlite3_prepare(db, "insert into t1(a,b) values(?, ?)", -1, &stmt, NULL);
    sqlite3_bind_text(stmt, 1, "one for the money", -1, NULL);
    sqlite3_bind_text(stmt, 2, "two for the show", -1, NULL);
    rc = sqlite3_step(stmt);
    if(rc != SQLITE_DONE){
        NSLog(@"Failed to insert data");
        return;
    }
    sqlite3_finalize(stmt);
}

- (void) displayData {
    int rc;
    if(db == NULL){
        [self initializeSQLCipher];
    }
    NSMutableString *buffer = [NSMutableString stringWithString:@""];
    sqlite3_stmt *stmt;
    sqlite3_prepare(db, "select * from t1;", -1, &stmt, NULL);
    while((rc = sqlite3_step(stmt)) == SQLITE_ROW){
        [buffer appendString:[NSString stringWithFormat:@"a:%s b:%s\n",
                              sqlite3_column_text(stmt, 0), sqlite3_column_text(stmt, 1)]];
    }
    NSLog(@"%s", [buffer UTF8String]);
    [_textOutput setText:buffer];
}

@end

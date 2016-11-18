//
//  VSDBSortedSetTest.m
//  VSDB
//
//  Created by Valo on 16/7/14.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSSDBTests.h"

@interface SSDBSortedSetTests : VSSDBTests

@end

@implementation SSDBSortedSetTests

- (void)testZset{
    NSString *name = @"tests";
    NSString *key  = @"test:key:2";
    NSString *score = @"5";
    BOOL ret = [self.vssdb zset:name key:key score:score];
    NSLog(@"ret = %@", @(ret));
}

- (void)testZget{
    NSString *name = @"tests";
    NSString *key = @"test:key:2";
    NSString *score = [self.vssdb zget:name key:key];
    NSLog(@"score = %@", score);
}

- (void)testZdel{
    NSString *name = @"tests";
    NSString *key = @"test:key:1";
    BOOL ret = [self.vssdb zdel:name key:key];
    NSLog(@"ret = %@", @(ret));
}

- (void)testZincr{
    NSString *name = @"tests";
    NSString *key = @"test:key:1";
    int64_t nval = [self.vssdb zincr:name key:key by:2];
    NSLog(@"nval = %@", @(nval));
}

- (void)testZsize{
    NSString *name = @"tests";
    int64_t size = [self.vssdb zsize:name];
    NSLog(@"size = %@", @(size));
}

- (void)testZrank{
    NSString *name = @"tests";
    NSString *key = @"test:key:1";
    int64_t ret = [self.vssdb zrank:name key:key];
    NSLog(@"ret = %@", @(ret));
}

- (void)testZrrank{
    NSString *name = @"tests";
    NSString *key = @"test:key:1";
    int64_t ret = [self.vssdb zrrank:name key:key];
    NSLog(@"ret = %@", @(ret));
}

- (void)testZrange{
    NSArray *list = [self.vssdb zrange:@"tests" offset:0 limit:1];
    printf("---------\n");
    for (VSDSortedSetItem *item  in list) {
        printf("%s | %s | %s\n", item.name.UTF8String, item.key.UTF8String, item.score.UTF8String);
    }
    printf("---------\n");
}

- (void)testZrrange{
    NSArray *list = [self.vssdb zrrange:@"tests" offset:0 limit:10];
    printf("---------\n");
    for (VSDSortedSetItem *item  in list) {
        printf("%s | %s | %s\n", item.name.UTF8String, item.key.UTF8String, item.score.UTF8String);
    }
    printf("---------\n");
}

- (void)testZscan{
    NSArray *list = [self.vssdb zscan:@"tests" key:@"test:key:1" startScore:@"1" endScore:@"10" limit:20];
    printf("---------\n");
    for (VSDSortedSetItem *item  in list) {
        printf("%s | %s | %s\n", item.name.UTF8String, item.key.UTF8String, item.score.UTF8String);
    }
    printf("---------\n");
}

- (void)testZrscan{
    NSArray *list = [self.vssdb zrscan:@"tests" key:@"test:key:1" startScore:@"10" endScore:@"1" limit:20];
    printf("---------\n");
    for (VSDSortedSetItem *item  in list) {
        printf("%s | %s | %s\n", item.name.UTF8String, item.key.UTF8String, item.score.UTF8String);
    }
    printf("---------\n");
}

- (void)testZlist{
    NSArray *list = [self.vssdb zlist:@"tes*" endName:@"testss" limit:10];
    printf("---------\n");
    for (NSString *item  in list) {
        printf("%s \n", item.UTF8String);
    }
    printf("---------\n");
}

- (void)testZrlist{
    NSArray *list = [self.vssdb zrlist:@"testss" endName:@"tes*" limit:10];
    printf("---------\n");
    for (NSString *item  in list) {
        printf("%s \n", item.UTF8String);
    }
    printf("---------\n");
}

- (void)testZfix{
    NSString *name = @"tests";
    int64_t size = [self.vssdb zfix:name];
    NSLog(@"size = %@", @(size));
}

@end

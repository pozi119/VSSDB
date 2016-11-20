//
//  VSDBKeyValueTest.m
//  VSDB
//
//  Created by Valo on 16/7/13.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSSDBTests.h"

@interface SSDBKeyValueTests : VSSDBTests

@end

@implementation SSDBKeyValueTests

- (void)testSet{
    NSString *key = @"test:key:5";
    NSString *val = @"6";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [self.vssdb set:key data:data];
    BOOL ret1 = 1;//[self.vssdb expire:key ttl:5];
    NSLog(@"ret = %@,%@", @(ret),@(ret1));
}

- (void)testGet{
    NSString *key = @"test:key:5";
    NSData *val = [self.vssdb get:key];
    NSString *str = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
    NSLog(@"str = %@", str);
}

- (void)testSetnx{
    NSString *key = @"test:key:5";
    NSString *val = @"5";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [self.vssdb setnx:key data:data];
    NSLog(@"ret = %@", @(ret));
}

- (void)testIncr{
    NSString *key = @"test:key:5";
    int64_t val = [self.vssdb incr:key by:2];
    NSLog(@"nval = %@", @(val));
}

- (void)testDel{
    NSString *key = @"test:key:5";
    BOOL ret = [self.vssdb del:key];
    NSLog(@"ret = %@", @(ret));
}

- (void)testMultiset{
    NSDictionary *dic = @{
                          @"test:key:6":@(6),
                          @"test:key:7":@"7",
                          @"test:key:8":@"val8",
                          @"test:key:9":[NSData dataWithBytes:"data9" length:5]};
    BOOL ret = [self.vssdb multi_set:dic];
    NSLog(@"ret = %@", @(ret));
}

- (void)testMultget{
    NSArray *keys = @[@"test:key:1",
                      @"test:key:2",
                      @"test:key:3",
                      @"test:key:4",
                      @"test:key:5",
                      @"test:key:6",
                      @"test:key:7",
                      @"test:key:8",
                      @"test:key:9"];
    for (NSString *key  in keys) {
        NSData *val = [self.vssdb get:key];
        NSString *str = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
        NSLog(@"key = %@, str = %@, val = %@", key, str, val);
    }
}

- (void)testMultDel{
    NSArray *keys = @[@"test:key:7",
                      @"test:key:8",
                      @"test:key:9"];
    BOOL ret = [self.vssdb multi_del:keys];
    NSLog(@"ret = %@", @(ret));
}

- (void)testSetBit{
    NSString *key = @"test:key:5";
    BOOL ret = [self.vssdb setbit:key bitOffset:2 on:0];
    NSLog(@"ret = %@", @(ret));
}

- (void)testGetBit{
    NSString *key = @"test:key:5";
    int ret = [self.vssdb getbit:key bitOffset:3];
    NSLog(@"ret = %@", @(ret));
}

- (void)testGetSet{
    NSString *key = @"test:key:5";
    NSString *val = @"val52";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    NSData *old = [self.vssdb getset:key newData:data];
    NSLog(@"old = %@", old);
}

- (void)testScan{
    NSString *startKey = @"test:key:0";
    NSString *endKey = @"test:key:9";
    NSArray *array = [self.vssdb scan:startKey endKey:endKey limit:10];
    printf("---------\n");
    for (VSDKeyValItem *item  in array) {
        printf("%s : %s\n", item.key.UTF8String, item.val.bytes);
    }
    printf("---------\n");
}

- (void)testRscan{
    NSString *startKey = @"test:key:9";
    NSString *endKey = @"test:key";
    NSArray *array = [self.vssdb rscan:startKey endKey:endKey limit:10];
    printf("---------\n");
    for (VSDKeyValItem *item  in array) {
        printf("%s : %s\n", item.key.UTF8String, item.val.bytes);
    }
    printf("---------\n");
}

@end

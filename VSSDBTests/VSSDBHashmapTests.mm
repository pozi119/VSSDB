//
//  VSDBHashmapTest.m
//  VSDB
//
//  Created by Valo on 16/7/14.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSSDBTests.h"

@interface VSSDBHashmapTests : VSSDBTests

@end

@implementation VSSDBHashmapTests

- (void)testHset{
    NSDictionary *dic = @{@"aa":@"11",
                          @"bb":@"22",
                          @"cc":@"33",
                          @"dd":@"44",
                          @"ee":@"55",
                          @"ff":@"66"};
    NSString *name = @"tests";
//    NSString *key = @"test:key:1";
//    NSString *val = @"val1";
//    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    __block BOOL ret = YES;
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        ret = ret && [self.vssdb hset:name key:key data:[obj dataUsingEncoding:NSUTF8StringEncoding]];
    }];
//    BOOL ret = [self.vssdb hset:name key:key data:data];
    NSLog(@"ret = %@", @(ret));
}

- (void)testHget{
    NSString *name = @"tests";
    NSString *key = @"test:key:1";
    NSData *data = [self.vssdb hget:name key:key];
    NSLog(@"data = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

- (void)testHdel{
    NSString *name = @"tests";
    NSString *key = @"test:key:5";
    BOOL ret = [self.vssdb hdel:name key:key];
    NSLog(@"ret = %@", @(ret));
}

- (void)testHincr{
    NSString *name = @"tests";
    NSString *key = @"test:key:1";
    int64_t nval = [self.vssdb hincr:name key:key by:2];
    NSLog(@"nval = %@", @(nval));
}

- (void)testHsize{
    NSString *name = @"tests";
    int64_t size = [self.vssdb hsize:name];
    NSLog(@"size = %@", @(size));
}

- (void)testHclear{
    NSString *name = @"tests";
    int64_t size = [self.vssdb hclear:name];
    NSLog(@"size = %@", @(size));
}

- (void)testHlist{
    NSArray *list = [self.vssdb hlist:@"tes*" endName:@"testss" limit:10];
    printf("---------\n");
    for (NSString *item  in list) {
        printf("%s \n", item.UTF8String);
    }
    printf("---------\n");
}

- (void)testHscan{
    NSArray *list = [self.vssdb hrscan:@"tests" startKey:@"ff" endKey:@"ab" limit:3];
    printf("---------\n");
    for (VSDHashmapItem *item  in list) {
        printf("%s | %s | %s\n", item.name.UTF8String, item.key.UTF8String, item.val.bytes);
    }
    printf("---------\n");
}

- (void)testHrscan{
    NSArray *list = [self.vssdb hrscan:@"tests" startKey:@"test:key:9" endKey:@"test:key:" limit:10];
    printf("---------\n");
    for (VSDHashmapItem *item  in list) {
        printf("%s | %s | %s\n", item.name.UTF8String, item.key.UTF8String, item.val.bytes);
    }
    printf("---------\n");
}

@end

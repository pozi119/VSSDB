//
//  VSDBListTest.m
//  VSDB
//
//  Created by Valo on 16/7/14.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSSDBTests.h"

@interface SSDBListTests : VSSDBTests

@end

@implementation SSDBListTests

- (void)testQsize{
    NSString *name = @"tests";
    int64_t size = [self.vssdb qsize:name];
    NSLog(@"size = %@", @(size));
}

- (void)testQfront{
    NSString *front = [self.vssdb qfront:@"tests"];
    NSLog(@"front = %@",front);
}

- (void)testQback{
    NSString *back = [self.vssdb qback:@"tests"];
    NSLog(@"front = %@", back);
}

- (void)testQpushFront{
    NSString *val  = @"bbb";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [self.vssdb qpush_front:@"tests" data:data];
    NSLog(@"ret = %@", @(ret));
}

- (void)testQpushBack{
    NSString *val  = @"bbb";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [self.vssdb qpush_back:@"tests" data:data];
    NSLog(@"ret = %@", @(ret));
}

- (void)testQPopFront{
    NSData *front = [self.vssdb qpop_front:@"tests"];
    NSLog(@"front = %@", front);
}

- (void)testQPopback{
    NSData *back = [self.vssdb qpop_back:@"tests"];
    NSLog(@"front = %@", back);
}

- (void)testQfix{
    NSString *name = @"tests";
    int64_t size = [self.vssdb qfix:name];
    NSLog(@"size = %@", @(size));
}

- (void)testQlist{
    NSArray *list = [self.vssdb qlist:@"test" endName:@"tests" limit:0];
    printf("---------\n");
    for (NSString *item  in list) {
        printf("%s \n", item.UTF8String);
    }
    printf("---------\n");
}

- (void)testQrlist{
    NSArray *list = [self.vssdb qrlist:@"test" endName:@"tests" limit:0];
    printf("---------\n");
    for (NSString *item  in list) {
        printf("%s \n", item.UTF8String);
    }
    printf("---------\n");
}

- (void)testQslice{
    NSArray *list = [self.vssdb qslice:@"tests" offset:0 limit:10];
    printf("---------\n");
    for (NSString *item  in list) {
        printf("%s \n", item.UTF8String);
    }
    printf("---------\n");
}

- (void)testQget{
    NSString *data = [self.vssdb qget:@"tests" index:0];
    NSLog(@"data = %@", data);
}

- (void)testQset{
    NSString *val  = @"ccc";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [self.vssdb qset:@"tests" index:1 data:data];
    NSLog(@"ret = %@", @(ret));
}

- (void)testQsetBySeq{
    NSString *val  = @"ddd";
    NSData *data = [val dataUsingEncoding:NSUTF8StringEncoding];
    BOOL ret = [self.vssdb qset_by_seq:@"tests" seq:0 data:data];
    NSLog(@"ret = %@", @(ret));
}

@end

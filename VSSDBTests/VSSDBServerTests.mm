//
//  VSDCommandServerTests.m
//  VSDB
//
//  Created by Valo on 16/7/13.
//  Copyright © 2016年 valo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSSDBTests.h"

@interface SSDCommandServerTests : VSSDBTests

@end

@implementation SSDCommandServerTests

- (void)testFlushdb {
    int ret = [self.vssdb flushdb];
    NSLog(@"ret = %@", @(ret));
}

- (void)testSize {
    int64_t size = [self.vssdb size];
    NSLog(@"ret = %@", @(size));
}

- (void)testCompact {
    [self.vssdb compact];
}


@end

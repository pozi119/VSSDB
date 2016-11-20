//
//  VSSDBTests.m
//  VSSDBTests
//
//  Created by Valo on 2016/11/18.
//  Copyright © 2016年 Valo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VSSDBTests.h"

@implementation VSSDBTests

- (void)setUp {
    [super setUp];
    self.vssdb = [[VSSDB alloc] initWithName:@"test"];
    [self.vssdb open];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.vssdb close];
    [super tearDown];
}

- (void)testExample{

}


@end

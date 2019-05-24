//
// Copyright 2017 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <XCTest/XCTest.h>

#import "CommonLib/Config/GREYAppState.h"
#import "CommonLib/Config/GREYConfiguration.h"

@interface GREYConfigurationTest : XCTestCase {
  GREYConfiguration *_configuration;
}
@end

@implementation GREYConfigurationTest

- (void)setUp {
  [super setUp];
  _configuration = GREYConfiguration.sharedConfiguration;
}

- (void)testQueryForUnsetConfigurationsThrowsException {
  [self grey_assertThatExceptionThrownWithName:@"NSUnknownKeyException"
                                andDescription:@"Unknown configuration key: Unset"
                           whileExecutingBlock:^{
                             [_configuration valueForConfigKey:@"Unset"];
                           }];

  [self grey_assertThatExceptionThrownWithName:@"NSUnknownKeyException"
                                andDescription:@"Unknown configuration key: Unset"
                           whileExecutingBlock:^{
                             [_configuration boolValueForConfigKey:@"Unset"];
                           }];

  [self grey_assertThatExceptionThrownWithName:@"NSUnknownKeyException"
                                andDescription:@"Unknown configuration key: Unset"
                           whileExecutingBlock:^{
                             [_configuration integerValueForConfigKey:@"Unset"];
                           }];

  [self grey_assertThatExceptionThrownWithName:@"NSUnknownKeyException"
                                andDescription:@"Unknown configuration key: Unset"
                           whileExecutingBlock:^{
                             [_configuration stringValueForConfigKey:@"Unset"];
                           }];
}

- (void)testQueryForDefaultConfigurationReturnsDefaultValue {
  [_configuration setDefaultValue:@"foo" forConfigKey:@"bar1"];

  XCTAssertNotNil([_configuration valueForConfigKey:kGREYConfigKeyActionConstraintsEnabled]);
  XCTAssertEqualObjects([_configuration valueForConfigKey:@"bar1"], @"foo");
}

- (void)testCustomDefaultValueCanBeOverritten {
  [_configuration setDefaultValue:@(1.0) forConfigKey:@"bar"];
  [_configuration setDefaultValue:@(2.0) forConfigKey:@"bar"];

  XCTAssertEqual([[_configuration valueForConfigKey:@"bar"] doubleValue], 2.0);

  [_configuration setValue:@(3.0) forConfigKey:@"bar"];
  XCTAssertEqual([[_configuration valueForConfigKey:@"bar"] doubleValue], 3.0);
}

- (void)testQueryForSetConfigurationReturnsUpdatedValue {
  [_configuration setValue:@NO forConfigKey:kGREYConfigKeyActionConstraintsEnabled];
  XCTAssertEqual([_configuration valueForConfigKey:kGREYConfigKeyActionConstraintsEnabled], @NO);

  [_configuration setValue:@YES forConfigKey:kGREYConfigKeyActionConstraintsEnabled];
  XCTAssertEqual([_configuration valueForConfigKey:kGREYConfigKeyActionConstraintsEnabled], @YES);
}

- (void)testResetDoesNotRemoveCustomDefaultValues {
  [_configuration setDefaultValue:@NO forConfigKey:@"defaultValue1"];
  [_configuration setDefaultValue:@(5.0) forConfigKey:@"defaultValue2"];

  [_configuration reset];
  XCTAssertEqual([_configuration valueForConfigKey:@"defaultValue1"], @NO);

  double actualValue = [[_configuration valueForConfigKey:@"defaultValue2"] doubleValue];
  XCTAssertEqual(actualValue, 5.0);
}

- (void)testResetRemovesValue {
  [_configuration setValue:@NO forConfigKey:kGREYConfigKeyActionConstraintsEnabled];
  [_configuration setValue:@(1.1) forConfigKey:kGREYConfigKeyCALayerMaxAnimationDuration];

  [_configuration reset];

  XCTAssertEqual([_configuration valueForConfigKey:kGREYConfigKeyActionConstraintsEnabled], @YES);
  double actualValue =
      [[_configuration valueForConfigKey:kGREYConfigKeyCALayerMaxAnimationDuration] doubleValue];
  XCTAssertEqual(actualValue, 10.0);
}

- (void)testQueryBoolReturnsConvertedValue {
  [_configuration setValue:@NO forConfigKey:kGREYConfigKeyActionConstraintsEnabled];
  XCTAssertFalse([_configuration boolValueForConfigKey:kGREYConfigKeyActionConstraintsEnabled]);

  [_configuration setValue:@YES forConfigKey:kGREYConfigKeyActionConstraintsEnabled];
  XCTAssertTrue([_configuration boolValueForConfigKey:kGREYConfigKeyActionConstraintsEnabled]);
}

- (void)testQueryDoubleReturnsConvertedValue {
  [_configuration setValue:@(1.0) forConfigKey:kGREYConfigKeyCALayerMaxAnimationDuration];
  double actualValue =
      [_configuration doubleValueForConfigKey:kGREYConfigKeyCALayerMaxAnimationDuration];
  XCTAssertEqual(actualValue, 1.0);

  [_configuration setValue:@(1.3) forConfigKey:kGREYConfigKeyCALayerMaxAnimationDuration];
  actualValue = [_configuration doubleValueForConfigKey:kGREYConfigKeyCALayerMaxAnimationDuration];
  XCTAssertEqual(actualValue, 1.3);
}

- (void)testQueryUIntegerReturnConvertedValue {
  [_configuration setValue:@(kGREYPendingCAAnimation) forConfigKey:kGREYConfigKeyIgnoreAppStates];
  NSUInteger actualValue =
      [_configuration unsignedIntegerValueForConfigKey:kGREYConfigKeyIgnoreAppStates];
  XCTAssertEqual(actualValue, kGREYPendingCAAnimation);

  [_configuration setValue:@(kGREYIdle) forConfigKey:kGREYConfigKeyIgnoreAppStates];
  actualValue = [_configuration unsignedIntegerValueForConfigKey:kGREYConfigKeyIgnoreAppStates];
  XCTAssertEqual(actualValue, 0UL);
}

- (void)testArrayReturnsSameObjects {
  NSArray *array = @[ @"foo", @(YES), @(42) ];
  [_configuration setValue:array forConfigKey:@"foo"];
  XCTAssertEqualObjects([_configuration arrayValueForConfigKey:@"foo"], array);
  [_configuration setValue:@[] forConfigKey:@"foo"];
  XCTAssertEqual([_configuration arrayValueForConfigKey:@"foo"].count, (NSUInteger)0);
}

- (void)testSettingEmptyArray {
  NSArray *array = @[];
  [_configuration setValue:array forConfigKey:@"foo"];
  XCTAssertEqualObjects([_configuration arrayValueForConfigKey:@"foo"], array);
}

- (void)testMacrosHaveSameResultsAsRespectiveMethods {
  [_configuration setValue:@YES forConfigKey:@"boolConfig"];
  XCTAssertEqual(GREY_CONFIG_BOOL(@"boolConfig"),
                 [_configuration boolValueForConfigKey:@"boolConfig"]);

  [_configuration setValue:@1234 forConfigKey:@"intConfig"];
  XCTAssertEqual(GREY_CONFIG_INTEGER(@"intConfig"),
                 [_configuration integerValueForConfigKey:@"intConfig"]);

  [_configuration setValue:@"StringValue" forConfigKey:@"stringConfig"];
  XCTAssertEqualObjects(GREY_CONFIG_STRING(@"stringConfig"),
                        [_configuration stringValueForConfigKey:@"stringConfig"]);

  [_configuration setValue:@(1.2) forConfigKey:@"doubleConfig"];
  XCTAssertEqual(GREY_CONFIG_DOUBLE(@"doubleConfig"),
                 [_configuration doubleValueForConfigKey:@"doubleConfig"]);

  [_configuration setValue:@[ @"hello" ] forConfigKey:@"arrayConfig"];
  XCTAssertEqual(GREY_CONFIG_ARRAY(@"arrayConfig"),
                 [_configuration arrayValueForConfigKey:@"arrayConfig"]);
}

#pragma mark - Private

/**
 *  Utility method that invokes a block and asserts that it throws an exception.
 *
 *  @param exceptionName The name of the exception that is expected to be thrown.
 *  @param description   The description of the exception that is expected to be thrown.
 *  @param block         The block to be executed.
 */
- (void)grey_assertThatExceptionThrownWithName:(NSString *)exceptionName
                                andDescription:description
                           whileExecutingBlock:(void (^)())block {
  @try {
    block();
    XCTFail(@"Block should fail with %@", exceptionName);
  } @catch (NSException *exception) {
    XCTAssertEqualObjects(exceptionName, exception.name);
    XCTAssertEqualObjects(description, exception.description);
  }
}

@end

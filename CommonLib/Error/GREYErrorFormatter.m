//
// Copyright 2020 Google Inc.
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

#import "GREYErrorFormatter.h"

#import "GREYObjectFormatter.h"
#import "GREYInteraction.h"
#import "GREYErrorConstants.h"
#import "NSError+GREYCommon.h"
#import "GREYError+Private.h"
#import "GREYFatalAsserts.h"

#pragma mark - UI Hierarchy Keys

static NSString *const kHierarchyWindowLegendKey                 = @"[Window 1]";
static NSString *const kHierarchyAcessibilityLegendKey           = @"[AX]";
static NSString *const kHierarchyUserInteractionEnabledLegendKey = @"[UIE]";
static NSString *const kHierarchyBackWindowKey                   = @"Back-Most Window";
static NSString *const kHierarchyAccessibilityKey                = @"Accessibility";
static NSString *const kHierarchyUserInteractionEnabledKey       = @"User Interaction Enabled";
static NSString *const kHierarchyLegendKey                       = @"Legend";
static NSString *const kHierarchyHeaderKey                       = @"UI Hierarchy (ordered by wind"
                                                                   @"ow level, back to front):\n";

#pragma mark - GREYErrorFormatter

@implementation GREYErrorFormatter

#pragma mark - Public Methods

+ (NSString *)formattedDescriptionForError:(GREYError *)error {
  if (GREYShouldUseErrorFormatterForError(error)) {
    return LoggerDescription(error);
  }
  return [GREYObjectFormatter formatDictionary:[error grey_descriptionDictionary]
                                        indent:kGREYObjectFormatIndent
                                     hideEmpty:YES
                                      keyOrder:nil];
}

#pragma mark - Public Functions

BOOL GREYShouldUseErrorFormatterForError(GREYError *error) {
  return [error.domain isEqualToString:kGREYInteractionErrorDomain] &&
         (error.code == kGREYInteractionElementNotFoundErrorCode ||
          error.code == kGREYInteractionActionFailedErrorCode);
}

BOOL GREYShouldUseErrorFormatterForExceptionReason(NSString *reason) {
  return [reason containsString:@"the desired element was not found"] ||
         [reason containsString:@"Failed to type"] ||
         [reason containsString:@"GREYKeyboard: No known SHIFT key"] ||
         [reason containsString:@"Reason for action failure was not provided."] ||
         [reason containsString:@"Failed to take snapshot."] ||
         [reason containsString:@"Keyboard did not appear after tapping on an element"] ||
         [reason containsString:@"First Responder of Element does not conform to UITextInput"] ||
         [reason containsString:@"Failed to find stepper buttons"] ||
         [reason containsString:@"Cannot set stepper value due to"] ||
         [reason containsString:@"Failed to exactly step to"] ||
         [reason containsString:@"Failed to find Picker Column."] ||
         [reason containsString:@"UIPickerView does not contain"] ||
         [reason containsString:@"Slider's Minimum is"] ||
         [reason containsString:@"Element is not attached to a window"] ||
         [reason containsString:@"Unknown tap type"] ||
         [reason containsString:@"it is outside window's bounds"] ||
         [reason containsString:@"Deeplink open action failed"];
}

#pragma mark - Static Functions

static NSString *FormattedHierarchy(NSString *hierarchy) {
  if (!hierarchy) {
    return nil;
  }
  NSMutableArray<NSString*> *logger = [[NSMutableArray alloc] init];
  [logger addObject:kHierarchyHeaderKey];
  NSString *windowLegend = kHierarchyWindowLegendKey;
  NSString *axLegend = kHierarchyAcessibilityLegendKey;
  NSString *uieLegend = kHierarchyUserInteractionEnabledLegendKey;
  NSDictionary<NSString *, NSString *> *legendLabels = @{
    windowLegend : kHierarchyBackWindowKey,
    axLegend : kHierarchyAccessibilityKey,
    uieLegend : kHierarchyUserInteractionEnabledKey
  };
  NSArray<NSString *> *keyOrder = @[ windowLegend, axLegend, uieLegend ];
  NSString *legendDescription = [GREYObjectFormatter formatDictionary:legendLabels
                                                               indent:kGREYObjectFormatIndent
                                                            hideEmpty:NO
                                                             keyOrder:keyOrder];
  [logger addObject:[NSString stringWithFormat:@"%@: %@\n", kHierarchyLegendKey,
                     legendDescription]];
  [logger addObject:hierarchy];
  return [logger componentsJoinedByString:@"\n"];
}

static NSString *LoggerDescription(GREYError *error) {
  NSMutableArray<NSString *> *logger = [[NSMutableArray alloc] init];
  
  NSString *exceptionReason = error.localizedDescription;
  if (exceptionReason) {
    [logger addObject:[NSString stringWithFormat:@"\n%@", exceptionReason]];
  }
  
  NSString *recoverySuggestion = error.userInfo[kErrorDetailRecoverySuggestionKey];
  if (recoverySuggestion) {
    [logger addObject:recoverySuggestion];
  }
  
  NSString *elementMatcher = error.userInfo[kErrorDetailElementMatcherKey];
  if (elementMatcher) {
    [logger addObject:[NSString stringWithFormat:@"%@:\n%@", kErrorDetailElementMatcherKey,
                       elementMatcher]];
  }
  
  NSString *assertionCriteria = error.userInfo[kErrorDetailAssertCriteriaKey];
  if (assertionCriteria) {
    [logger addObject:[NSString stringWithFormat:@"%@: %@", kErrorDetailAssertCriteriaKey,
                       assertionCriteria]];
  }
  NSString *actionCriteria = error.userInfo[kErrorDetailActionNameKey];
  if (actionCriteria) {
    [logger addObject:[NSString stringWithFormat:@"%@: %@", kErrorDetailActionNameKey,
                       actionCriteria]];
  }
  
  NSString *searchActionInfo = error.userInfo[kErrorDetailSearchActionInfoKey];
  if (searchActionInfo) {
    [logger addObject:[NSString stringWithFormat:@"%@\n%@", kErrorDetailSearchActionInfoKey,
                       searchActionInfo]];
  }
  
  NSString *nestedError = error.nestedError.description;
  if (nestedError) {
    [logger addObject:[NSString stringWithFormat:@"Underlying Error:\n%@", nestedError]];
  }
  
  NSString *UIHierarchy = FormattedHierarchy(error.appUIHierarchy);
  if (UIHierarchy) {
    [logger addObject:UIHierarchy];
  }
  
  return [NSString stringWithFormat:@"%@\n", [logger componentsJoinedByString:@"\n\n"]];
}

@end
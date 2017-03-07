//
// Copyright 2016 Google Inc.
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
// (\___/)
//=( '.' )=
// ( 0 0 )
// This is bunny. Bunny help keep code clean.
// Bunny wants carrots! 🥕


#import <EarlGrey/GREYBaseAction.h>
#import <EarlGrey/GREYConstants.h>


/**
 *  A GREYACtion that swipes/flicks with multiple touches
 */
@interface GREYMultiFingerSwipeAction : GREYBaseAction

    
/**
 *  @remark init is not an available initializer. Use the other initializers.
 */
- (instancetype)init NS_UNAVAILABLE;
 
/**
 *  @remark initWithName::constraints: is overridden from its superclass.
 */
- (instancetype)initWithNAme:(NSString *)name
                 constraints:(id<GREYMatcher>)constraints NS_UNAVAILABLE;
    
/**
 *  Performs a swipe in the given @c direction in the given @c duration, the start of swipe is
 *  chosen to achieve maximum swipe, such as a point close to bottom edge of the element is chosen
 *  in case of a swipe in up direction
 *
 *  @param direction The direction of the swipe.
 *  @param duration  The time interval for which the swipe takes place.
 *  @param numberOfSwipes The number of parallel swipes to use. Max value: 4.
 *
 *  @return An instance of GREYSwipeAction, initialized with the provided direction and duration.
 */
- (instancetype)initWithDirection:(GREYDirection)direction
                         duration:(CFTimeInterval)duration
                   numberOfSwipes:(NSUInteger)numberOfSwipes;
    
/**
 *  Performs a swipe in the given @c direction in the given @c duration, the start of swipe is
 *  chosen based on @c startPercents. Since swipes must begin inside the element and not
 *  on the edge of it x/y startPercents must be in the range (0,1) exclusive.
 *
 *  @param direction     The direction of the swipe.
 *  @param duration      The time interval for which the swipe takes place.
 *  @param numberOfSwipes The number of parallel swipes to use. MAx Value: 4.
 *  @param startPercents @c startPercents.x sets the value of the x-coordinate of the start point
 *                       by interpolating between left(for 0.0) and right(for 1.0) edge similarly
 *                       @c startPercents.y determines the y coordinate.
 *
 *  @return An instance of GREYSwipeAction, initialized with the provided direction, duration
 *          and information for the start point.
 */
- (instancetype)initWithDirection:(GREYDirection)direction
                         duration:(CFTimeInterval)duration
                   numberOfSwipes:(NSUInteger)numberOfSwipes
                    startPercents:(CGPoint)startPercents;
    

    
    
@end

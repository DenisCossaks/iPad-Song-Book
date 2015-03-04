//
//  AirTurnView.h
//  AirTurnInterface
//
//  Created by Nick Brook on 04/01/2012.
//  Copyright (c) 2012 Nick Brook. All rights reserved.
//
//  Permission is hereby granted, to any person (the “Licensee”) who has 
//  legitimately purchased a copy of this framework, example code and 
//  associated documentation (the “Software”) from AirTurn Inc, to use the 
//  compiled binary framework and any parts of the example code within their 
//  own software for distribution and sale on the Apple App Store.  The 
//  Software must remain unmodified except any portion of the example source 
//  code which may be used and modified without restriction.  The Licensee has 
//  no right to distribute any part of the Software further beyond this 
//  Agreement.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//

/*
 If you do not want to use AirTurnInterface, you can use AirTurnView directly.  Do not use the AirTurnInterface class at all in this case, as the first time you use the AirTurnInterface class it assumes control over AirTurnView.
 
 Using AirTurnView directly allows you to manage the virtual keyboard and first responder control however you want.  AirTurnKeyboardManager is provided to help you control the virtual keyboard should you wish to take that approach.
 
 You can achieve everything that AirTurnInterface does through the public interfaces provided in this header.
 
 This class has a singleton method.  You should use this to obtain the shared instance of the AirTurnView.  I can see no real need to have more than one instance of AirTurnView, but if you do create multiple instances it should not cause any problems.
 
 */

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnTypes.h>

// The notification name
UIKIT_EXTERN NSString * const AirTurnButtonNotification;
/*
 The notification userinfo key for the button press code.
 Example:
 
 AirTurnPort button = [(NSNumber *)[[notification userInfo] objectForKey:AirTurnButtonPressedKey] intValue];
 */
UIKIT_EXTERN NSString * const AirTurnButtonPressedKey;

// Notification for connected state change
UIKIT_EXTERN NSString * const AirTurnConnectedStateChangedNotification;
UIKIT_EXTERN NSString * const AirTurnDidConnectNotification;
UIKIT_EXTERN NSString * const AirTurnDidDisconnectNotification;

// Notification for mode change
UIKIT_EXTERN NSString * const AirTurnModeChangedNotification;

@protocol AirTurnViewDelegate <NSObject>
@optional

- (void)AirTurnViewWillRemoveFromViewHeirarchy;
- (void)AirTurnViewDidRemoveFromViewHeirarchy;

- (void)AirTurnViewDidMoveToWindow:(UIWindow *)window;

// return false to prevent becoming first responder
- (BOOL)AirTurnViewShouldBecomeFirstResponder;
- (void)AirTurnViewWillBecomeFirstResponder;
- (void)AirTurnViewDidBecomeFirstResponder;
- (void)AirTurnViewDidNotBecomeFirstResponder;

// return false to prevent resigning first responder
- (BOOL)AirTurnViewShouldResignFirstResponder;
- (void)AirTurnViewWillResignFirstResponder;
- (void)AirTurnViewDidResignFirstResponder;
- (void)AirTurnViewDidNotResignFirstResponder;

@end

AIRTURN_CLASS_AVAILABLE(3_2)
@interface AirTurnView : UIView

@property(nonatomic, assign) NSObject<AirTurnViewDelegate> *delegate;
@property(nonatomic, assign) UIView *parentView;
@property(nonatomic, readonly) BOOL AirTurnConnected;
@property(nonatomic, readonly) AirTurnMode currentMode;
@property(nonatomic, readonly) NSString *currentModeString;
 
/*
 You can set your own input view (a zero rect view) as another way to disable the virtual keyboard when the AirTurnView is first responder.  This will alleviate issues with popovers but also remove the animation of the keyboard when changing first responder.
 */
@property (readwrite, retain) UIView *inputView;

+ (AirTurnView *)sharedView;

- (void)resignParentView:(UIView *)view;
- (void)removeFromViewHierarchy;
- (void)removeFromViewHeirarchy __AVAILABILITY_INTERNAL_DEPRECATED;

/* 
 the default resignFirstResponder calls the delegate methods,
 which will usually be set up to show the keyboard automatically or something.  If you want to just resign first responder with nothing else (ie the super method) call this.
 */
- (BOOL)resignFirstResponderNoDelegate;

@end

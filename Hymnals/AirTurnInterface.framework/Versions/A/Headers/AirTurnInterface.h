//
//  AirTurnInterface.h
//
//  Created by Nick Brook on 03/01/2012.
//  Copyright 2012 Nick Brook. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnTypes.h>
#import <AirTurnInterface/AirTurnView.h>

@interface UIView (AirTurnAdditions)

- (UIView *)findFirstResponder;

@end

AIRTURN_CLASS_AVAILABLE(3_2)
@interface AirTurnInterface : NSObject

/*
 Retrieve the shared interface
 */
+ (AirTurnInterface *)sharedInterface;

/* 
 Enable or disable the interface.
 If you set to YES, the interface will attempt to become the first responder, removing focus from any text field.
 */
@property(nonatomic, assign) BOOL enabled;

/* 
 You can manually set the parent window for the Airturn hidden view.  If you do not do this, it is added to the view of the root view controller of the key window when enabled.
 */
@property(nonatomic, assign) UIView *parentView;

/*
 Remove a view as the parent view of the interface.
 If the current parent view of the interface is the same as the view passed here, then the interface attaches to the root view controller's view.
 */
- (void)resignParentView:(UIView *)view;

/*
 The hidden view is always persistent in the view hierarchy if the interface is used in your project.  To remove the view from your view hierarchy, call this method.
 This method also disables the interface.  If you enable the interface or set a new parent view, the view will be added back into your view hierarchy.
 */
- (void)removeFromViewHierarchy;
/* DEPRECIATED */- (void)removeFromViewHeirarchy;/* DEPRECIATED */

/*
 If YES, and something else becomes first responder, the interface will continuously check if there is still something else which is first responder.
 If not, it becomes first responder again.
 Defaults to YES.
 */
@property(nonatomic, assign) BOOL firstResponderPolling;

/*
 How often the first responder is polled for, in seconds
 Default is 1 second
 */
@property(nonatomic, assign) NSTimeInterval firstResponderPollingInterval;

/*
 Make the AirTurn view first responder.  Should be used if another text field has taken focus, to regain control to the AirTurn interface.
 */
- (BOOL)becomeFirstResponder;

/*
 Check if the interface text view is currently the first responder.
 The interface may be enabled but not first responder if another view is temporarily first responder.
 */
- (BOOL)isFirstResponder;

/*
 By default, set to YES.
 The interface is usually resigned when another text field wants focus.  When this is the case, it is necessary to display the keyboard.
 Sometimes the interface is resigned for other reasons, for example on the transition out of a modal view controller.  In these cases the interface should not display the keyboard.  Set this property to NO to prohibit keyboard showing.
 */
@property(nonatomic, assign) BOOL displayKeyboardWhenNotFirstResponder;
@property(nonatomic, assign) BOOL displayKeyboardOnResignFirstResponder __AVAILABILITY_INTERNAL_DEPRECATED;

/*
 Manually display or hide the keyboard
 */
- (void)setKeyboardVisible:(BOOL)visible animate:(BOOL)animate;

/*
 Provided for informational purposes only.  Not guaranteed to be accurate.
 */
@property(nonatomic, readonly) BOOL AirTurnConnected;

/*
 Provided for information purposes only.  Will not be set until after a button is pressed.
 */
@property(nonatomic, readonly) AirTurnMode currentMode;

/*
 Provides a human readable string identifying the current AirTurn mode.  English.
 */
@property(nonatomic, readonly) NSString *currentModeString;

@end

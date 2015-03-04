//
//  AirTurnKeyboardManager.h
//  AirTurnInterface
//
//  Created by Nick Brook on 10/04/2012.
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

#import <UIKit/UIKit.h>
#import <AirTurnInterface/AirTurnTypes.h>

AIRTURN_CLASS_AVAILABLE(3_2)
@interface AirTurnKeyboardManager : NSObject

@property(nonatomic, readonly) CGRect keyboardFrame;

+ (AirTurnKeyboardManager *)sharedManager;

- (void)setKeyboardVisible:(BOOL)visible animate:(BOOL)animate;

- (BOOL)isKeyboardVisible;

@end

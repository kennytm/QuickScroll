/*

QSGesture.m ... Gesture handler for QuickScroll 3.
Copyright (C) 2010  KennyTM~ <kennytm@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import <UIKit/UIKit2.h>
#import "QuickScroll.h"

#define LOG NSLog

/// Check if the touches satisfy our custom gesture.
static QSScrollerType QSSatisfyGesture(NSSet* allTouchs, UITouch* anyTouch) {
	if (anyTouch.tapCount >= 3) {
		return QSScrollerType_Scrollbar;
	} else {
		return QSScrollerType_None;
	}
}

/// Check if the view is a scroller.
static BOOL QSIsScrollView(UIView* view) {
	static Class scrollViewClass = Nil;
	static Class scrollerClass = Nil;
	
	if (scrollViewClass == Nil)
		scrollViewClass = [UIScrollView class];
	if (scrollerClass == Nil) {
		// UIScroller is kinda deprecated.
		// To prevent dylinker error, we use objc_getClass here.
		scrollerClass = objc_getClass("UIScroller") ?: scrollViewClass;
	}
	
	return [view isKindOfClass:scrollViewClass] || [view isKindOfClass:scrollerClass];
}

/// Get the deepest scroll view enclosing this view, including itself.
static UIScrollView* QSGetScrollView(UIView* view) {
	while (view != nil && !QSIsScrollView(view)) {
		view = view.superview;
	}
	return (UIScrollView*)view;
}

/// Try to get the focused view and scroll view from event.
QSScrollerViewInfo QSReceiveScrollView(UIEvent* event) {
	QSScrollerViewInfo retval = {nil, nil, QSScrollerType_None};
	
	// Make sure the event is a tap event.
	if (event.type == UIEventTypeTouches) {
		NSSet* allTouches = [event allTouches];
		UITouch* anyTouch = [allTouches anyObject];
		
		if (anyTouch.isTap) {
			retval.type = QSSatisfyGesture(allTouches, anyTouch);
			if (retval.type != QSScrollerType_None) {
				retval.focusView = anyTouch.view;
				retval.scrollView = QSGetScrollView(retval.focusView);
			}
		}
	}
	
	return retval;
}


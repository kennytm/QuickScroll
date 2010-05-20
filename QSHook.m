/*

QSHook.m ... Hook QuickScroll 3 into an application.
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

#include <substrate2.h>
#import <UIKit/UIKit2.h>
#import "QuickScroll.h"
#import "QSTransitions.h"

DefineObjCHook(void, UIWindow__sendTouchesForEvent_, UIWindow* self, SEL _cmd, UIEvent* event) {
	QSScrollerViewInfo info = QSReceiveScrollView(event);
	
	// Make sure we only have 1 abstract scroller per scroll view.
	if (QSFindAbstractScroller(info.scrollView) == nil) {
		QSAbstractScroller* scroller = [QSAbstractScroller scrollerWithInfo:info];
		if (scroller != nil) {
			QSAddSubviewWithTransition(info.scrollView, scroller, QSTransition_PageCurl);
		}
	}
	
	Original(UIWindow__sendTouchesForEvent_)(self, _cmd, event);
}

static void QSInstallHooks(void) {
	Class windowClass = [UIWindow class];
	InstallObjCInstanceHook(windowClass, @selector(_sendTouchesForEvent:), UIWindow__sendTouchesForEvent_);
}


__attribute__((constructor)) static void init (void) {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	QSInstallHooks();
	
	[pool drain];
}

__attribute__((destructor)) static void terminate (void) {
}

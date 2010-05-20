/*

FILE_NAME ... FILE_DESCRIPTION
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

#import "QuickScroll.h"
#import "QSTransitions.h"

@implementation QSAbstractScroller

-(id)initWithInfo:(QSScrollerViewInfo)info_ {
	if ((self = [super initWithFrame:info_.scrollView.bounds])) {
		info = info_;
		self.backgroundColor = [UIColor redColor];
	}
	return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	QSRemoveSubviewWithTransition(self.superview, self, QSTransition_PageCurl);
}

+(QSAbstractScroller*)scrollerWithInfo:(QSScrollerViewInfo)info_ {
	Class cls;
	switch (info_.type) {
		case QSScrollerType_Pane:
			cls = [QSAbstractScroller class];
			break;
		case QSScrollerType_Scrollbar:
			cls = [QSAbstractScroller class];
			break;
		default:
			cls = nil;
			break;
	}
	
	QSAbstractScroller* scroller = [[[cls alloc] initWithInfo:info_] autorelease];
	return scroller;
}

@end

/// Find the first QSAbstractScroller in the subview of the scroll view.
QSAbstractScroller* QSFindAbstractScroller(UIScrollView* view) {
	Class cls = [QSAbstractScroller class];
	for (QSAbstractScroller* subview in view.subviews)
		if ([subview isKindOfClass:cls])
			return subview;
	return nil;
}


/*

QSAbstractScroller.h ... Header for QSAbstractScroller
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

#ifndef QSABSTRACTSCROLLER_H_uqyop4uk55a
#define QSABSTRACTSCROLLER_H_uqyop4uk55a

#import <UIKit/UIKit.h>

typedef enum {
	QSScrollerType_None,
	QSScrollerType_Pane,
	QSScrollerType_Scrollbar
} QSScrollerType;

typedef struct {
	UIScrollView* scrollView;
	UIView* focusView;
	QSScrollerType type;
} QSScrollerViewInfo;

@interface QSAbstractScroller : UIView {
	QSScrollerViewInfo info;
}
+(QSAbstractScroller*)scrollerWithInfo:(QSScrollerViewInfo)info_;
@end

#if __cplusplus
extern "C" {
#endif
	
	QSAbstractScroller* QSFindAbstractScroller(UIScrollView* view);
	
#if __cplusplus
}
#endif

#endif
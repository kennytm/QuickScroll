/*

QuickScroll.h ... Header for QuickScroll 3.
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

#ifndef QUICKSCROLL_H_93utqr3zu3
#define QUICKSCROLL_H_93utqr3zu3

#import <UIKit/UIKit2.h>
#import "QSAbstractScroller.h"
#import "QSTransitions.h"

#if __cplusplus
extern "C" {
#endif	
	
	QSScrollerViewInfo QSReceiveScrollView(UIEvent* event);

	UIImage* QSRenderLayer(CALayer* layer, CGSize target_size, BOOL multicolumn, CGRect* p_final_rect);
	
	
	
#if __cplusplus
}
#endif

#endif

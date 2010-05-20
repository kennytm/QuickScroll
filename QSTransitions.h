/*

QSTransitions.h ... Dismiss or show a view with animation.
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

#ifndef QSTRANSITIONS_H_lp6hyemsgm
#define QSTRANSITIONS_H_lp6hyemsgm

#import <UIKit/UIKit.h>

#if __cplusplus
extern "C" {
#endif
	
	typedef enum {
		QSTransition_None,
		QSTransition_Fade,	// Fade in / Fade out
		QSTransition_Flip,	// Flip from right / Flip from left
		QSTransition_Slide,	// Slide in / slide out
		QSTransition_PageCurl	// Page curl in / page curl out
	} QSTransition;
	
	void QSAddSubviewWithTransition(UIView* view, UIView* subview, QSTransition transition);
	void QSRemoveSubviewWithTransition(UIView* view, UIView* subview, QSTransition transition);
	
#if __cplusplus
}
#endif

#endif

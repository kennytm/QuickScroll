/*

QSTransitions ... Transit 
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

#import "QSTransitions.h"

/// Compute the origin the subview should slide to/from.
static CGRect QSFinalSlideOrigin(CGSize canvas_size, CGRect target_rect) {
	// To determine from which side should the view slide in, we compute the
	// speed of sliding assuming a constant time. Suppose we want to slide from
	// bottom, then the speed is
	//
	//      speed = (distance from top edge to bottom of canvas) / time
	// 
	// Then we find the side which has lowest speed. In case of tie, the following
	// precedence is taken:
	//
	//      right, bottom, left, top.
	
	// Step 1: Find the distance (hence speed) to slide.
	CGFloat dist_from_right = canvas_size.width - target_rect.origin.x;
	CGFloat dist_from_bottom = canvas_size.height - target_rect.origin.y;
	CGFloat dist_from_left = target_rect.origin.x + target_rect.size.width;
	CGFloat dist_from_top = target_rect.origin.y + target_rect.size.height;
	
	// Step 2: Find the shortest direction.
	CGFloat cur_dist = dist_from_right;
	int slide_dir = 0;
	if (dist_from_bottom < cur_dist) {
		cur_dist = dist_from_bottom;
		slide_dir = 1;
	}
	if (dist_from_left < cur_dist) {
		cur_dist = dist_from_left;
		slide_dir = 2;
	}
	if (dist_from_top < cur_dist) {
		cur_dist = dist_from_top;
		slide_dir = 3;
	}
	
	// Step 3: Find the origin of initial position to slide in with the given direction.
	CGRect final_frame = target_rect;
	switch (slide_dir) {
		case 0:	// right.
			final_frame.origin.x = canvas_size.width;
			break;
		case 1:	// bottom.
			final_frame.origin.y = canvas_size.height;
			break;
		case 2:	// left.
			final_frame.origin.x = -target_rect.size.width;
			break;
		case 3:	// top.
			final_frame.origin.y = -target_rect.size.height;
			break;
	}
	
	return final_frame;
}

static void QSAddSubviewWithComplexTransition(UIView* view, UIView* subview, QSTransition transition, BOOL transit_in) {
	UIViewAnimationTransition trans;
	if (transition == QSTransition_Flip)
		trans = transit_in ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft;
	else
		trans = transit_in ? UIViewAnimationTransitionCurlDown : UIViewAnimationTransitionCurlUp;
	
	[UIView beginAnimations:@"QSTransitionAnimation" context:NULL];
	[UIView setAnimationTransition:trans forView:view cache:YES];
	if (transit_in)
		[view addSubview:subview];
	else
		[subview removeFromSuperview];
	[UIView commitAnimations];
}


static void QSAddSubviewWithSlideAnimation(UIView* view, UIView* subview, BOOL slide_in) {
	CGRect original_frame = subview.frame;
	CGRect final_frame = QSFinalSlideOrigin(view.bounds.size, original_frame);
	
	if (slide_in) {
		subview.frame = final_frame;
		[view addSubview:subview];
	}
	
	[UIView beginAnimations:@"QSSlideAnimation" context:NULL];
	[UIView setAnimationCurve:(slide_in ? UIViewAnimationCurveEaseIn : UIViewAnimationCurveEaseOut)];
	subview.frame = slide_in ? original_frame : final_frame;
	if (!slide_in) {
		[UIView setAnimationDelegate:subview];
		[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	}
	[UIView commitAnimations];	
}

static void QSAddSubviewWithFadeAnimation(UIView* view, UIView* subview, BOOL fade_in) {
	if (fade_in) {
		subview.alpha = 0;
		[view addSubview:subview];
	}
	
	[UIView beginAnimations:@"QSFadeAnimation" context:NULL];
	subview.alpha = fade_in ? 1 : 0;
	if (!fade_in) {
		[UIView setAnimationDelegate:subview];
		[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	}
	[UIView commitAnimations];		
}

static void QSToggleSubviewWithTransition(UIView* view, UIView* subview, QSTransition transition, BOOL add) {
	if (transition == QSTransition_Flip || transition == QSTransition_PageCurl) {
		QSAddSubviewWithComplexTransition(view, subview, transition, add);
	} else if (transition == QSTransition_Slide) {
		QSAddSubviewWithSlideAnimation(view, subview, add);
	} else if (transition == QSTransition_Fade) {
		QSAddSubviewWithFadeAnimation(view, subview, add);
	} else {
		if (add)
			[view addSubview:subview];
		else
			[subview removeFromSuperview];
	}
}

void QSAddSubviewWithTransition(UIView* view, UIView* subview, QSTransition transition) {
	QSToggleSubviewWithTransition(view, subview, transition, YES);
}

void QSRemoveSubviewWithTransition(UIView* view, UIView* subview, QSTransition transition) {
	QSToggleSubviewWithTransition(view, subview, transition, NO);
}

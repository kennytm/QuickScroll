/*

QSGraphics.m ... Rendering layer into an image.
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

#include <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

/// Rescale a CGSize to another CGSize, and chop up into multiple columns if needed,
/// such that the resulting packing is closest to the target size.
static void QSRescaleSizeToFit(CGSize src, CGSize target, CGFloat* scale, CGRect* rect, BOOL multicolumn, CGSize* page_size, int* col_count, int* row_count) {
	if (multicolumn) {
		
		if (page_size == NULL) {
		
			// perform multi-column rescaling. We need to chop up the src rect such
			// that the aspect ratio of the two are closest.
			//
			// If we chop up into N columns, then the height will be reduced by N,
			// and the width will be increased by N, so the total ratio will be increased
			// by a factor N^2. 
			//
			// Therefore, we should solve the equation
			//
			//      srcAspect * N^2 == targetAspect
			//
			// for N. Similar for N rows.
			
			CGFloat srcAspect = src.width / src.height;
			CGFloat targetAspect = target.width / target.height;
			
			if (srcAspect <= targetAspect) {
				*row_count = 1;
				CGFloat N = floorf(sqrtf(targetAspect / srcAspect));
				if (N > 1) {
					src.width *= N;
					src.height /= N;
				}
				*col_count = (int)N;
			} else {
				*col_count = 1;
				CGFloat N = floorf(sqrtf(srcAspect / targetAspect));
				if (N > 1) {
					src.height *= N;
					src.width /= N;
				}
				*row_count = (int)N;
			}
			
		} else {
			int w_pages = (int)ceilf(src.width / page_size->width);
			int h_pages = (int)ceilf(src.height / page_size->height);
			int total_pages = w_pages * h_pages;
			
		}
	}
	
	CGFloat widthScale = target.width / src.width;
	CGFloat heightScale = target.height / src.height;
	CGFloat finalScale = 1;
	if (finalScale > widthScale)
		finalScale = widthScale;
	if (finalScale > heightScale)
		finalScale = heightScale;
	*scale = finalScale;
	
	if (finalScale != 1) {			
		CGSize finalSize = CGSizeMake(src.width * finalScale, src.height * finalScale);
		CGPoint finalOrigin = CGPointMake((target.width - finalSize.width)/2, (target.height - finalSize.height)/2);
		rect->origin = finalOrigin;
		rect->size = finalSize;
	} else {
		// Use roundf to avoid accidental anti-aliasing when rescale is not needed.
		CGPoint finalOrigin = CGPointMake(roundf((target.width - src.width)/2), roundf((target.height - src.height)/2));
		rect->origin = finalOrigin;
		rect->size = src;
	}
}

/// Create a context with no alpha channel.
static CGContextRef QSCreateOpaqueContext(CGSize sz) {
	size_t final_width = ceilf(sz.width);
	size_t final_height = ceilf(sz.height);
	CGColorSpaceRef rgb_space = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, final_width, final_height, 8, final_width * 4, rgb_space, kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipLast);
	CGColorSpaceRelease(rgb_space);
//	CGContextTranslateCTM(ctx, 0, sz.height);
//	CGContextScaleCTM(ctx, 1, -1);
	return ctx;
}

/// Reshape an image into multicolumn.
/// (The input image will be -released, and the returned image will be -retained.)
static CGImageRef QSReshapeImage(CGImageRef img, CGSize aspect_retained_size, CGSize final_size, int col_count, int row_count) {
	if (col_count == 1 && row_count == 1) {
		return img;
	} else {
		CGContextRef ctx = QSCreateOpaqueContext(final_size);
		CGRect rect = CGRectMake(0, 0, CGImageGetWidth(img), CGImageGetHeight(img));
		if (col_count > 1) {
			for (int i = 0; i < col_count; ++ i) {
				rect.origin.x = i * aspect_retained_size.width;
				rect.origin.y = (1 - col_count + i) * final_size.height;
				CGContextDrawImage(ctx, rect, img);
			}
		} else {
			for (int i = 0; i < row_count; ++ i) {
				rect.origin.x = (1 - col_count + i) * final_size.width;
				rect.origin.y = i * aspect_retained_size.height;
				CGContextDrawImage(ctx, rect, img);
			}
		}
		CGImageRelease(img);
		img = CGBitmapContextCreateImage(ctx);
		CGContextRelease(ctx);
		
		return img;
	}
}

/// Render a layer in a CGContext.
static void QSRenderLayerInContext(CALayer* layer, CGContextRef ctx) {
	[layer drawInContext:ctx];
	for (CALayer* sublayer in layer.sublayers) {
		CGContextSaveGState(ctx);
		CGRect fr = sublayer.frame;
		CGContextTranslateCTM(ctx, fr.origin.x, fr.origin.y);
		QSRenderLayerInContext(sublayer, ctx);
		CGContextRestoreGState(ctx);
	}
}

/// Render a layer into an UIImage.
UIImage* QSRenderLayer(CALayer* layer, CGSize target_size, BOOL multicolumn, CGRect* p_final_rect) {
	// step 1: rescale.
	CGSize src_size = layer.bounds.size;
	CGFloat scale;
	CGRect final_rect;
	int col_count = 1, row_count = 1;
	QSRescaleSizeToFit(src_size, target_size, &scale, &final_rect, multicolumn, NULL, &col_count, &row_count);
	
	// step 2: render.
	CGSize rescaled_size = CGSizeMake(src_size.width * scale, src_size.height * scale);
	CGContextRef ctx = QSCreateOpaqueContext(rescaled_size);
	CGContextTranslateCTM(ctx, 0, rescaled_size.height);
	CGContextScaleCTM(ctx, scale, -scale);
	QSRenderLayerInContext(layer, ctx);
	CGImageRef img = CGBitmapContextCreateImage(ctx);
	CGContextRelease(ctx);
	
	// step 3: reshape.
	img = QSReshapeImage(img, rescaled_size, final_rect.size, col_count, row_count);
	
	if (p_final_rect != NULL)
		*p_final_rect = final_rect;
	
	UIImage* retval = [UIImage imageWithCGImage:img];
	CGImageRelease(img);
	
	return retval;
}

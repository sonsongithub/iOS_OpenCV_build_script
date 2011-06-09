/*
 * OpenCVTest
 * FaceDetectTestViewController.m
 *
 * Copyright (c) Yuichi YOSHIDA, 11/05/07
 * All rights reserved.
 * 
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are 
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior 
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "FaceDetectTestViewController.h"

#import <opencv/cv.h>

#import "OpenCVHelpLibrary.h"

@interface FaceDetectTestViewController(private)

- (void)changed:(id)sender;
- (void)removeAllFaceAnnotation;
- (void)detectFaceWithImageName:(NSString*)name;

@end

@implementation FaceDetectTestViewController

#pragma mark - IBAction

- (void)changed:(id)sender {
	imageCounter++;
	if (imageCounter == [imageFileNames count]) {
		imageCounter = 0;
	}
	NSString *name = [imageFileNames objectAtIndex:imageCounter];
	[self detectFaceWithImageName:name];
}

#pragma mark - Instance method

- (void)removeAllFaceAnnotation {
	for (UIView *v in views)
		[v removeFromSuperview];
	[views removeAllObjects];
}

- (void)detectFaceWithImageName:(NSString*)name {
	[self removeAllFaceAnnotation];
	
	// make half image with gaussian blur
	float scale = 2;
	UIImage *source = [UIImage imageNamed:name];
	IplImage *image = CGCreateIplImageWithCGImage(source.CGImage, CV_LOAD_IMAGE_GRAYSCALE);
	
	// Scaling down
	IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 1);
	cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
	
	// Load XML
	NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	CvHaarClassifierCascade* cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
	CvMemStorage* storage = cvCreateMemStorage(0);
	
	// Detect faces and draw rectangle on them
	CvSeq* faces = cvHaarDetectObjects(small_image, cascade, storage, 1.2f, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0,0), cvSize(20, 20));
	cvReleaseImage(&small_image);
	
	// draw result of detection
	for(int i = 0; i < faces->total; i++) {
		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
		
		// Calc the rect of faces
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
		
		UIView *v = [[UIView alloc] initWithFrame:CGRectMake(cvrect.x*scale, cvrect.y*scale, cvrect.width*scale, cvrect.height*scale)];
		[self.view addSubview:v];
		[views addObject:v];
		[v release];
		[v setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5]];		
		[pool release];
	}
	[imageView setImage:source];
	cvReleaseMemStorage(&storage);
	cvReleaseHaarClassifierCascade(&cascade);
}

#pragma mark - Override

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		views = [[NSMutableArray array] retain];
		imageFileNames = [[NSMutableArray array] retain];
		
		[imageFileNames addObject:@"Steve.jpg"];
		[imageFileNames addObject:@"lenna.jpg"];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self setTitle:NSLocalizedString(@"Face detection", nil)];
	
	[self.navigationController setToolbarHidden:NO animated:YES];
	
	[self changed:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	
	UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: NSLocalizedString(@"Prev", nil), NSLocalizedString(@"Next", nil), nil]];
	[segment setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segment setMomentary:YES];
	[segment autorelease];
	UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:segment];
	[segment addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
	
	[self.navigationController.toolbar setItems:[NSArray arrayWithObject:item]];
}

#pragma mark - dealloc

- (void)dealloc {
	[views release];
	[imageFileNames release];
    [super dealloc];
}

@end

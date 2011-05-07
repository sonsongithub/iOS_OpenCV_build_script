//
//  FaceDetectTestViewController.m
//  OpenCVTest
//
//  Created by sonson on 11/05/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FaceDetectTestViewController.h"

#import <opencv/cv.h>

@implementation FaceDetectTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
	CGImageRef imageRef = image.CGImage;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	IplImage *iplimage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
	CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
	CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

- (void)test {
	UIImage *source = [UIImage imageNamed:@"lena.jpg"];
	IplImage *image = [self CreateIplImageFromUIImage:source];
	
	// Scaling down
	IplImage *small_image = cvCreateImage(cvSize(image->width/2,image->height/2), IPL_DEPTH_8U, 3);
	cvPyrDown(image, small_image, CV_GAUSSIAN_5x5);
	int scale = 2;
	
	// Load XML
	NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
	CvHaarClassifierCascade* cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
	CvMemStorage* storage = cvCreateMemStorage(0);
	
	// Detect faces and draw rectangle on them
	CvSeq* faces = cvHaarDetectObjects(small_image, cascade, storage, 1.2f, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(0,0), cvSize(20, 20));
//	CvSeq* faces = cvHaarDetectObjects(small_image, cascade, storage, 1.2f, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(20, 20));
	cvReleaseImage(&small_image);
	
	NSLog(@"%d", faces->total);
	
//	// Create canvas to show the results
//	CGImageRef imageRef = source.CGImage;
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//	CGContextRef contextRef = CGBitmapContextCreate(NULL, imageView.image.size.width, imageView.image.size.height,
//													8, imageView.image.size.width * 4,
//													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
//	CGContextDrawImage(contextRef, CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height), imageRef);
//	
//	CGContextSetLineWidth(contextRef, 4);
//	CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 1.0, 0.5);
//	
//	// Draw results on the iamge
//	for(int i = 0; i < faces->total; i++) {
//		NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
//		
//		// Calc the rect of faces
//		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
//		CGRect face_rect = CGContextConvertRectToDeviceSpace(contextRef, CGRectMake(cvrect.x * scale, cvrect.y * scale, cvrect.width * scale, cvrect.height * scale));
//		
//		if(overlayImage) {
//			CGContextDrawImage(contextRef, face_rect, overlayImage.CGImage);
//		} else {
//			CGContextStrokeRect(contextRef, face_rect);
//		}
//		
//		[pool release];
//	}
//	
//	imageView.image = [UIImage imageWithCGImage:CGBitmapContextCreateImage(contextRef)];
//	CGContextRelease(contextRef);
//	CGColorSpaceRelease(colorSpace);
	
	cvReleaseMemStorage(&storage);
	cvReleaseHaarClassifierCascade(&cascade);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self test];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

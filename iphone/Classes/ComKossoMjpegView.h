/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * @kosso
 */
#import "TiUIView.h"
#import "TiDimension.h"

@interface ComKossoMjpegView : TiUIView {
    TiUIView *containerview;
    UIImageView *mjpegview;

    NSMutableURLRequest *_request;
    
    NSURL *_url;
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
    
    TiDimension width;
    TiDimension height;
    
}

@property (nonatomic, readwrite, copy) NSURL *url;

- (void)setImage_:(id)arg; //

- (void)play;
- (void)pause;
- (void)clear;
- (void)stop:(id)args;

- (void)cleanupConnection;

@end

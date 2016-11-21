/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2016 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 * @kosso
 */

#import "ComKossoMjpegView.h"
#import "TiUtils.h"
#import "TiBlob.h"
#import "TiFile.h"

#define END_MARKER_BYTES { 0xFF, 0xD9 }
static NSData *_endMarkerData = nil;

@implementation ComKossoMjpegView


- (void)initializeState
{
    containerview = [[TiUIView alloc] initWithFrame:[self frame]];
    [self addSubview:containerview];
    mjpegview = [[UIImageView alloc] initWithFrame:[self frame]];
    [mjpegview setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [mjpegview setContentMode:[self contentModeForImageView]];
    [self addSubview:mjpegview];
    
    _receivedData = [NSMutableData data];
    
    [super initializeState];
}

-(UIViewContentMode)contentModeForImageView
{
    if (TiDimensionIsAuto(width) || TiDimensionIsAutoSize(width) || TiDimensionIsUndefined(width) ||
        TiDimensionIsAuto(height) || TiDimensionIsAutoSize(height) || TiDimensionIsUndefined(height)) {
        return UIViewContentModeScaleAspectFit;
    }
    else {
        return UIViewContentModeScaleToFill;
    }
}

-(void)dealloc
{
    if (_connection) {
        [_connection cancel];
    }
    if (_url) {
        [_url release];
    }
    
    RELEASE_TO_NIL(_receivedData);
    RELEASE_TO_NIL(containerview);
    RELEASE_TO_NIL(mjpegview);
    
    [super dealloc];
}
-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    // Sets the size and position of the view
    [TiUtils setView:containerview positionRect:bounds];
    [TiUtils setView:mjpegview positionRect:bounds];
}
-(void)setColor_:(id)color
{
    // Assigns the view's background color
    containerview.backgroundColor = [[TiUtils colorValue:color] _color];
}

-(void)setImage_:(id)arg
{
    // NSLog(@"[INFO] setImage");
    // hmm... not too sure what's going on here..
    if ([arg isKindOfClass:[TiBlob class]]) {
        TiBlob *blob = (TiBlob*)arg;
        NSLog(@"[INFO] set image from TiBlob");
        dispatch_async(dispatch_get_main_queue(), ^{
            mjpegview.image = [blob image];
        });
        
    }
    else if ([arg isKindOfClass:[TiFile class]]) {
        TiFile *file = (TiFile*)arg;
        //NSLog(@"[INFO] set image from TiFile");
        NSURL * fileUrl = [NSURL fileURLWithPath:[file path]];
        NSData *imageData = [NSData dataWithContentsOfURL:fileUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            mjpegview.image = [UIImage imageWithData:imageData];
        });
        
    }
    else if ([arg isKindOfClass:[NSString class]]) {
        // remote url
        // NSLog(@"[INFO] image provided was a string  %@", arg);
        NSURL * fileUrl = [NSURL fileURLWithPath:arg];
        NSData *imageData = [NSData dataWithContentsOfURL:fileUrl];
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    mjpegview.image = [UIImage imageWithData:imageData];
        //});
        
         [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:arg]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
             //NSLog(@"[INFO] got the image");
             dispatch_async(dispatch_get_main_queue(), ^{
                mjpegview.image = [UIImage imageWithData:data];
             });
         
         }];
        
    }
    else if ([arg isKindOfClass:[UIImage class]]) {
        // called within this class
        dispatch_async(dispatch_get_main_queue(), ^{
            mjpegview.image = (UIImage*)arg;
        });
    }
    else if ([arg isKindOfClass:[NSData class]]) {
        // called within this class
        dispatch_async(dispatch_get_main_queue(), ^{
            mjpegview.image = [UIImage imageWithData:arg];
        });
    }
    
}

#pragma mark - Public Methods

-(void)requestMJPEG:(id)args
{
    // Just provide a url
    if([args count] == 1){
        NSString *mjpegurl = [TiUtils stringValue:[args objectAtIndex:0]];
        NSLog(@"[INFO] requestMJPEG: %@", mjpegurl);
        _url = [NSURL URLWithString:mjpegurl];
        
    } else if([args count] == 5){
        // Or the url parts..
        NSString *protocol = [TiUtils stringValue:[args objectAtIndex:0]];
        NSString *host = [TiUtils stringValue:[args objectAtIndex:1]];
        NSInteger *port = [TiUtils intValue:[args objectAtIndex:2]];
        NSString *method = [TiUtils stringValue:[args objectAtIndex:3]];
        NSString *path = [TiUtils stringValue:[args objectAtIndex:4]];
        
        NSLog(@"[INFO] requestMJPEG: %@ : %@://%@:%d%@", method, protocol, host, port, path);
        NSString *urlstring = [NSString stringWithFormat:@"%@://%@:%ld%@", protocol, host, (long)port, path];
        _url = [NSURL URLWithString:urlstring];
        
    }
    
    _receivedData = [[NSMutableData alloc] init];
    
    if (_endMarkerData == nil) {
        uint8_t endMarker[2] = END_MARKER_BYTES;
        _endMarkerData = [[NSData alloc] initWithBytes:endMarker length:2];
    }
    
    [self play];
    
}


- (void)play  {
    if (_connection) {
        NSLog(@"[INFO] interrupting stream.. ");
        [self stop:nil];
        
    }
    if (_url) {
        NSLog(@"[INFO] play: %@", _url);
        _connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:_url] delegate:self];
    }
}

- (void)pause  {
    if (_connection) {
        [_connection cancel];
        [self cleanupConnection];
    }
}

- (void)clear {
    mjpegview.image = nil;
}

- (void)stop:(id)args {
    [self pause];
    [self clear];
}


#pragma mark - Private Methods

- (void)cleanupConnection {
    if (_connection) {
        [_connection release];
        _connection = nil;
    }
    
    if (_receivedData) {
        [_receivedData release];
        _receivedData = nil;
    }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (_receivedData) {
        [_receivedData release];
    }
    
    _receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
    
    // This is where we monitor the incoming data buffer and look for the JPEG markers...
    NSRange endRange = [_receivedData rangeOfData:_endMarkerData
                                          options:0
                                            range:NSMakeRange(0, _receivedData.length)];
    
    long long endLocation = endRange.location + endRange.length;
    if (_receivedData.length >= endLocation) {
        NSData *imageData = [_receivedData subdataWithRange:NSMakeRange(0, endLocation)];
        UIImage *receivedImage = [UIImage imageWithData:imageData];
        if (receivedImage) {
            // NSLog(@"[INFO] Found a JPEG frame!");
            mjpegview.image = receivedImage;
            [_receivedData release];
            _receivedData = nil;
            _receivedData = [[NSMutableData alloc] init];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self cleanupConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self cleanupConnection];
}


@end
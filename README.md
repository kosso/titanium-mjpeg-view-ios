# titanium-mjpeg-view-ios
A Titanium iOS module for showing an MJPEG stream in a view. Not using WebViews or WebKit.



See `example/app.js` for a working example app. 

----------------

Unlike some solutions for getting MJPEG video streams into a view which often use a UIWebView (or even better, WKWebView), this actually parses the data stream coming from a device for incoming MJPEG frames.



This works perfectly connecting to a Raspberry Pi running **mjpeg-streamer**. See : https://github.com/kosso/mjpg-streamer



Ideas / ToDo: 

- Try filtering the frame with a `CIKernel`
- … 


-----------

@kosso : November 21, 2016
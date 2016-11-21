
// com.kosso.mjpeg : example app. 
// @kosso : November 2016

var mjpegmodule = require('com.kosso.mjpeg');

console.log('module loaded:', mjpegmodule);

////////////////////////////////////////////////////
// Connection settings.  Works very well with mjpeg-streamer on a Raspberry Pi
// see  : https://github.com/jacksonliam/mjpg-streamer

// Simpler method
var mjpeg_url = 'http://extcam-8.se.axis.com/mjpg/video.mjpg?timestamp=1479768373043'; // A demo stream from Axis

// var mjpeg_url = 'http://192.168.0.31:8080/?action=stream';  // My Raspberry Pi

// or use parts.. 
// var protocol = 'http';
// var host = '192.168.0.31';
// var port = 8080;
// var mjpeg_path = '/?action=stream';
// var method = 'GET';


////////////////////////////////////////////////////

var connected = false;

// open a single window
var win = Ti.UI.createWindow({
  backgroundColor:'#222'
});

// throw things in a scrollview
var sv = Ti.UI.createScrollView({
  top:0,
  left:0,
  right:0,
  zIndex:1,
  backgroundColor:'transparent',
  bottom:0,
  layout:'vertical',
  contentHeight:Ti.UI.SIZE,
  scrollType:'vertical'
});

var mjpegView = mjpegmodule.createView({
  top:40,
  left:0,
  right:0,
  color:'#667888b0',
  backgroundImage:'loading_bg_sq.png',
  height:Math.round(Ti.Platform.displayCaps.platformWidth * 0.75) // 4:3 aspect ratio
});

sv.add(mjpegView);

var textField = Ti.UI.createTextField({
  borderStyle: Ti.UI.INPUT_BORDERSTYLE_LINE,
  color: '#222',
  backgroundColor:'#eee',
  top: 10, 
  textAlign:'center',
  font:{fontSize:14},
  left:10,
  right:10,
  height: 40
});

textField.value = mjpeg_url;

textField.addEventListener('change', function(e){
  console.log('change: ', e);
  if(e.value!=''){
    mjpeg_url = e.value;
  }

});

sv.add(textField);


var btn_cam_remote_preview = Ti.UI.createButton({
  title:'   START MJPEG STREAM   ',
  borderColor:'#ccc',
  borderRadius:20,
  height:40,
  tintColor:'white',
  top:10,
  left:10,
  right:10
});
sv.add(btn_cam_remote_preview);

btn_cam_remote_preview.addEventListener('click', function(){
  if(!connected){
    console.log('connecting to MJPEG stream ...');

    // url only
    mjpegView.requestMJPEG(mjpeg_url);

    // mjpegView.requestMJPEG(protocol, host, port, method, mjpeg_path); // needs auth too eventually.

    btn_cam_remote_preview.title = 'STOP';

  } else {
    console.log('disconnect camera ');
    mjpegView.stop();
    btn_cam_remote_preview.title = '   START MJPEG STREAM   ';
  }
  connected = !connected;
});

win.add(sv);

win.open();
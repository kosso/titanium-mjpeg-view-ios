
// com.kosso.mjpeg : example app. 
// @kosso : November 21, 2016

var mjpegmodule = require('com.kosso.mjpeg');

console.log('module loaded:', mjpegmodule);

////////////////////////////////////////////////////
// Connection settings.  Works very well with mjpeg-streamer on a Raspberry Pi

// see  : https://github.com/jacksonliam/mjpg-streamer
var protocol = 'http';
var host = '192.168.0.31';
var port = 8080;
var mjpeg_path = '/?action=stream';
var method = 'GET';
////////////////////////////////////////////////////

var connected = false;

// open a single window
var win = Ti.UI.createWindow({
  backgroundColor:'white'
});

// throw things in a scrollview
var sv = Ti.UI.createScrollView({
  top:0,
  left:0,
  right:0,
  zIndex:1,
  backgroundColor:'#fff',
  bottom:0,
  layout:'vertical',
  contentHeight:Ti.UI.SIZE,
  scrollType:'vertical'
});

var mjpegView = mjpegmodule.createView({
  top:40,
  left:0,
  right:0,
  color:'#aa003388',
  backgroundImage:'loading_bg_sq.png',
  height:Math.round(Ti.Platform.displayCaps.platformWidth * 0.75) // 4:3 aspect ratio
});

sv.add(mjpegView);

var btn_cam_remote_preview = Ti.UI.createButton({
  title:'   START MJPEG STREAM   ',
  borderColor:'#ccc',
  height:40,
  top:10,
  width:Ti.UI.SIZE
});
sv.add(btn_cam_remote_preview);

btn_cam_remote_preview.addEventListener('click', function(){
  if(!connected){
    console.log('connecting to MJPEG stream ...');

    mjpegView.requestMJPEG(protocol, host, port, method, mjpeg_path); // needs auth too eventually.

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
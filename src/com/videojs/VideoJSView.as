package com.videojs{

    import com.videojs.events.VideoJSEvent;
    import com.videojs.events.VideoPlaybackEvent;
    import com.videojs.structs.ExternalErrorEventName;

    import flash.display.Bitmap;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.media.Video;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;

    public class VideoJSView extends Sprite{

        private var _uiVideo:Video;
        private var _uiBackground:Sprite;

        private var _model:VideoJSModel;

        public function VideoJSView(){

            _model = VideoJSModel.getInstance();
            _model.addEventListener(VideoJSEvent.BACKGROUND_COLOR_SET, onBackgroundColorSet);
            _model.addEventListener(VideoJSEvent.STAGE_RESIZE, onStageResize);
            _model.addEventListener(VideoPlaybackEvent.ON_META_DATA, onMetaData);
            _model.addEventListener(VideoPlaybackEvent.ON_VIDEO_DIMENSION_UPDATE, onDimensionUpdate);

            _uiBackground = new Sprite();
            _uiBackground.graphics.beginFill(_model.backgroundColor, 1);
            _uiBackground.graphics.drawRect(0, 0, _model.stageRect.width, _model.stageRect.height);
            _uiBackground.graphics.endFill();
            _uiBackground.alpha = _model.backgroundAlpha;
            addChild(_uiBackground);

            _uiVideo = new Video();
            _uiVideo.width = _model.stageRect.width;
            _uiVideo.height = _model.stageRect.height;
            _uiVideo.smoothing = true;
            addChild(_uiVideo);

            _model.videoReference = _uiVideo;
            _model.broadcastEventExternally('onmetadata', {w: _model.stageRect.width, h: _model.stageRect.height});

        }


        private function sizeVideoObject(metadata:Object = null):void{

            var __targetWidth:int, __targetHeight:int;

            var __availableWidth:int = _model.stageRect.width;
            var __availableHeight:int = _model.stageRect.height;

            var __nativeWidth:int = 320;

            if(_model.metadata.width != undefined){
                __nativeWidth = Number(_model.metadata.width);
            }

            if(_uiVideo.videoWidth != 0){
                __nativeWidth = _uiVideo.videoWidth;
            }

            var __nativeHeight:int = 240;

            if(_model.metadata.width != undefined){
                __nativeHeight = Number(_model.metadata.height);
            }

            if(_uiVideo.videoWidth != 0){
                __nativeHeight = _uiVideo.videoHeight;
            }

            // first, size the whole thing down based on the available width
            __targetWidth = __availableWidth;
            __targetHeight = __targetWidth * (__nativeHeight / __nativeWidth);

            if(__targetHeight > __availableHeight){
                __targetWidth = __targetWidth * (__availableHeight / __targetHeight);
                __targetHeight = __availableHeight;
            }

            _uiVideo.width = __targetWidth;
            _uiVideo.height = __targetHeight;

            _uiVideo.x = Math.round((_model.stageRect.width - _uiVideo.width) / 2);
            _uiVideo.y = Math.round((_model.stageRect.height - _uiVideo.height) / 2);

        }

        private function transformVideoObject(obj:Object):void {
          var rotation:int = 0;
          var w:int = _uiVideo.width;
          var h:int = _uiVideo.height;
          for (var t:String in obj) {
            if (t == "orientation") {
              rotation = parseInt(obj[t]);
            }
            if (t=="resolution") {
              var dimens:Array = obj[t].split(",");
              w = parseInt(dimens[0]);
              h = parseInt(dimens[1]);
            }
          }
          //reset transform matrix and position in center screen
          var m: Matrix = new Matrix();
          _uiVideo.transform.matrix = m;
          _uiVideo.width = w;
          _uiVideo.height = h;
          rotateAroundCenter(_uiVideo, rotation);
          scaleVideo(_uiVideo);
          center(_uiVideo);
        }

        private function center(ob:DisplayObject):void {
          var rect:Rectangle = ob.getBounds(ob.parent);
          var stageCenter:Point = new Point(this.stage.stageWidth*0.5, this.stage.stageHeight*0.5);
          var rectCenter:Point = new Point(rect.left+rect.width*0.5, rect.top+rect.height*0.5);
          var m:Matrix=ob.transform.matrix;
          m.translate(stageCenter.x-rectCenter.x, stageCenter.y-rectCenter.y);
          ob.transform.matrix = m;
        }

        private function scaleVideo(ob:DisplayObject):void {
          var rect:Rectangle = ob.getBounds(ob.parent);
          var s:Number = Math.min(this.stage.stageWidth/rect.width, this.stage.stageHeight/rect.height);
          var m:Matrix=ob.transform.matrix;
          m.scale(s, s);
          ob.transform.matrix = m;
        }

        private function rotateAroundCenter (ob:DisplayObject, angleDegrees:Number):void {
          var rect:Rectangle = ob.getBounds(ob.parent);
          var m:Matrix = ob.transform.matrix;
          m.translate(-(rect.left + (rect.width / 2)), -(rect.top + (rect.height / 2)));
          m.rotate (angleDegrees*(Math.PI/180));
          m.translate(rect.left + (rect.width / 2), rect.top + (rect.height / 2));
          ob.transform.matrix=m;
          ob.rotation = Math.round(ob.rotation);
        }

        private function onBackgroundColorSet(e:VideoPlaybackEvent):void{
            _uiBackground.graphics.clear();
            _uiBackground.graphics.beginFill(_model.backgroundColor, 1);
            _uiBackground.graphics.drawRect(0, 0, _model.stageRect.width, _model.stageRect.height);
            _uiBackground.graphics.endFill();
        }

        private function onStageResize(e:VideoJSEvent):void{
            _uiBackground.graphics.clear();
            _uiBackground.graphics.beginFill(_model.backgroundColor, 1);
            _uiBackground.graphics.drawRect(0, 0, _model.stageRect.width, _model.stageRect.height);
            _uiBackground.graphics.endFill();
            // sizeVideoObject();
            transformVideoObject(_model.metadata);

        }

        private function onMetaData(e:VideoPlaybackEvent):void{
            // sizeVideoObject();
            transformVideoObject(_model.metadata);
        }

        private function onDimensionUpdate(e:VideoPlaybackEvent):void{
            sizeVideoObject();
            // transformVideoObject(_model.metadata);
        }

    }
}

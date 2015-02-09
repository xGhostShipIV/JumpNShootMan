package 
{
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.*;
	
	public class ExternalLoader extends MovieClip
	{
		var progress_txt:TextField = new TextField();
		var pbar:MovieClip = new bar();
		
		var myLoader:Loader = new Loader();
		
		var percent_loaded:Number;

		function ExternalLoader():void
		{
			//OPEN fires when loading process starts
			myLoader.contentLoaderInfo.addEventListener(Event.OPEN, onOpen);
			//PROGRESS carries info about number of bytes loaded;
			myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			//COMPLETE fires when process finishes;
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			//start loading of mainMovie.swf;
			myLoader.load(new URLRequest("JumpnShootMan.swf"));
		}

		//loading started so add the text field on the stage
		function onOpen(e:Event):void
		{
			pbar.x = stage.stageWidth / 2;
			pbar.y = stage.stageHeight / 2;
			progress_txt.x = stage.stageWidth / 2 - 10;
			progress_txt.y = stage.stageHeight / 2 - 10;
			addChild(pbar);
			addChild(progress_txt);
		}

		//update progress
		function onProgress(e:ProgressEvent):void
		{
			percent_loaded = (e.bytesLoaded/e.bytesTotal);
			pbar.value = percent_loaded;
			
			pbar.scaleX = percent_loaded;
			progress_txt.text = String(Math.floor((e.bytesLoaded/e.bytesTotal)*100)) + "%";
		}

		//end of loading so clean up and add loaded clip on the stage
		function onComplete(e:Event):void
		{
			trace("Loading process complete");
			//remove unnecessary listeners
			myLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			myLoader.contentLoaderInfo.removeEventListener(Event.OPEN, onOpen);
			myLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);

			progress_txt.text = "Loading Complete";
			progress_txt.x -= 30;
			setTimeout(playGame, 1000);
			
		}
		
		function playGame():void
		{
			removeChild(pbar);
			removeChild(progress_txt);
			addChild(myLoader.content);
		}
	}
}
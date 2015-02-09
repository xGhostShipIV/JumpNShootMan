package  {
	
	import flash.display.MovieClip;
	
	
	public class Hammers extends MovieClip {
		
		public var speed:Number;
		public var power:Number;
		
		public function Hammers(PosX:Number, PosY:Number, Speed:Number) {
			// constructor code
			x = PosX;
			y = PosY;
			speed = Speed * 2;
			power = 1;
		}
	}
	
}

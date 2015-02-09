package  {
	
	import flash.display.MovieClip;
	
	
	public class Lemon extends MovieClip {
		
		public var speed:Number;
		public var power:Number;
		
		public function Lemon(PositionX:Number, PositionY:Number, Speed:Number, Power:Number) {
			// constructor code
			x = PositionX;
			y = PositionY;
			speed = Speed * 2;
			power = Power;

		}
	}
	
}

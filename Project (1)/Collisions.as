package 
{

	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	public class Collisions
	{

		public function Collisions()
		{
			//trace(root);
			// constructor code
		}

		public static function Collision(obj1:DisplayObject, obj2:DisplayObject):Boolean
		{
			var mainInstance:MovieClip = Main.main;

			if (obj1.getBounds(mainInstance.stage).intersects(obj2.getBounds(mainInstance.stage)))
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		public static function CollideTop(obj1:DisplayObject, obj2:DisplayObject):Boolean
		{
			if (Collision(obj1, obj2) && (obj1.y + obj1.height / 2) <= obj2.y &&
			   (obj1.x + (obj1.width * 1.5)) >= obj2.x && obj1.x < (obj2.x + obj2.width))
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		public static function CollideSide(obj1:DisplayObject, obj2:DisplayObject):Boolean
		{
			if (Collision(obj1, obj2) && (obj1.y - obj1.height) >= obj2.y &&
			   ((obj1.x + obj1.width) < obj2.x || obj1.x > (obj2.x + obj2.width)))
			{
				return true;
			}
			else
			{
				return false;
			}

		}

	}
}
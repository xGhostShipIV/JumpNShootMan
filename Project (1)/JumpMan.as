package 
{
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	public class JumpMan extends MovieClip
	{

		var currentAnimation:String;
		var stepsTaken:int;
		var stepsToEncounter:int;
		var speedX:Number;
		var speedY:Number;
		
		public function JumpMan()
		{
			// constructor code
			speedX = 0;
			speedY = 0;
			stepsTaken = 0;
			stepsToEncounter = Math.floor(Math.random() * 40 + 10);
			//stepsToEncounter = 1;
		}

		public function resetEncounter()
		{
			stepsTaken = 0;
			stepsToEncounter = Math.floor(Math.random() * 40 + 10);			
		}
		
		public function MoveUp()
		{
			if (currentAnimation != "OverWorld_Up")
			{
				currentAnimation = "OverWorld_Up";
				gotoAndPlay(currentAnimation);
			}

			var touching:Boolean = false;
			var nextBounds:Rectangle = new Rectangle(x,
			 (y - 10), width, height);

			for (var i:int = 0; i < Main.trees.length; i++)
			{
				var treeRect:Rectangle = Main.trees[i].getBounds(stage);

				if (nextBounds.intersects(treeRect))
				{
					speedY = 0;
					touching = true;
				}
			}

			if (! touching && y - height / 2 > 0)
			{
				speedY = -10;
				speedX = 0;
				stepsTaken++;
			}
		}

		public function MoveDown()
		{
			if (currentAnimation != "OverWorld_Down")
			{
				currentAnimation = "OverWorld_Down";
				gotoAndPlay(currentAnimation);
			}

			var touching:Boolean = false;
			var nextBounds:Rectangle = new Rectangle(x,
			 (y - 10), width, height);

			for (var i:int = 0; i < Main.trees.length; i++)
			{
				var treeRect:Rectangle = Main.trees[i].getBounds(stage);

				if (nextBounds.intersects(treeRect))
				{
					speedY = 0;
					touching = true;
				}
			}

			if (! touching && y + height / 2 < stage.stageHeight)
			{
				speedY = 10;
				speedX = 0;
				stepsTaken++;
			}
		}

		public function MoveRight()
		{
			if (currentAnimation != "OverWorld_Right")
			{
				currentAnimation = "OverWorld_Right";
				gotoAndPlay(currentAnimation);
			}

			var touching:Boolean = false;
			var nextBounds:Rectangle = new Rectangle(x,
			 (y), width, height);

			for (var i:int = 0; i < Main.trees.length; i++)
			{
				var treeRect:Rectangle = Main.trees[i].getBounds(stage);

				if (nextBounds.intersects(treeRect))
				{
					speedX = 0;
					touching = true;
				}
			}

			scaleX = 1;

			if (! touching && x + width / 2 < stage.stageWidth)
			{
				speedY = 0;
				speedX = 10;
				stepsTaken++;
			}
		}

		public function MoveLeft()
		{
			if (currentAnimation != "OverWorld_Right")
			{
				currentAnimation = "OverWorld_Right";
				gotoAndPlay(currentAnimation);
			}

			var touching:Boolean = false;
			var nextBounds:Rectangle = new Rectangle(x - 10,
			 (y), width, height);

			for (var i:int = 0; i < Main.trees.length; i++)
			{
				var treeRect:Rectangle = Main.trees[i].getBounds(stage);

				if (nextBounds.intersects(treeRect))
				{
					speedX = 0;
					touching = true;
				}
			}

			scaleX = -1;

			if (! touching && x - width / 2 > 0)
			{
				speedX = -10;
				speedY = 0;
				stepsTaken++;
			}
		}
		
		public function Idle()
		{
			speedX = 0;
			speedY = 0;
		}
		
		public function jumpManUpdate()
		{
			var mainInstance:MovieClip = Main.main;
			
			var nextBounds:Rectangle = new Rectangle(x + speedX,
				 y + speedY, width, height);
			 
			var treeCollision:Boolean = false;

			for(var i:int = 0; i < Main.trees.length; i++)
			{
				var treeRect:Rectangle = Main.trees[i].getBounds(mainInstance.stage);
				
				if(nextBounds.intersects(treeRect))
				{
					treeCollision = true;
					break;
				}
			}
			
			if(!treeCollision)
			{
				x += speedX;
				y += speedY;
			}
			
			if(x + speedX < width / 2 ||
			   x + speedX > mainInstance.stage.stageWidth - speedX)
			   speedX = 0;
			if(y + speedY < height / 2 ||
			   y + speedY > mainInstance.stage.stageHeight - height / 2)
			   speedY = 0;
		}

	}

}
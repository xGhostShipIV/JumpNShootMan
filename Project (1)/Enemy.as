package 
{

	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;


	public class Enemy extends MovieClip
	{
		//Enemy base values
		public const E_BASE_SPEED = 5;
		public const E_BASE_JUMP = -10;
		public const E_BASE_HEALTH = 3;
		public const E_SHOOT_CD = 300;
		
		//Array of hammers universal to all enemies
		public static var hammers:Array;

		//An instance of main to access the stage
		public var mainInstance:MovieClip;

		//ShootMans position. Used in determining AI facing
		public var shootManPos:Number;

		//Values associated with enemies movement and combat
		public var currentHealth:Number;
		public var speedX:Number;
		public var speedY:Number;

		//Boolean flags to manage enemies
		public var isJumping:Boolean;
		public var isShooting:Boolean;
		public var isDying:Boolean;

		//Timers on which the enemy will operate
		public var actTimer:Timer;
		public var deathDirection:Number;
		
		//Enemy sounds
		public var e_hitSound:Sound;
		public var e_jumpSound:Sound;
		public var e_soundChannel:SoundChannel;
		
		//Text field used to show Exp gains
		public var expText:TextField;
		public var format:TextFormat;

		public function Enemy()
		{
			// constructor code
			mainInstance = Main.main;

			currentHealth = E_BASE_HEALTH;
			speedX = 0;
			speedY = 0;

			shootManPos = mainInstance.stage.stageWidth;

			hammers = new Array();
			actTimer = new Timer(1000);
			deathDirection = 1;
			
			expText = new TextField();
			format = new TextFormat();
			
			e_hitSound = new Sound();
			e_jumpSound = new Sound();
			e_soundChannel = new SoundChannel();
			
			e_hitSound.load(new URLRequest("Sounds/enemyHit.mp3"));
			e_jumpSound.load(new URLRequest("Sounds/enemyJump.mp3"));
			
			actTimer.addEventListener(TimerEvent.TIMER, chooseAction);
		}

		public function chooseAction(e:TimerEvent)
		{
			//Every time the event triggers a random action is called
			var chooser:int = Math.ceil(Math.random() * 3);

			if (chooser == 1)
			{
				Move();
			}
			else if (chooser == 2)
			{
				Jump();
			}
			else
			{
				Shoot();
			}
		}

		public function Move()
		{
			//The conditions here will make sure that when an enemy starts moving
			//They will always start heading in the direction of shootman
			//This method also ensures they stay on screen
			if (x > shootManPos)
			{
				if (x - E_BASE_SPEED > 0)
				{
					speedX =  -  E_BASE_SPEED;
				}
				else
				{
					speedX = 0;

				}
				scaleX = 1;
			}
			else
			{
				if (x + width + E_BASE_SPEED < mainInstance.stage.stageWidth)
				{
					speedX = E_BASE_SPEED;
				}
				else
				{
					speedX = 0;

				}
				scaleX = -1;
			}
		}

		public function Jump()
		{
			//Does not allow for double jumping
			if (! isJumping)
			{
				e_soundChannel = e_jumpSound.play();
				e_soundChannel.soundTransform = Main.sfxTransform;
				
				isJumping = true;
				speedY = E_BASE_JUMP;
			}
		}

		public function Shoot()
		{
			//These conditions ensure that enemies always fire in the direction of shootman
			if (x > shootManPos && scaleX == -1)
			{
				scaleX = 1;
			}
			else if (x < shootManPos && scaleX == 1)
			{
				scaleX = -1;
			}

			speedX = 0;

			var newHammer:MovieClip = new Hammers(x,y,(E_BASE_SPEED - 2) *  -  scaleX);
			hammers.push(newHammer);
			mainInstance.stage.addChild(newHammer);
		}
		
		public function Die()
		{
			//Removes the enemy from the stage
			//mainInstance.stage.removeChild(this);
			gotoAndStop("Enemy_Dying");
			
			for(var i:int = 0; i < hammers.length; i++)
			{
				//Removes any hammers from the stage
				mainInstance.stage.removeChild(hammers[i]);
			}
			
			//Empties out the hammers array
			hammers.splice(0, hammers.length);
			
			//Stops the timer and removes the listener
			actTimer.stop();
			actTimer.removeEventListener(TimerEvent.TIMER, chooseAction);
			
			//This will make sure when the enemy dies they move in a
			//direction appropriate to where they were shot from
			if(x > shootManPos)
				deathDirection = 1;
			else
				deathDirection = -1;
				
			//adds the EXP gain text
			expText.x = x - width / 2;
			expText.y = y;
			expText.text = "+10 EXP";
			
			format.color = 0xffd700;
			format.bold = true;
			expText.setTextFormat(format);
			
			mainInstance.stage.addChild(expText);
				
			mainInstance.stage.addEventListener(Event.ENTER_FRAME, deathAnimation);
		}
		
		public function deathAnimation(e:Event)
		{
			//Adjusts the enemys speed to look like he is falling
			//And causes him to fade out
			x += E_BASE_SPEED * deathDirection;
			y += 5;
			this.alpha -= 0.1;
			
			expText.y -= 2;
			
			//When the enemy is off the stage everything is removed
			if(y > mainInstance.stage.stageHeight)
			{
				mainInstance.stage.removeChild(expText);
				mainInstance.stage.removeChild(this);
				mainInstance.stage.removeEventListener(Event.ENTER_FRAME, deathAnimation);
			}
		}

		public function EnemyUpdate(ShootManPos:Number)
		{
			//Gets shootmans position everyframe in order to allow the AI to behave properly
			shootManPos = ShootManPos;

			//Updates any hammers thrown and removes them if they go off screen
			for (var i:int = 0; i < hammers.length; i++)
			{
				hammers[i].x +=  hammers[i].speed;

				if (hammers[i].x + hammers[i].width < 0 || 
				   hammers[i].x > mainInstance.stage.stageWidth)
				{
					mainInstance.stage.removeChild(hammers[i]);
					hammers.splice(i, 1);
				}
			}
			
			//only moves them if they wont go off screen
			if (x - width / 2 + speedX > 0 
			   && x + width / 2 + speedX < mainInstance.stage.stageWidth)
			{
				x +=  speedX;
			}

			var shouldFall:Boolean = checkCollisions();
			
			//Applies gravity and checks for collisions with ground and platforms
			if (isJumping)
			{
				y +=  speedY;
				speedY +=  0.5;
			}
			else if (shouldFall && y < mainInstance.PLATFORM_GROUND)
			{
				y +=  speedY;
				speedY +=  0.5;
			}
			else if (!shouldFall)
			{
				speedY = 0;
				isJumping = false;
			}

			if (y > mainInstance.PLATFORM_GROUND && shouldFall)
			{
				y = mainInstance.PLATFORM_GROUND - 7;
				isJumping = false;
				shouldFall = false;
			}

		}

		public function checkCollisions():Boolean
		{
			var willFall:Boolean;

			for (var i:int = 0; i < Main.platforms.length; i++)
			{
				if (Collisions.CollideTop(this,Main.platforms[i]) && speedY > 0)
				{
					y = (Main.platforms[i].y) - height / 2 - 7;
					isJumping = false;
					speedY = 0;
					willFall = false;

					break;
				}
				else
				{
					willFall = true;
					continue;
				}
			}

			return willFall;
		}
	}

}
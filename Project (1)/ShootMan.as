package 
{

	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	public class ShootMan extends MovieClip
	{
		//Used to smooth over the playing of animations
		public var currentAnimation:String;

		//Variables to track movement
		public var isJumping:Boolean;
		public var isShooting:Boolean;
		public var isHurting:Boolean;
		public var stopping:Boolean;
		public var speed:Number;
		public var speedY:Number;

		//Base RPG values
		public const BASE_HEALTH:Number = 5;
		public const BASE_SPEED:Number = 5;
		public const BASE_JUMP:Number = -10;
		public var currentHealth:Number;
		
		
		//RPG bonuses from leveling
		public var shotPower:Number;
		public var bonusRun:Number;
		public var bonusJump:Number;
		public var bonusHealth:Number;
		
		//Variables related to leveling
		public var level:Number;
		public var currentXP:Number;
		public var xpToLevel:Number;
		public var skillPoints:Number;

		//Variables associated with tracking shooting
		public const SHOOT_CD:Number = 150;
		public var lemons:Array;
		public var bullets:Number;
		public var shootTimer:Timer;
		public var hurtTimer:Timer;
		public var onCooldown:Boolean;
		
		//Variables for sounds
		public var shootSound:Sound;
		public var hitSound:Sound;
		public var jumpSound:Sound;
		public var shootManChannel:SoundChannel;

		public function ShootMan()
		{
			// constructor code
			lemons = new Array();
			shootTimer = new Timer(SHOOT_CD);
			hurtTimer = new Timer(650);

			currentAnimation = "Platform_Idle";
			currentHealth = BASE_HEALTH;
			
			speed = 0;
			speedY = 0;
			bullets = 0;
			
			currentXP = 0;
			xpToLevel = 50;
			level = 1;
			
			bonusRun = 0;
			bonusJump = 0;
			shotPower = 1;
			bonusHealth = 0;
			skillPoints = 0;
			
			isJumping = false;
			isShooting = false;
			isHurting = false;
			stopping = false;
			onCooldown = false;
			
			shootSound = new Sound();
			hitSound = new Sound();
			jumpSound = new Sound();
			shootManChannel = new SoundChannel();
			
			shootSound.load(new URLRequest("Sounds/playerShoot.mp3"));
			jumpSound.load(new URLRequest("Sounds/playerJump.mp3"));
			hitSound.load(new URLRequest("Sounds/playerHit.mp3"));
		}

		public function Idle()
		{
			currentAnimation = "Platform_Idle";
				
			gotoAndPlay(currentAnimation);
			//stopping = true;
		}

		public function Left()
		{
			if (! isJumping && ! isShooting)
			{
				if (currentAnimation != "Platform_Run")
				{
					currentAnimation = "Platform_Run";
					gotoAndPlay(currentAnimation);
				}

			}
			else if (!isJumping && isShooting)
			{
				if (currentAnimation != "Platform_Run_And_Shoot")
				{
					currentAnimation = "Platform_Run_And_Shoot";
					gotoAndPlay(currentAnimation);
				}
			}

			stopping = false;
			speed = -BASE_SPEED - bonusRun;
			scaleX = -1;

		}

		public function Right()
		{
			if (! isJumping && ! isShooting)
			{
				if (currentAnimation != "Platform_Run")
				{
					currentAnimation = "Platform_Run";
					gotoAndPlay(currentAnimation);
				}

			}
			else if (!isJumping && isShooting)
			{
				if (currentAnimation != "Platform_Run_And_Shoot")
				{
					currentAnimation = "Platform_Run_And_Shoot";
					gotoAndPlay(currentAnimation);
				}
			}

			stopping = false;
			speed = BASE_SPEED + bonusRun;
			scaleX = 1;
		}

		public function Jump()
		{
			if (! isShooting)
			{
				if (currentAnimation != "Platform_Jump")
				{
					currentAnimation = "Platform_Jump";
					gotoAndPlay(currentAnimation);
				}
			}
			else
			{
				if (currentAnimation != "Platform_Jump_And_Shoot")
				{
					currentAnimation = "Platform_Jump_And_Shoot";
					gotoAndPlay(currentAnimation);
				}
			}

			shootManChannel = jumpSound.play();
			shootManChannel.soundTransform = Main.sfxTransform;
			
			y +=  1;
			isJumping = true;
			speedY = BASE_JUMP - bonusJump;
		}

		public function Shoot()
		{
			var mainInstance:MovieClip = Main.main;
			var newLemon:Lemon;
			
			if (! onCooldown)
			{
				onCooldown = true;
				shootTimer.addEventListener(TimerEvent.TIMER, changeCD);
				shootTimer.start();
				var positionX:Number = 0;
				var Speed:Number = 0;

				if (scaleX > 0)
					positionX = x + width / 2;
				else
					positionX = x - width / 2;
				
				if(speed == 0)
				{
					Speed = 5 * scaleX;
					
					if(!isJumping)
					{
						currentAnimation = "Platform_Stand_And_Shoot";
					}
					else
						currentAnimation = "Platform_Jump_And_Shoot";
						
						gotoAndStop(currentAnimation);
				}
				else
				{
					Speed = speed;
					
					if(!isJumping)
					{
						currentAnimation = "Platform_Run_And_Shoot";
						gotoAndPlay(currentAnimation);
					}
					else
					{
						currentAnimation = "Platform_Jump_And_Shoot";
						gotoAndStop(currentAnimation);
					}
				}
				
				shootManChannel = shootSound.play();
				shootManChannel.soundTransform = Main.sfxTransform;
				
				newLemon = new Lemon(positionX, y, Speed, shotPower);
				lemons.push(newLemon);
				bullets++;
				mainInstance.stage.addChild(newLemon);
			}
		}
		
		public function changeCD(e:TimerEvent)
		{
			if(onCooldown)
			{
				onCooldown = false;
				shootTimer.removeEventListener(TimerEvent.TIMER, changeCD);
				shootTimer.stop();
			}
		}
		
		public function shootManUpdate()
		{
			var mainInstance:MovieClip = Main.main;
			
			//Checks if any bullets are on screen.
			//Updates them accordingly and makes sure shootman
			//is animated as if he's shooting.
			if(bullets > 0)
			{
				isShooting = true;
				
				if(speed == 0 && !isJumping && !isHurting)
					gotoAndPlay("Platform_Stand_And_Shoot");
				
				for(var i:int = 0; i < lemons.length; i++)
				{
					lemons[i].x += lemons[i].speed;
					
					if(lemons[i].x < 0 || lemons[i].x > mainInstance.stage.stageWidth)
					{
						mainInstance.stage.removeChild(lemons[i]);
						lemons.splice(i, 1);
						bullets--;
					}
				}
			}
			else
			{
				isShooting = false;
				
				if(isJumping && !isHurting)
				{
					currentAnimation = "Platform_Jump";
					gotoAndStop(currentAnimation);
				}
				else if(!isHurting)
				{
					if(speed == 0)
					{
						Idle();
					}
					else
					{
						if(currentAnimation != "Platform_Run" && !isHurting)
						{
							currentAnimation = "Platform_Run";
							gotoAndPlay(currentAnimation);
						}
					}
				}
			}
			
			//Moves shootman and keeps him on the screen
			if(!stopping)
			{
				if(x + speed > width / 2 && (x + width / 2) + speed < mainInstance.stage.stageWidth)
					x += speed;
			}
			//If he is stopping his speed will bleed off and be set to 0 when
			//below a threshold
			else
			{
				speed *= 0.95;
				
				if(speed < 0.5 || speed > 0.5)
				{
					stopping = false;
					speed = 0;
				}
			}
			
			//A boolean that determines if gravity should be applied
			var shouldFall:Boolean = checkCollisions();
				
			//Makes shootMan jump
			if(isJumping)
			{
				y += speedY;
				speedY += 0.5;
			}
			//Here, if shootman has walked off a platform
			//gravity will be applied to him and he will fall
			else if(shouldFall && y < mainInstance.PLATFORM_GROUND)
			{
				y += speedY;
				speedY += 0.5;
			}
			//Else his speedY is adjusted to 0
			else if(!shouldFall)
				speedY = 0;
			
			//If shootMan is falling this block will stop his falling
			//And apply the appropriate animation according to what he
			//was doing when he hit the ground
			if(y > mainInstance.PLATFORM_GROUND && shouldFall)
			{
				y = mainInstance.PLATFORM_GROUND;
				isJumping = false;
				shouldFall = false;
				stopping = false;
				
				if(speed == 0)
					Idle();
				else
				{
					if(!isShooting && !isHurting)
						gotoAndPlay("Platform_Run");
					else //if (!isHurting)
						gotoAndPlay("Platform_Run_And_Shoot");
				}
			}
		}
		
		public function Hit(hammerSpeed:Number)
		{
			isHurting = true;
			isJumping = true;
			
			if(currentAnimation != "Platform_Ouch")
			{
				currentAnimation = "Platform_Ouch";
				gotoAndPlay(currentAnimation);
			}
			
			if(hammerSpeed == 0)
				hammerSpeed = 5;
				
			speed = hammerSpeed;
			speedY = -5;
			
			shootManChannel = hitSound.play();
			shootManChannel.soundTransform = Main.sfxTransform;
			
			hurtTimer.addEventListener(TimerEvent.TIMER, Recover);
			hurtTimer.start();
		}
		
		public function Recover(e:TimerEvent)
		{
			isHurting = false;
			speed = 0;
			hurtTimer.removeEventListener(TimerEvent.TIMER, Recover);
			hurtTimer.stop();
		}
		
		public function checkCollisions(): Boolean
		{
			var willFall:Boolean;
			
			for(var i:int = 0; i < Main.platforms.length; i++)
			{
				if(Collisions.CollideTop(this, Main.platforms[i]) && speedY > 0)
				{
					y = (Main.platforms[i].y) - height / 2 - 7;
					isJumping = false;
					speedY = 0;
					willFall = false;
					
				if (currentAnimation != "Platform_Run" 
					&& currentAnimation != "Platform_Run_And_Shoot"
					&& (speed > 1 || speed < -1))
				{
					if(!isShooting)
						currentAnimation = "Platform_Run";
					else
						currentAnimation = "Platform_Run_And_Shoot";
						
					gotoAndPlay(currentAnimation);
				}
				else if (currentAnimation != "Platform_Idle" && speed == 0)
				{
					if(!isShooting)
					{
						currentAnimation = "Platform_Idle";
						gotoAndStop(currentAnimation);
					}
					else
					{
						currentAnimation = "Platform_Stand_And_Shoot";
						gotoAndStop(currentAnimation);
					}
										
				}
						
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
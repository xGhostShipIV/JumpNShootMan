package 
{

	import flash.display.MovieClip;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.media.SoundTransform;
		
	public class Main extends MovieClip
	{
		//Creates a static object of main so we can access
		//it -- and the stage from other classes
		public static var main:Main;
		
		//Arrays of level objects. They are static so they can be used
		//in other classes
		public static var trees:Array;
		public static var platforms:Array;
		public static var enemies:Array;
		public var Lives:Array;
	
		//A constant for the position of the ground in the platform level
		public const PLATFORM_GROUND:Number = 324;
		
		//Declaration of all objects used throughout the game
		public var backgroundImage:MovieClip;
		public var jumpMan:MovieClip;
		public var shootMan:MovieClip;
		public var levelUp:MovieClip;
		public var victoryText:MovieClip;
		
		//Variables required to handle achievements
		public var achievementDisplay:MovieClip;
		public var firstWin:Boolean;
		public var levelFive:Boolean;
		public var achievSound:Sound;
		public var achieveChannel:SoundChannel;
		
		//All variables used in the stats menu
		var statScreen:MovieClip;
		var statCursor:MovieClip;
		var statText:TextField;
		var statFormat:TextFormat;
		var statCursorPos:int;
		var xPos:Array;

		public static var musicTransform:SoundTransform = new SoundTransform();
		public static var sfxTransform:SoundTransform = new SoundTransform();
		
		public var OWMusic:Sound = new Sound();
		public var PFMusic:Sound = new Sound();
		
		public function Main()
		{
			if(!stage) this.addEventListener(Event.ADDED_TO_STAGE, init);
			else init();
			

		}
		
		private function init(e:Event = null)
		{
						//Initializes our static main object
			main = this;
			
			//Initializes all objects
			jumpMan = new JumpMan();
			shootMan = new ShootMan();
			levelUp = new LevelUpText();
			victoryText = new VictoryText();
			
			statScreen = new StatScreen();
			statCursor = new StatCursor();
			statText = new TextField();
			statFormat = new TextFormat();
			statCursorPos = 0;
			xPos = new Array(3);
			
			trees = new Array(12);
			platforms = new Array(3);
			enemies = new Array(2);
			Lives = new Array(shootMan.currentHealth);
			
			achievementDisplay = new Achievement();
			achievSound = new Sound();
			achievSound.load(new URLRequest("Sounds/achievment.mp3"));
			achieveChannel = new SoundChannel();
			firstWin = false;
			levelFive = false;
			
			backgroundImage = new backGround();
			
			for (var i:int = 0; i < trees.length; i++)
				trees[i] = new Tree();
				
			for(var r:int = 0; r < enemies.length; r++)
				enemies[r] = new Enemy();
				
			for(var j:int = 0; j < platforms.length; j++)
				platforms[j] = new Platform();
				
			for(var i:int = 0; i < Lives.length; i++)
				Lives[i] = new LifeCounter();
				
			OWMusic.load(new URLRequest("Sounds/overworldMusic.mp3"));
			PFMusic.load(new URLRequest("Sounds/battleMusic.mp3"));
		}

		public function StartOverWorld():void
		{
			//**** This Method is called from the stage whenever the frame  ****//
			//**** that holds the overworld is accessed.  This will make it ****//
			//**** easier for when we implement menus and other navigation  ****//
			//**** tools.													****//
			
			//Note: This method will also be called when the platform level ends.
			// This way it will reinitialize the overworld level.
			
			//Adding All Event Listeners
			stage.addEventListener(KeyboardEvent.KEY_DOWN, moveJumpMan);
			stage.addEventListener(KeyboardEvent.KEY_UP, stopJumpMan);
			stage.addEventListener(Event.ENTER_FRAME, OWUpdate);
			
			//Begins playing the overworld music track
			musicChannel = OWMusic.play();
			musicChannel.soundTransform = musicTransform;
			
			//This methods adds all the trees to the stage.
			//Its very messy because I couldn't find a neater way to do it
			placeTrees();
			stage.color = 0x17b813;

			//sets the starting position for jumpman and adds him to the stage
			jumpMan.x = stage.stageWidth / 2;
			jumpMan.y = stage.stageHeight / 2;
			jumpMan.resetEncounter();
			
			addChild(jumpMan);
		}
		
		public function OWUpdate(e:Event):void
		{
			jumpMan.jumpManUpdate();
			
			//Compares the steps taken to the number of steps required to start an encounter
			if(jumpMan.stepsTaken >= jumpMan.stepsToEncounter)
			{
				startEncounter();
			}
		}
		
		public function stopJumpMan(e:KeyboardEvent)
		{
			//Since the Key_up listener listens for any key being released
			//I had to specify a range of keys that I wanted the function to 
			//apply to
			if(e.keyCode >= 37 || e.keyCode <= 40)
				jumpMan.Idle();
		}
		
		public function moveJumpMan(e:KeyboardEvent)
		{
			if(e.keyCode == 37) //Left arrow key code
			{
				jumpMan.MoveLeft();
			}
			if(e.keyCode == 39) //Right Arrow key Code
			{
				jumpMan.MoveRight();
			}
			if(e.keyCode == 38) //Up arrow key Code
			{
				jumpMan.MoveUp();
			}
			if(e.keyCode == 40) //Down Arrow key Code
			{
				jumpMan.MoveDown();
			}
			if(e.keyCode == 75)
			{
				gotoStats();
			}
		}
		
		public function gotoStats()
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, moveJumpMan);
			stage.removeEventListener(Event.ENTER_FRAME, OWUpdate);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, updateStats);
			removeChild(jumpMan);
			
			for(var i:int = 0; i < trees.length; i++)
				removeChild(trees[i]);
				

			xPos[0] = 117;
			xPos[1] = 275;
			xPos[2] = 435;
			
			statCursorPos = 0;
			statCursor.x = xPos[0];
			statCursor.y = 348;
			
			statText.text = String(shootMan.skillPoints);
			statText.x = 160; statText.y = 10;
			
			statFormat.color = 0xc0a00c;
			statFormat.size = 14;
			
			statText.setTextFormat(statFormat);
			
			stage.addChild(statScreen);
			stage.addChild(statCursor);
			stage.addChild(statText);
		}
		
		public function updateStats(e:KeyboardEvent)
		{
			if(e.keyCode == 39)
			{
					statCursorPos++;

					if(statCursorPos >= xPos.length)
						statCursorPos = 0;
					
				statCursor.x = xPos[statCursorPos];
			}
			if(e.keyCode == 37)
			{
					statCursorPos--;

					if(statCursorPos < 0)
						statCursorPos = 2;
					
				statCursor.x = xPos[statCursorPos];
			}
			if(e.keyCode == 13)
			{
				if(shootMan.skillPoints > 0)
				{
					if(statCursor.x == xPos[0])
					{
						shootMan.bonusJump += 2;
					}
					if(statCursor.x == xPos[1])
					{
						shootMan.shotPower++;
					}
					if(statCursor.x == xPos[2])
					{
						shootMan.bonusHealth++;
						shootMan.bonusRun += 2;
					}
					
					shootMan.skillPoints--;
					statText.text = String(shootMan.skillPoints);
				}
				
			}
			if(e.keyCode == 75)
			{
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, updateStats);
				stage.addEventListener(Event.ENTER_FRAME, OWUpdate);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, moveJumpMan);
			
				stage.removeChild(statCursor);
				stage.removeChild(statText);
				stage.removeChild(statScreen);
				
				addChild(jumpMan);
				placeTrees();
			}
			
		}
		//this is ugly as all hell but I couldnt figure out a way to code it and
		//have them placed where I wanted.
		public function placeTrees()
		{
			trees[0].x = 0; trees[0].y = 0; addChild(trees[0]);
			trees[1].x = trees[1].width; trees[1].y = 0; addChild(trees[1]);
			trees[2].x = 0; trees[2].y = trees[2].height; addChild(trees[2]);
			
			trees[3].x = stage.stageWidth - 2 * trees[3].width; trees[3].y = 0; addChild(trees[3]);
			trees[4].x = stage.stageWidth - trees[4].width; trees[4].y = 0; addChild(trees[4]);
			trees[5].x = stage.stageWidth - trees[5].width; trees[5].y = trees[5].height; addChild(trees[5]);
			
			trees[6].x = 0; trees[6].y = stage.stageHeight - trees[6].height; addChild(trees[6]);
			trees[7].x = trees[7].width; trees[7].y = stage.stageHeight - trees[7].height; addChild(trees[7]);
			trees[8].x = 0; trees[8].y = stage.stageHeight - 2 * trees[8].height; addChild(trees[8]);
			
			trees[9].x = stage.stageWidth - 2 * trees[9].width; trees[9].y = stage.stageHeight - trees[9].height; addChild(trees[9]);
			trees[10].x = stage.stageWidth - trees[10].width; trees[10].y = stage.stageHeight - trees[10].height; addChild(trees[10]);
			trees[11].x = stage.stageWidth - trees[11].width; trees[11].y = stage.stageHeight - 2 * trees[11].height; addChild(trees[11]);
		}
		
		public function startEncounter():void
		{
			//Removes listeners for the overworld and all MCs associated with it
			stage.removeEventListener(Event.ENTER_FRAME, OWUpdate);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, moveJumpMan);
			removeChild(jumpMan);
			
			for(var i:int = 0; i < trees.length; i++)
				removeChild(trees[i]);
			
			addPlatforms();
						
			//Adds enemies to the stage at predefined locations
			for(var j:int = 0; j < 2; j++)
			{
				enemies[j] = new Enemy();
				enemies[j].x = (100 * j) + (200 * j) + enemies[j].width * 2.5;
				enemies[j].y = PLATFORM_GROUND - 57 - enemies[j].height / 2;
				stage.addChild(enemies[j]);
			}
			
			
			//Sets the position for shootMan and puts him back to full health
			//Also sets him back to his default animation
			shootMan.x = stage.stageWidth / 2;
			shootMan.y = PLATFORM_GROUND;
			shootMan.currentHealth = shootMan.BASE_HEALTH + shootMan.bonusHealth;
			shootMan.currentAnimation = "Platform_Idle";
			shootMan.gotoAndPlay(shootMan.currentAnimation);
			
			//Reinitializes the life counter array to accomadate for bonus health
			Lives = new Array(shootMan.currentHealth);
			
			//Adds life counters to the stage
			for(var i:int = 0; i < shootMan.currentHealth; i++)
			{
				Lives[i] = new LifeCounter();
				Lives[i].x = i * Lives[i].width + 5;
				Lives[i].y = 10;
				
				stage.addChild(Lives[i]);
			}
			
			//Stops the OW soundtrack and starts the platform music
			musicChannel.stop();
			musicChannel = PFMusic.play();
			musicChannel.soundTransform = musicTransform;
			
			//Adds the movieclips to be used for the platform stage
			stage.addChildAt(backgroundImage, 0.9);
			stage.addChild(shootMan);
			
			//Creates a delay when the platform level start. Otherwise it allowed
			//No reaction time for the player to adjust from overworld to platform
			setTimeout(PFListeners, 2000);
		}
		
		public function addPlatforms()
		{
			//Self explanatory. Had to be done manually cause I couldnt figure out the math
			platforms[0].x = platforms[0].width * 1.25; platforms[0].y = PLATFORM_GROUND - 50;
			platforms[1].x = stage.stageWidth - platforms[1].width * 1.25; platforms[1].y = PLATFORM_GROUND - 50;
			platforms[2].x = stage.stageWidth / 2; platforms[2].y = PLATFORM_GROUND - 130;
			
			for(var i:int = 0; i < platforms.length; i++)
				stage.addChild(platforms[i]);
				
		}
		
		public function PFListeners()
		{
			//Starts all functionality of the platform level.
			//IE the updates and controls as well as the AI
			stage.addEventListener(Event.ENTER_FRAME, PFUpdate);
			stage.addEventListener(KeyboardEvent.KEY_UP, stopShootMan);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, moveShootMan);
			
			for(var i:int = 0; i < enemies.length; i++)
				enemies[i].actTimer.start();
		}
		
		public function moveShootMan(e:KeyboardEvent)
		{
			//Removes control from player is shootMan has been hit
			if(!shootMan.isHurting)
			{
				if(e.keyCode == 37)
					shootMan.Left();
				if(e.keyCode == 39)
					shootMan.Right();
				if(e.keyCode == 32)
				{
					//Prevents double jumping
					if(!shootMan.isJumping)
						shootMan.Jump();
				}
				if(e.keyCode == 17)
				{
					//Shooting
					shootMan.Shoot();
				}
			}
		}
		
		public function stopShootMan(e:KeyboardEvent)
		{
			//Since keyUp event polls for every key, I had to specify which keys
			//I didnt want to apply these effects to. So space bar and left control
			if(e.keyCode != 32 && e.keyCode != 17 && !shootMan.isHurting)
			{
				//Conditions to control the animations that will play
				if(!shootMan.isJumping && !shootMan.isShooting)
				{
					shootMan.Idle();
					shootMan.stopping = true;
				}
				else
					shootMan.stopping = true;
			}
		}
		
		public function PFUpdate(e:Event)
		{			
			shootMan.shootManUpdate();
			
				
			//Handles updates for enemies, as well as enemy - shootman collision
			for(var i:int = 0; i < enemies.length; i++)
			{
				//Checks for collision and prevents health loss if multiple hits
				//Occur in too rapid of a succession
				if(Collisions.Collision(enemies[i], shootMan) && !shootMan.isHurting)
				{
				   shootMan.Hit(enemies[i].speedX);
				   enemies[i].speedX = 0;
				   enemies[i].actTimer.stop();
				   enemies[i].actTimer.start();
				 
				   	shootMan.currentHealth--;
					stage.removeChild(Lives[shootMan.currentHealth]);
					Lives.pop();
				}
				
				//If the enemy shouldnt be dead, update him. Otherwise kill him
				if(!enemies[i].isDying)
					enemies[i].EnemyUpdate(shootMan.x);
				else
				{
					enemies[i].Die();
					shootMan.currentXP += 10;
					enemies.splice(i, 1);
				}
			}
				
			//Checks if any of ShootMans lemons collide with an enemy
			for(var j:int = 0; j < shootMan.lemons.length; j++)
				for(var jj:int = 0; jj < enemies.length; jj++)
					if(Collisions.Collision(shootMan.lemons[j], enemies[jj]))
					{
						//Adjusts the enemies current health
						enemies[jj].e_soundChannel = enemies[jj].e_hitSound.play();
						enemies[jj].e_soundChannel.soundTransform = sfxTransform;
						enemies[jj].currentHealth -= shootMan.lemons[j].power;
						
						//Commences enemy death
						if(enemies[jj].currentHealth <= 0)
							enemies[jj].isDying = true;
							
						//Removes the lemon from the stage and from the array of lemons
						stage.removeChild(shootMan.lemons[j]);
						shootMan.lemons.splice(j, 1);
						shootMan.bullets--;
						//Breaks to avoid a crash cause from changing the size
						//of the array during the loop
						break;
					}
					
			for(var k:int = 0; k < Enemy.hammers.length; k++)
			{
				//Checks collision between shootman and enemy projectiles
				if(Collisions.Collision(Enemy.hammers[k], shootMan))
				{
					//Prevents health loss in the event of too many successive hits
					if(!shootMan.isHurting)
					{
						shootMan.currentHealth -= Enemy.hammers[k].power;
						shootMan.Hit(Enemy.hammers[k].speed);
						stage.removeChild(Lives[shootMan.currentHealth]);
						Lives.pop();
					}
					
					stage.removeChild(Enemy.hammers[k]);
					Enemy.hammers.splice(k, 1);
					
					break;
				}
			}
			
			//Final thing to check is win/loss conditions
			if(shootMan.currentHealth <= 0)
				PFDefeat();
			if(enemies.length == 0)
				PFVictory();
		}
		
		public function PFDefeat()
		{
			//Removes all listeners from the stage
			stage.removeEventListener(Event.ENTER_FRAME, PFUpdate);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, moveShootMan);
			stage.removeEventListener(KeyboardEvent.KEY_UP, stopShootMan);
			
			//Creates a text field and its format to display game over text
			var defeatText:TextField = new TextField();
			var textFormat:TextFormat = new TextFormat();
			
			defeatText.y = 100;
			defeatText.text = "GAME OVER";
			defeatText.x = stage.stageWidth / 2 - defeatText.width / 2;
			
			textFormat.size = 26;
			textFormat.color = 0xFBB117;
			textFormat.bold = true;
			
			defeatText.setTextFormat(textFormat);
			defeatText.wordWrap = true;
			
			stage.addChildAt(defeatText, 1);
			
			//Stops AI but does not remove them.
			for(var i:int = 0; i < enemies.length; i++)
			{
				enemies[i].stop();
				enemies[i].actTimer.stop();
				enemies[i].actTimer.removeEventListener(TimerEvent.TIMER, enemies[i].chooseAction);
			}
				
			//Removes any lemons
			for(var j:int = 0; j < shootMan.lemons.length; j++)
			{
				stage.removeChild(shootMan.lemons[j]);
				shootMan.bullets--;
			}
			
			//Empties lemon array
			shootMan.lemons.splice(0, shootMan.lemons.length);
			
			//Removes any hammers
			for(var k:int = 0; k < Enemy.hammers.length; i++)
				stage.removeChild(Enemy.hammers[k]);
								
			//Empties hammer array
			Enemy.hammers.splice(0, Enemy.hammers.length);
			
			//Adds a new Frame event to animate shootMans death
			stage.addEventListener(Event.ENTER_FRAME, defeatAnimation);
		}
		
		public function endGame(e:KeyboardEvent)
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, endGame);
			musicChannel.stop();
			
			//Removes all children that are remaining on the stage
			for(var i:int = 0; i < enemies.length; i++)
				stage.removeChild(enemies[i]);
				
			for(var i:int = 0; i < platforms.length; i++)
				stage.removeChild(platforms[i]);
				
			while(stage.numChildren - 1 > 0)
				stage.removeChildAt(0);
				
			//Re-initializes shootMan so if player decides to play again
			//He is back to his default values.
			shootMan = new ShootMan();
			
			//Goes to the main menu frame
			gotoAndPlay("Game_Menu");
		}
		
		public function defeatAnimation(e:Event)
		{
			shootMan.gotoAndPlay("Platform_Ouch");
			
			//Causes shootMan to fadeout
			shootMan.alpha -= 0.05;
			
			//If he is completely faded stop animation and remove shootman
			//At this point no other functionality occurs and the game must be
			//exited via the X button.  As I cannot find a method to quit flash
			if(shootMan.alpha <= 0)
			{
				//at the end of the animation will add a "Any Key" listener
				//to return to the main menu
				stage.removeEventListener(Event.ENTER_FRAME, defeatAnimation);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, endGame);
				stage.removeChild(shootMan);
			}
		}
		
		public function PFVictory()
		{
			//Removes control from the game
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, moveShootMan);
			stage.removeEventListener(KeyboardEvent.KEY_UP, stopShootMan);
			stage.removeEventListener(Event.ENTER_FRAME, PFUpdate);
			
			//Removes lemons
			for(var i:int = 0; i < shootMan.lemons.length; i++)
			{
				stage.removeChild(shootMan.lemons[i]);
				shootMan.bullets--;
			}
				
			//empties the lemon array
			shootMan.lemons.splice(0, shootMan.lemons.length);
			
			
			//Removes life counters
			for(var i:int = 0; i < Lives.length; i++)
				stage.removeChild(Lives[i]);
				
			//Checks for achievements and displays them once if conditions are met
			if(!firstWin)
			{
				firstWin = true;
				stage.addChildAt(achievementDisplay, 1);
				achievementDisplay.gotoAndStop("FirstWin");
				achieveChannel = achievSound.play();
				achieveChannel.soundTransform = sfxTransform;
			}
			
			if(shootMan.level == 5 && !levelFive)
			{
				levelFive = true;
				stage.addChildAt(achievementDisplay, 1);
				achievementDisplay.gotoAndStop("lvl5");
				achieveChannel = achievSound.play();
				achieveChannel.soundTransform = sfxTransform;

			}
			
			//If shootMan isnt on the ground an animation will happen that will
			//bring him to the ground and then call the end method.
			//Else the end method is called
			if(shootMan.y < PLATFORM_GROUND)
			{
				stage.addEventListener(Event.ENTER_FRAME, victoryAnimation);
			}
				else
				{
					shootMan.gotoAndPlay("Platform_Victory");
					checkLevel();
				}
		}
		
		public function victoryAnimation(e:Event)
		{
			//If shootMan is not on the ground make him fall toward it
			if(shootMan.y < PLATFORM_GROUND)
			{
				if(shootMan.currentAnimation != "Platform_Jump")
					shootMan.currentAnimation = "Platform_Jump";
				
				shootMan.gotoAndPlay(shootMan.currentAnimation);
				shootMan.y += 5;
			}
			//Else end the animation and call last platform method
			else
			{
				shootMan.y = PLATFORM_GROUND;
				stage.removeEventListener(Event.ENTER_FRAME, victoryAnimation);
				
				shootMan.gotoAndPlay("Platform_Victory");
				checkLevel();
			}
		}
		
		public function checkLevel()
		{
			//This method determines whether or not shootMan gained enough experience to level up
			//If he has the appropriate animations and winText will be displayed.  As well as all
			//RPG elements will be adjusted
			var winText:TextField = new TextField();
			var winFormat:TextFormat = new TextFormat();
			winText.width = 155;			
			winFormat.color = 0xffd700;
			winFormat.size = 18;
			
			if(shootMan.currentXP >= shootMan.xpToLevel)
			{
				levelUp.x = stage.stageWidth / 2;
				levelUp.y = 100;
				
				winText.x = stage.stageWidth / 2 - 50;
				winText.y = 150;
				winText.text = "+1 Skill Point!";
				winText.setTextFormat(winFormat);
				
				stage.addChildAt(winText, 1);
				stage.addChildAt(levelUp, 1);
				
				shootMan.level++;
				shootMan.currentXP = shootMan.currentXP - shootMan.xpToLevel;
				shootMan.xpToLevel = Math.floor(shootMan.xpToLevel * 1.75);
				shootMan.skillPoints++;

				setTimeout(goOverWorld, 3000);
			}
			else
			{
				victoryText.x = stage.stageWidth / 2;
				victoryText.y = 100;
				
				winText.x = stage.stageWidth / 2 - 50;
				winText.y = 150;
				winText.text = "EXP: " + String(shootMan.currentXP) + " / " + String(shootMan.xpToLevel);
				winText.setTextFormat(winFormat);
				
				stage.addChildAt(winText, 1);
				stage.addChildAt(victoryText, 1);
				
				setTimeout(goOverWorld, 2000);
			}
		}
		
		public function goOverWorld()
		{
			//Removes platformer elements
			stage.removeChild(shootMan);
			stage.removeChild(backgroundImage);
			
			for(var i:int = 0; i < platforms.length; i++)
				stage.removeChild(platforms[i]);
								
			//This is a bit of genius.  Because victory clips and textfields
			//were added locally in the last function, the pointer to them has
			//been lost.  So this statement checks if there are any children left
			//on the stage and removes them without the pointer to them being needed.
			while(stage.numChildren - 1 > 0)
				stage.removeChildAt(0);
				
			//Stops the platform music
			musicChannel.stop();
			
			//Resets number of steps needed for encounter and then restarts the overworld
			jumpMan.resetEncounter();
			StartOverWorld();
		}

	}

}
/*
	@pjs
		crisp="true";
		pauseOnBlur="false";
		preload="data/mc/air.png",
				"data/mc/dirt.png",
				"data/mc/grass.png",
				"data/mc/stone.png",
				"data/mc/bedrock.png",
				"data/mc/iron_ore.png",
				"data/mc/coal_ore.png",
				"data/mc/gold_ore.png",
				"data/mc/logs.png",
				"data/mc/leaves.png",
				"data/mc/player.png",
				"data/mc/diamond_ore.png",

				"data/mine/air.png",
				"data/mine/dirt.png",
				"data/mine/grass.png",
				"data/mine/stone.png",
				"data/mine/bedrock.png",
				"data/mine/iron_ore.png",
				"data/mine/coal_ore.png",
				"data/mine/gold_ore.png",
				"data/mine/logs.png",
				"data/mine/leaves.png",
				"data/mine/player.png",
				"data/mine/diamond_ore.png";
*/

// [rows][cols]
int[][] arrWorld = new int[800][401];
PImage[] blockImages = new PImage[100];
int mouseSelectedBlockX = 0;
int mouseSelectedBlockY = 0;
int blockSize = 32;
int screenScale = 4;
boolean bigPreview = true;
boolean myTextures = false;
boolean forcePreviewUpdate = true;

int blockCovered = 0;
int[] backgroundBlocks = {0, 17, 18};

int playerX = 400;
int prevPlayerX = 400;
int playerY = 180;
int prevPlayerY = 180;

boolean facingLeft = false;		// Actualy Backwards????? facingRight ????

int screenCenterX;
int screenCenterY;
int previewWidth;
int previewHeight;

// DumpPixelArray runs outside in draw().
// Because of this, I need a bunch of vars to hold things.
// Prefix: dpa
boolean dpaWorking = false;
int[][] dpaToDraw;
int dpaI = 0;

// Color Data
color[] blockColors = new color[100];

void settings()
{
	// This only runs on PC, Web ignores it.
	size(800, 600);
	noSmooth();
}

void setup()
{
	frameRate(30);

	SetWebScreenSize();
	WebSetup();
	background(#FFFFFF);
	stroke(#000000);
	fill(#000000);
	println("Program Start.");

	loadMyTextures();

	screenCenterX = blockSize * floor((width / 2) / blockSize);
	screenCenterY = blockSize * floor((height / 2) / blockSize);
	previewWidth = ( floor( width / blockSize ) / 2 );
	previewHeight = ( floor( height / blockSize ) / 2 );

	blockColors[0] = color(204, 255, 255);
	blockColors[1] = color(128, 128, 128);
	blockColors[2] = color(0, 204, 0);
	blockColors[3] = color(153, 102, 51);
	blockColors[7] = color(0, 0, 0);

	blockColors[11] = color(255, 102, 0);
	blockColors[14] = color(255, 255, 102);
	blockColors[15] = color(255, 191, 128);
	blockColors[16] = color(38, 38, 38);
	blockColors[17] = color(109, 49, 18);
	blockColors[18] = color(51, 153, 51);

	blockColors[56] = color(0, 204, 255);

	GenerateWorld();
	blockCovered = arrWorld[playerX][playerY];
	arrWorld[playerX][playerY] = 19;		// Place the player

	//int[][] arrayTest = new int[100][100];

	//DumpPixelArray(AddRoughCircle(arrayTest, 50, 50, 60, 1, 0));
};

void draw()
{
	/*
	if(!focused)
	{
		fill(0, 0, 0);
		textSize(20);
		text("Click to Focus", 700, 50);
	}
	else
	{
		fill(255, 255, 255);
		textSize(20);
		text("Click to Focus", 700, 50);
	}
	*/

	if(dpaWorking) { DumpPixelArrayWork(); };

	mouseSelectedBlockX = mouseX - 299;
	mouseSelectedBlockY = mouseY - 79;

	//print(mouseSelectedBlockX + ", ");
	//println(mouseSelectedBlockY);

	prevPlayerX = playerX;
	prevPlayerY = playerY;

	if(keyPressed)
	{
		arrWorld[playerX][playerY] = blockCovered;

		if( ( key == 'w' ) && (playerY != 0) && ( arrayContains(backgroundBlocks, arrWorld[playerX][max(playerY - 1, 0)]) ) )
		{
			playerY--;
		}
		if( ( key == 'a' ) && (playerX != 0) && ( arrayContains(backgroundBlocks, arrWorld[max(playerX - 1, 0)][playerY]) ) )
		{
			facingLeft = true;
			playerX--;
		}
		if( ( key == 's' ) && (playerY != arrWorld[0].length - 1) && ( arrayContains(backgroundBlocks, arrWorld[playerX][min(playerY + 1, arrWorld[0].length)]) ) )
		{
			playerY++;
		}
		if( ( key == 'd' ) && (playerX != arrWorld.length - 1) && ( arrayContains(backgroundBlocks, arrWorld[min(playerX + 1, arrWorld.length)][playerY]) ) )
		{
			facingLeft = false;
			playerX++;
		}
		//println(playerX + ", " + playerY);
		blockCovered = arrWorld[playerX][playerY];
		arrWorld[playerX][playerY] = 19;
	}

	//if( ( ( mouseX != pmouseX ) || ( mouseY != pmouseY ) || (forcePreviewUpdate == true) ) && (focused) )

	if( ( playerX != prevPlayerX ) || ( playerY != prevPlayerY ) || (forcePreviewUpdate == true) )
	{
		forcePreviewUpdate = false;
		//updatePreview(mouseSelectedBlockX, mouseSelectedBlockY);
		if( !bigPreview )
		{
			updateLittlePreview(playerX, playerY);
		}
		else
		{
			updateBigPreview(playerX, playerY);
		}
	}
};

void keyReleased()
{
	if( key == '`' || key == '~' )
	{
		SetWebScreenSize();
		IntroMessages();
		DumpPixelArray(arrWorld);
	};

	if( key == '+' || key == '=' )
	{
		forcePreviewUpdate = true;
		if( myTextures )
		{
			loadMinecraftTextures();
		}
		else
		{
			loadMyTextures();
		}
	}

	if( key == '-' || key == '_' )
	{
		bigPreview = !bigPreview;
		forcePreviewUpdate = true;
		dpaWorking = false;
		if( !bigPreview )
		{
			println("Switched to little preview.");
			background(#FFFFFF);
			IntroMessages();
			DumpPixelArray(arrWorld);
		}
	}
};

void updateLittlePreview(int centerX, int centerY)
{
	for(int i = -16/screenScale; i <= 16/screenScale; i++)
	{
		for(int j = -16/screenScale; j <= 16/screenScale; j++)
		{
			image(blockImages[0], 145 + blockSize*j, 400 + blockSize*i, blockSize, blockSize);
			if( ( centerY+i >= 0 ) && ( centerX+j >= 0 ) && ( centerY+i < arrWorld[0].length ) && ( centerX+j < arrWorld.length ) )
			{
				if( arrWorld[centerX+j][centerY+i] == 19 )
				{
					pushMatrix();
					image(blockImages[blockCovered], 145 + blockSize * j, 400 + blockSize * i, blockSize, blockSize);
					if( !facingLeft )
					{
						translate(145 + blockSize * j, 400 + blockSize * i);
					}
					else
					{
						translate(145 + blockSize + blockSize * j, 400 + blockSize * i);
						scale(-1, 1);
					}
					image(blockImages[19], 0, 0, blockSize, blockSize);
					popMatrix();
				}
				else
				{
					image(blockImages[arrWorld[centerX+j][centerY+i]], 145 + blockSize * j, 400 + blockSize * i, blockSize, blockSize);
				}
			}
		}
	}
};

void updateBigPreview(int centerX, int centerY)
{
	for(int i = -previewHeight; i <= previewHeight; i++)
	{
		for(int j = -previewWidth; j <= previewWidth; j++)
		{
			image(blockImages[0], screenCenterX + blockSize*j, screenCenterY + blockSize*i, blockSize, blockSize);

			if( ( centerX+j >= 0 ) && ( centerX+j < arrWorld.length ) && ( centerY+i >= 0 ) && ( centerY+i < arrWorld[0].length ) )
			{
				if( arrWorld[centerX+j][centerY+i] == 19 )
				{
					pushMatrix();
					image(blockImages[blockCovered], screenCenterX + blockSize * j, screenCenterY + blockSize * i, blockSize, blockSize);
					if( !facingLeft )
					{
						translate(screenCenterX + blockSize * j, screenCenterY + blockSize * i);
					}
					else
					{
						translate(screenCenterX + blockSize + blockSize * j, screenCenterY + blockSize * i);
						scale(-1, 1);
					}
					image(blockImages[19], 0, 0, blockSize, blockSize);
					popMatrix();
				}
				else
				{
					image(blockImages[arrWorld[centerX+j][centerY+i]], screenCenterX + blockSize * j, screenCenterY + blockSize * i, blockSize, blockSize);
				}
			}
		}
	}
};

void loadMinecraftTextures()
{
	myTextures = false;
	blockImages[0] = loadImage("data/mc/air.png");
	blockImages[1] = loadImage("data/mc/stone.png");
	blockImages[2] = loadImage("data/mc/grass.png");
	blockImages[3] = loadImage("data/mc/dirt.png");
	blockImages[7] = loadImage("data/mc/bedrock.png");

	blockImages[14] = loadImage("data/mc/gold_ore.png");
	blockImages[15] = loadImage("data/mc/iron_ore.png");
	blockImages[16] = loadImage("data/mc/coal_ore.png");
	blockImages[17] = loadImage("data/mc/logs.png");
	blockImages[18] = loadImage("data/mc/leaves.png");
	blockImages[19] = loadImage("data/mc/player.png");

	blockImages[56] = loadImage("data/mc/diamond_ore.png");
};

void loadMyTextures()
{
	myTextures = true;
	blockImages[0] = loadImage("data/mine/air.png");
	blockImages[1] = loadImage("data/mine/stone.png");
	blockImages[2] = loadImage("data/mine/grass.png");
	blockImages[3] = loadImage("data/mine/dirt.png");
	blockImages[7] = loadImage("data/mine/bedrock.png");

	blockImages[14] = loadImage("data/mine/gold_ore.png");
	blockImages[15] = loadImage("data/mine/iron_ore.png");
	blockImages[16] = loadImage("data/mine/coal_ore.png");
	blockImages[17] = loadImage("data/mine/logs.png");
	blockImages[18] = loadImage("data/mine/leaves.png");
	blockImages[19] = loadImage("data/mine/player.png");

	blockImages[56] = loadImage("data/mine/diamond_ore.png");
};

boolean arrayContains(int[] arrayToSearch, int contains)
{
	for(int i = 0; i < arrayToSearch.length; i++)
	{
		if(arrayToSearch[i] == contains)
		{
			return true;
		}
	}
	return false;
}

int CountInArray(int[][] toRead, int toFind)
{
	int count = 0;
	for(int i = 0; i < toRead.length; i++)
	{
		for(int j = 0; j < toRead[0].length; j++)
		{
			if( toRead[i][j] == toFind )
			{
				count++;
			}
		}
	}
	return count;
};

int[][] AddRoughCircle(int[][] arrayToEdit, int xCenter, int yCenter, int radius, int drawWith, int randomness)
{
	for (int j = 0; j <= radius; j++)
	{
		int intCurrentY = yCenter - radius - j;
		int Temp = int(sqrt(radius * radius - j * j));

		//int intLowerX = xCenter - Temp;
		//int intUpperX = xCenter + Temp;

		int intLowerX = xCenter - RandInt(Temp - randomness, Temp + randomness);
		int intUpperX = xCenter + RandInt(Temp - randomness, Temp + randomness);

		for (int k = intLowerX; k <= intUpperX; k++)
		{
			if ((intCurrentY >= 0) && (intCurrentY <= arrayToEdit[0].length - 1) && (k >= 0) && (k <= arrayToEdit.length - 1))
			{
				arrayToEdit[k][intCurrentY] = drawWith;
			}
		}
	}

	for (int j = 0; j <= radius; j++)
	{
		int intCurrentY = yCenter - radius + j;
		int Temp = int(sqrt(radius * radius - j * j));

		//int intLowerX = xCenter - Temp;
		//int intUpperX = xCenter + Temp;

		int intLowerX = xCenter - RandInt(Temp - randomness, Temp + randomness);
		int intUpperX = xCenter + RandInt(Temp - randomness, Temp + randomness);

		for (int k = intLowerX; k <= intUpperX; k++)
		{
			if ((intCurrentY >= 0) && (intCurrentY <= arrayToEdit[0].length - 1) && (k >= 0) && (k <= arrayToEdit.length - 1))
			{
				arrayToEdit[k][intCurrentY] = drawWith;
			}
		}
	}
	return arrayToEdit;
};

void DumpPixelArrayWork()
{
	for(int j = 0; j < dpaToDraw.length; j++)
	{
		stroke(blockColors[dpaToDraw[j][dpaI]]);
		point(300 + j, 80 + dpaI);
	}

	if( dpaI == dpaToDraw[0].length - 1 )
	{
		dpaWorking = false;
	}
	else
	{
		dpaI++;
	}
}

void DumpPixelArray(int[][] toDraw)
{
	dpaWorking = true;
	dpaToDraw = toDraw;
	dpaI = 0;
};

void LogArray(int[][] toDraw)
{
	String row = "";
	for(int i = 0; i < toDraw.length; i++)
	{
		row = "";
		for(int j = 0; j < toDraw[0].length; j++)
		{
			row += toDraw[i][j];
		}
		println(row);
	}
};

void GenerateWorld()
{
	// Add Base World
	// Row  0         =  Bedrock:   7
	// Rows 10 - 49   =  Stone:     1
	// Rows 9 - 6     =  Dirt:      3
	// Rows 5         =  Grass:     2

	// Stone
	for(int i = 0; i < arrWorld.length; i++)
	{
		for(int j = 200; j <= 399; j++)
		{
			arrWorld[i][j] = 1;
		};
	};

	// Dirt
	for(int i = 0; i < arrWorld.length; i++)
	{
		for(int j = 190; j <= 199; j++)
		{
			arrWorld[i][j] = 3;
		};
	};

	// Add Surface Randomness
	for(int i = 0; i <= arrWorld.length; i++)
	{
		arrWorld = AddRoughCircle(arrWorld, RandInt(0, arrWorld.length), RandInt(195,200), RandInt(2,8), 3, 0);
	}

	// Add Grass and Tress
	for(int i = 0; i < arrWorld.length; i++)
	{
		for(int j = 0; j < arrWorld[0].length; j++)
		{
			if(arrWorld[i][j] == 3)
			{
				arrWorld[i][j] = 2;
				if( RandInt(0,9) == 0 )
				{
					// Add a tree
					arrWorld[i][j] = 3;
					int treeHeight = RandInt(4,8);
					int leafRadius = RandInt(3,5);
					//println("Adding tree.  Height: " + treeHeight + ", Leaves: " + leafRadius);

					AddRoughCircle(arrWorld, i, j - treeHeight + leafRadius - 1, leafRadius, 18, 1);

					for(int k = j - 1; k >= j - treeHeight; k--)
					{
						arrWorld[i][k] = 17;
					}
				}
				break;
			}
		}
	}

	// Add Sub-Surface Randomness
	for(int i = 0; i <= arrWorld.length; i++)
	{
		arrWorld = AddRoughCircle(arrWorld, RandInt(0,arrWorld.length), RandInt(204,201), RandInt(1,6), 1, 2);
	}

	// Add Coal
	for(int i = 0; i <= arrWorld.length / 4; i++)
	{
		arrWorld = AddRoughCircle(arrWorld, RandInt(0,arrWorld.length), RandInt(200,399), 3, 16, 1);
	}

	// Add Iron
	for(int i = 0; i <= arrWorld.length / 4; i++)
	{
		arrWorld = AddRoughCircle(arrWorld, RandInt(0,arrWorld.length), RandInt(200,399), 2, 15, 1);
	}

	// Add Diamonds
	for(int i = 0; i <= .25 * arrWorld.length / 4; i++)
	{
		arrWorld = AddRoughCircle(arrWorld, RandInt(0,arrWorld.length), RandInt(350,400), 1, 56, 1);
	}

	// Add Gold
	for(int i = 0; i <= .3 * arrWorld.length / 4; i++)
	{
		arrWorld = AddRoughCircle(arrWorld, RandInt(0,arrWorld.length), RandInt(350,400), 1, 14, 1);
	}

	// Bedrock
	for(int i = 0; i < arrWorld.length; i++)
	{
		arrWorld[i][400] = 7;
	};

	println("Iron: " + CountInArray(arrWorld, 15));
	println("Coal: " + CountInArray(arrWorld, 16));
	println("Diamonds: " + CountInArray(arrWorld, 56));
	println("Gold: " + CountInArray(arrWorld, 14));
};

int RandInt(int min, int max)
{
	return int(random(min,max));
};

void IntroMessages()
{
	stroke(#000000);
	fill(#000000);
	textSize(12);
	text("Click on the canvas to focus sketch.  If the screen gets resized, press the ~ key to repaint. ", 20, 20);
	text("Here is a smiley face image for testing purposes.", 20, 40);
	text("Here is the Generated World:", 300, 70);
	DrawTestImage();
};

void DrawTestImage()
{
	fill(233, 224, 71);
	strokeWeight(7/2);
	ellipse(250/2, 250/2, 300/2, 300/2);
	fill(0);
	ellipse(200/2, 210/2, 30/2, 70/2);
	ellipse(300/2, 210/2, 30/2, 70/2);
	fill(255);
	bezier(150/2, 295/2, 200/2, 370/2, 300/2, 370/2, 350/2, 295/2);
	line(150/2, 295/2, 350/2, 295/2);
	line(160/2, 180/2, 210/2, 135/2);
	line(340/2, 180/2, 290/2, 135/2);
};

// These are Garbage functions that get overwritten by WebCode if on web.
void SetWebScreenSize() {};
void WebSetup() {};

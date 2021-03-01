//Served as a template for the assembly file

//Rewrite all library functions in terms of I/O Registers
//Remove small/unnecessary loops

#define CLK_PIN   13
#define DATA_PIN  11 
#define CS_PIN    10 
#define LB 7         
#define RB 6         

#define lo8(x) ((x)&0xff)
#define hi8(x) ((x)>>8)

uint8_t playerPaddle = 2;
uint8_t compPaddle = 2;
uint8_t ballx = 6;
uint8_t bally = 4;
int8_t speedx = 1;
int8_t speedy = -1;
boolean gameOver = false;

uint16_t buffer = 0 ; 

void spiTransfer(uint8_t data)
{
  SPDR = data;
  while(!(SPSR & (1<<SPIF)));
}

void refresh(){
  for(uint8_t i=1;i<=8;++i)
  {
    if(i==(playerPaddle-1)|i==(playerPaddle)|i==(playerPaddle+1))
      bitSet(buffer,0);
    if(i==(compPaddle-1)|i==(compPaddle)|i==(compPaddle+1))
      bitSet(buffer,15);
    if(i==bally)
      bitSet(buffer,ballx);

    bitClear(PORTB, 2);
    spiTransfer(i);
    spiTransfer(lo8(buffer));
    spiTransfer(i);
    spiTransfer(hi8(buffer));
    bitSet(PORTB, 2);
    
    buffer=0;
  }
}

void updateBall()
{
  // Reverse direction When hitting the bat
  if ((ballx > 13) & (speedx == 1) & (bally <= (compPaddle + 1)) & (bally >= (compPaddle -1)))
    speedx = -1;
  else
    if ((ballx >14) & (speedx == 1))
    {
      speedx=0;
      speedy=0;
      gameOver = true;
    }
  
  if ((ballx < 2) & (speedx == -1) & (bally <= (playerPaddle + 1)) & (bally >= (playerPaddle -1)))
    speedx = 1;
  else
    if ((ballx < 1) & (speedx == -1))
    {
      speedx=0;
      speedy=0;
      gameOver = true;
    }
  if (bally == 8) 
    speedy = -1;
  if (bally == 1) 
    speedy = 1;

  ballx += speedx;
  bally += speedy;

}

void ballChaser()
{
  if((compPaddle + 1) < bally)
    ++compPaddle;
  if((compPaddle - 1) > bally)
    --compPaddle;
}

void lose()
{
  while(true)
  {
    clearDisplays();
    delay(500);
    refresh();
    delay(500);
  }
}


void movePaddleLeft(){
  if(playerPaddle!=2)
    --playerPaddle;
}

void movePaddleRight(){
  if(playerPaddle!=7)
    ++playerPaddle;
}

void sendAll(uint8_t registerIndex, uint8_t value) {
  bitClear(PORTB, 2);
  spiTransfer(registerIndex);
  spiTransfer(value);
  spiTransfer(registerIndex);
  spiTransfer(value);
  bitSet(PORTB, 2);
}

void clearDisplays() {
  for (int row = 1; row <= 8; row++) {
    sendAll(row, 0);
  }
}



void setup() {
  DDRB = bit(5)|bit(3)|bit(2);
  PORTB = bit(2);
  SPCR = 0b01010000;
  DDRD = 0;
  PORTD = bit(7)|bit(6) ;
  sendAll(0xf, 0); // Disable test mode
  sendAll(0xb, 7); // Set scanlines to 8
  clearDisplays();
  sendAll(0xc, 1); // Enable display
}


void loop() {
  updateBall();
  if(gameOver)
    lose();

  ballChaser();
  
  if(!bitRead(PIND, LB))
    movePaddleLeft();
  if(!bitRead(PIND, RB))
    movePaddleRight();
  
  delay(100);
  refresh();
}

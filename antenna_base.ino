#include "pwm01.h"
#define encodeA 2
#define encodeB 3
#define MOTOR_ENA 12
#define DIR_LEFT 10
#define DIR_RIGHT 11
#define PWM_pin 6

float timeconstant = 1000000;
float radianss = 6.283185300;

int dir = 0;
int PWM_out = 0;
float seriel_read = 0;
int encoder_thick = 0;
int n = LOW;
int y = LOW;
int deg = 0;
float turn =0;
int rpm = 0;
float rads = 0;
float rad = 0;
float wave_time = 0;
unsigned long t = 0;
unsigned long timelast = 0;
const float Pi = 3.141593;
float Dz = 0.9876;        //Discritized value for the innercontroller  0.9876
float Kp = 125;           //kp value for outercontroller 127.35
int freq = 2;
float U_v = 0;
float U_p =0;
float Rw = 0;
float Ek = 0;
float Ek_last = 0;
float U_last = 0;
float voltage = 18;
float duty = 0;

void thick() { // counts encoder pulses
     n = digitalRead(encodeA);
     y = digitalRead(encodeB);
     t = micros();
     wave_time = t - timelast;                    // calculate time of pulse length on tachometer
     timelast = t;
    
  if (y == LOW) {
      encoder_thick--;                            // position decrement
  } else {
      encoder_thick++;                            // position increment
  }
  if(wave_time > 5000){                           // The motor Speed is measuered from tachometer pulses,
      rads = 0;                                   //so if a puls becomes to big the motor is not moving.
  } else{
      rads = (radianss*((timeconstant/(500*wave_time)))); // formula for calculating radians pr second, from pulst width on tachometer
  }
    deg = encoder_thick*0.72;                     // calculating angle in degrees from tachometer pulses.
}
void setup() {
  Serial.begin(250000);                           // start serial communication


                                                  // pins setup
  pinMode(MOTOR_ENA, OUTPUT);
  pinMode(DIR_LEFT, OUTPUT);
  pinMode(DIR_RIGHT, OUTPUT);
  pinMode(encodeA, INPUT);
  pinMode(encodeB, INPUT);
  pinMode(encodeA, INPUT_PULLUP);
  pinMode(encodeB, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(encodeA),thick,FALLING);
  digitalWrite(MOTOR_ENA,HIGH);                  // enabling motor
   pwm_setup( 6, 32000, 2);                      //set pwm frequencey to 32 khz on pin 6 with timer 2
   pwm_set_resolution(16);                       // Set PWM Resolution
}
void loop() {


  if ( Serial.available() ) {                    // if there is serial input it will be read from buffer
    seriel_read = Serial.parseFloat();           // saving the data from serialport buffer in memory
    Serial.println(seriel_read);                 // Ascii value
 }
  
  rad = ((deg*Pi)/180);                          // calculating angel into radians
  turn =seriel_read-rad;                         // calculating  differens between referens position and motor position 

  Rw = (Kp*turn+1);                              //outer controller 
  Ek = (Rw-rads);                                //inner controller
  U_p =(U_last+Ek-(Dz*Ek_last));                 // this is the value output from the 2 controllers from motor transfere function 
  U_last = U_p;                                  // saves the current value from U_p for calculations in next loop
  Ek_last = Ek;                                  // saves the value from Ek for calculations in next loop
  duty = U_p/voltage;                            // controller values to create the duty cycle
  
  delay(freq);                                   // a delay to controll the frequencey of updating pwm
  
  if(duty < 0){                                  //if the Duty is negative the value is convertet to positive to be able to convert it to a pwm duty cykle
    duty = duty*(-1);       
    dir = 0;                                     // setting the direction for the motor to turn
  }
  else{
    dir = 1;                                     // setting the direction for the motor to turn
 }
  PWM_out = map(duty,0 ,40,0,65534);             //mapingng controller settings in relation to PWM duty cykle
  
   if (PWM_out > 65533 ){                        //if pwm value is above 65534 it will be more then 100% duty and there will be overflow
       PWM_out = 65534;
 }
  if (dir == 1) {                                // to drive agaienst the counter clockwise
    digitalWrite(DIR_LEFT, HIGH);                               
    digitalWrite(DIR_RIGHT, LOW);                
    pwm_write_duty( 6, PWM_out);                 // Sets the PWM duty_cyckle 
 }
    if(dir == 0){                                // setting motor to turn clocwise
      digitalWrite(DIR_RIGHT, HIGH);
      digitalWrite(DIR_LEFT, LOW);
      pwm_write_duty( 6, PWM_out );             // Sets the PWM duty_cyckle 
 } 

}

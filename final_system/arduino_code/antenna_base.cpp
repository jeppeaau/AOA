// Inclusion of necessary libraries
#include <Arduino.h>
#include <stdint.h>
#include "pwm01.h"

// Definition of I/O pins and constant values
#define ENCODEA 2
#define ENCODEB 3
#define MOTOR_ENA 12
#define DIR_LEFT 10
#define DIR_RIGHT 11
#define PWM_PIN 6
#define pi 3.14159
#define PWM_FREQ 20000
#define pulse_per_rev 500
#define V_MAX 16

// Interpolation function, based on Arduino map function with float numbers
float interpolate(float x, float in_min, float in_max, float out_min, float out_max)
{
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// Variables related to position. All in radians
float theta_current=0;
float theta_previous=0;
float theta_ref=0;
float error_theta=0;
// Angle in radians that corrsponds to a pulse of the encoder
const float theta_increment=2*pi/pulse_per_rev;

// Variables related to velocity. All in radians per second
float omega_current=0;
float omega_ref=0;
float error_omega=0;

// Parameters of the controllers
const float k_theta=12.84;
const float k_omega=2.331;

// Variables related to the control voltage
float u_control=0;
uint32_t duty=0;

// Variable used to time the iterations of the control loop
uint16_t timer_var=0;

// Sampling period specified in microseconds
const uint32_t samp_period=1250;

// Serial communication input buffer
uint8_t buffer[4];

// Interrupt function that measures the position of the encoder
void position_int()
{
    if (digitalRead(ENCODEB))
    {
        theta_current+=theta_increment;
    }
    else
    {
        theta_current-=theta_increment;
    }
}

// Initial configuration of the Arduino
void setup()
{
    // Start serial communication at maximum baud rate
    Serial.begin(250000);
    
    // I/O configuration
    pinMode(MOTOR_ENA, OUTPUT);
    pinMode(DIR_LEFT, OUTPUT);
    pinMode(DIR_RIGHT, OUTPUT);
    pinMode(ENCODEA, INPUT_PULLUP);
    pinMode(ENCODEB, INPUT_PULLUP);
    
    // Interrupt configuration, PWM configuration and enabling the motor
    attachInterrupt(digitalPinToInterrupt(ENCODEA), position_int, FALLING);
    digitalWrite(MOTOR_ENA, HIGH);
    pwm_setup(PWM_PIN, PWM_FREQ, 2); 
    pwm_set_resolution(16);
    
    // Store initial system time
    timer_var=micros();
}

// Infinite loop
void loop()
{   
    // Checks if there is a new reference position
    if(Serial.available() >= sizeof(float))
    {
        // If there is a new reference, it is read and bytes
        // and casted into a float number
        Serial.readBytes(buffer,sizeof(float));
        memcpy(&theta_ref,buffer,sizeof(float));
    } 
    
    // Check if a sampling period has passed since the last stored system time
    if(micros()-timer_var >= samp_period)
    {        
        // Store current system time
        timer_var=micros();
        
        // Compute speed from previous position and current position
        omega_current=1e6*(theta_current-theta_previous)/samp_period;
        
        // Measure error in position and compute reference speed
        error_theta=theta_ref-theta_current;
        omega_ref=k_theta*error_theta;
        
        // Measure speed error and compute control voltage
        error_omega=omega_ref-omega_current;
        u_control=k_omega*error_omega;
        
        // Compute duty and limit its value to a 16 bit variable
        duty=(uint32_t)interpolate(fabsf(u_control), 0, V_MAX, 0, 65535);
        if(duty>65535)
        {
            duty=65535;
        }
        
        // Choose direction of the motor according to the value of u_control
        if (u_control > 0)
        {
            digitalWrite(DIR_LEFT, HIGH);
            digitalWrite(DIR_RIGHT, LOW);
        }
        else
        {
            digitalWrite(DIR_LEFT, LOW);
            digitalWrite(DIR_RIGHT, HIGH);
        }
        
        // Write PWM duty cycle
        pwm_write_duty(PWM_PIN, duty);
        
        // Store current position
        theta_previous=theta_current;
    }
}

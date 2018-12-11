#include <Arduino.h>
#include <stdint.h>
#include "pwm01.h"

#define ENCODEA 2
#define ENCODEB 3
#define MOTOR_ENA 12
#define DIR_LEFT 10
#define DIR_RIGHT 11
#define PWM_PIN 6
#define pi 3.14159
#define pulse_per_rev 500
#define V_MAX 12

// Interpolation function, based on Arduino map function with float numbers
float interpolate(float x, float in_min, float in_max, float out_min, float out_max)
{
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// Variables related to position
float theta_current=0;
float theta_previous=0;
float theta_ref=0;
float error_theta=0;
const float theta_increment=2*pi/pulse_per_rev;

// Variables related to velocity
float omega_current=0;
float omega_ref=0;
float error_omega=0;
float error_omega_previous=0;

// Parameters of the controllers
const float k_p=2;
// const float k_p=4;
const float a_0=0.04878;
const float a_1=-0.04265;
const float b_1=-1;

// Variables of the control voltage
float u_control=0;
float u_control_previous=0;
uint32_t duty=0;

// Variable used to time the iterations of the control loop
uint16_t timer_var=0;

// Samplng period specified in microseconds
const uint16_t samp_period=2500;

// Serial communication
uint8_t buffer[4];

// Function that measures the position of the encoder
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

void setup()
{
    Serial.begin(250000);
    
    pinMode(MOTOR_ENA, OUTPUT);
    pinMode(DIR_LEFT, OUTPUT);
    pinMode(DIR_RIGHT, OUTPUT);
    pinMode(ENCODEA, INPUT_PULLUP);
    pinMode(ENCODEB, INPUT_PULLUP);
    
    attachInterrupt(digitalPinToInterrupt(ENCODEA),position_int,FALLING);
    digitalWrite(MOTOR_ENA,HIGH);              // enabling motor
    pwm_setup(6,32000,2);                      //set pwm frequencey to 32 khz on pin 6 with timer 2
    pwm_set_resolution(16);                    // Set PWM Resolution
    
    timer_var=micros();
}

void loop()
{
    if(Serial.available() >= sizeof(float))
    {
        Serial.readBytes(buffer,sizeof(float));
        memcpy(&theta_ref,buffer,sizeof(float));
    }
    
    if(micros()-timer_var >= samp_period)
    {        
        // Set variable for software timer
        timer_var=micros();
        
        // Compute speed from previous position and store current position
        omega_current=1e6*(theta_current-theta_previous)/samp_period;
        // if(omega_current<20 && omega_current>0)
        //     omega_current=0;
        // else if(omega_current>-20 && omega_current<0)
        //     omega_current=0;
        
        // Measure error in position
        error_theta=theta_ref-theta_current;
        omega_ref=k_p*error_theta;
        
        // Compute control voltage from speed controller
        error_omega=omega_ref-omega_current;
        // u_control=a_0*error_omega+a_1*error_omega_previous-b_1*u_control_previous;
        u_control=k_p*error_omega;
        
        // Compute duty and limit its value
        duty=(uint32_t)interpolate(fabsf(u_control), 0, V_MAX, 0, 65535);
        if(duty>65535)
        {
            duty=65535;
        }
        
        // Choose direction of the motor
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
        
        // Store previous variables
        theta_previous=theta_current;
        u_control_previous=u_control;
        error_omega_previous=error_omega;
    }
}

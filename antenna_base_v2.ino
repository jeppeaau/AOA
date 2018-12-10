// Include libraries
#include <Arduino.h>
#include <stdint.h>
#include "pwm01.h"

// Define values that are not required to change
#define ENCODEA 2
#define ENCODEB 3
#define MOTOR_ENA 12
#define DIR_LEFT 10
#define DIR_RIGHT 11
#define PWM_PIN 6
#define pi 3.14159
#define pulse_per_rev 500
#define V_MAX 12

// #define TRIAL

// Interpolation function, based on Arduino map function with float numbers
float interpolate(float x, float in_min, float in_max, float out_min, float out_max)
{
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// Variables related to angular position, in radians (theta)
float theta_current=0;
float theta_ref = 0;
float error_theta=0;
const float theta_increment=2*pi/pulse_per_rev;     // Increment of theta that corresponds to a pulse

// Variables related to angular velocity, in radians per second (omega)
float omega_current=0;
float omega_ref=0;
float error_omega=0;
float error_omega_previous=0;

// Parameters of position controller
const float k_p=6.291;

// Parameters of speed controller. The controller implemented has the form:
//             a_0 + a_1*z^(-1)
//    D(z) = -------------------
//              1 + b_1*z^(-1)
const float a_0=2.9861;
const float a_1=-2.98;
const float b_1=-1;
// Current settings: f_omega=20; f_theta=10; f_samp=800;

// Variables related to the control action (volts)
float u_control=0;
float u_control_previous=0;
// Variable that has to be used to achieve a certain output voltage. Takes values in [0,65535], 
// 16 bit resolution. Defined as 32 bits to avoid overflow during its computation
uint32_t u_control_pwm=0;

// Variables used for timing
uint32_t speed_timer=0;             // Used to compute the speed by differenciating the position
uint32_t control_timer=0;           // Used to execute the control loop every sampling period
const uint16_t samp_period=1250;    // Samplng period specified in microseconds
uint8_t speed_null=1;               // Variable used to find if the motor is not moving
// 0 -> Motor is moving
// 1 -> Motor is not moving

// Variable used for serial communication
union {
    float value;
    uint8_t bytes[4];
} buffer;


// Function that measures the position of the encoder
void position_int()
{
    // Check direction of the motor
    if (digitalRead(ENCODEB))
    {
        // Increase position and compute speed
        theta_current+=theta_increment;
        omega_current=theta_increment/(micros()-speed_timer);
    }
    else
    {
        // Decrease position and compute speed
        theta_current-=theta_increment;
        omega_current=-theta_increment/(micros()-speed_timer);
    }
    // Save current time and set variable speed_null to 0.
    speed_timer=micros();
    speed_null=0;
}

void setup()
{
    // Start serial communication
    Serial.begin(19200);
    
    // Input-Output configuration
    pinMode(MOTOR_ENA, OUTPUT);
    pinMode(DIR_LEFT, OUTPUT);
    pinMode(DIR_RIGHT, OUTPUT);
    pinMode(ENCODEA, INPUT_PULLUP);
    pinMode(ENCODEB, INPUT_PULLUP);
    
    // Enable interrupt on channel A of the encoder, configure
    // PWM output and turn on the motor
    attachInterrupt(digitalPinToInterrupt(ENCODEA),position_int,FALLING);
    digitalWrite(MOTOR_ENA,HIGH);
    pwm_setup(PWM_PIN,32000,2);
    pwm_set_resolution(16);
    
    // Store initial time
    control_timer=micros();
}

void loop()
{
    // Check if there is a new reference position in the serial buffer
    if(Serial.available() >= sizeof(float))
    {
        Serial.readBytes(buffer.bytes,sizeof(float));
        theta_ref=buffer.value;
    }
    
    // If a sampling period has passed, the control loop has to be executed
    if(micros()-control_timer>=samp_period)
    {
        // Store current time for next iteration of the loop
        control_timer=micros();
        
        // This code if compiled if TRIAL is defined. Functionality not checked
        #ifdef TRIAL
        {
            // Check if the interrupt has been called since the last iteration
            // to find if the speed is null
            if(speed_null==1)
            {
                // If it has not been called, the motor is stopped
                // and the value of omega_current may not be correct
                omega_current=0;     
            }
            else
            {
                // Reset speed_null variable
                speed_null=1;
            }
        }
        #endif
        
        // Store previous variables, error and control action
        u_control_previous=u_control;
        error_omega_previous=error_omega;
        
        // Measure error in position
        error_theta=theta_ref-theta_current;
        
        // Compute reference speed from position controller, find speed error
        omega_ref=k_p*error_theta;
        error_omega=omega_ref-omega_current;
        
        // Compute control voltage from speed controller
        u_control=a_0*error_omega+a_1*error_omega_previous-b_1*u_control_previous;
        u_control=k_p*error_omega;
        
        // Compute u_control_pwm and limit its value to a 16 bit value
        u_control_pwm=(uint32_t)interpolate(fabsf(u_control), 0, V_MAX, 0, 65535);
        if(u_control_pwm>65535)
        {
            u_control_pwm=65535;
        }
        
        // Choose direction of the motor according to the value of the voltage
        if (u_control > 0)
        {
            digitalWrite(DIR_LEFT, HIGH);
            digitalWrite(DIR_RIGHT, LOW);
        }
        else
        {
            digitalWrite(DIR_RIGHT, HIGH);
            digitalWrite(DIR_LEFT, LOW);
        }
        
        // Write PWM duty cycle
        pwm_write_duty(PWM_PIN,u_control_pwm);
    }
}

# cureDDrone
Data Driven Fault Diagnosis

This project is about using Data Driven Methods to detect and diagnose faults of a drone.

HOW TO:

1. First run the file dataRead.m
    - This script reads the flight data in .data format  
    - It searches through the data to find data lines corresponding to the data of interest (GPS data, gyro data, accelerometer data). Each line in data corresponds to a specific data type (accelerometer_x, accelerometer_y, accelerometer_z) Measurements that are taken very preliminary meters of the take-off are omitted.
    - It finds the SETTING messages in the .dta file. SETTING is one of the messages saved in the onboard SD card (.data flight data ). In the case there is an entry from the ground control station to go back to the nominal control surface conditions, the SETTING message is in the from : SETTTING 1.0 1.0 0.0 0.0. If there is a fault introduced from the ground control station, those values will change depending on the fault injected.
    - Using the indexes of the SETTING messages, the faulty and nominal phases of the flight are distunguished. The flight starts with no fault, so until the first SETTINGS message, all measurements are labeled as nominal, and are free of fault. The first SETTING message (unless its value is equal to 1.0 1.0 0.0 0.0) means that a fault is injected from the Ground Control Station (GCS). The phase of the flight starting from the last SETTING message until the next setting index are saved in variables fault_start_stop (with a size : 2 X number_of_faulty_phases) and nominal_start_stop  ( with a size : 2 X number_of_nominal_phases). First row corresponds to the index of start of that specific phase and second row corresponds to the end index of that phase. 
EXAMPLE : fault_start_stop = [12333 15738 23908
                              12428 16104 24108] 
          means that the first fault starts at the 12333. line of the data file and that fault finishes at 12428. line. Then all the measurements that corresponds to this interval will be faulty flights and more specificly correspond to the first fault. Which fault they correspond can be checked in the SETTING message that initialtes the interval (EX : data(12333) will correspond to a SETTING message which inclues the information about the fault injected).  

2. Select the fault and nominal phase of your interest in selectFaultToInvest.m file. To do that, you have to select which fault and nominal phase you want to work with. For now, the classification only works for two classes which means that you should select one faulty phase and one nominal phase. The selection is done thought the variables fault_id and nominal_id. 
    - First, check the fault and nominal phases you want to work with by studying the fault_start_stop matrix. It might be easier to explain it on an example that we have initiated above. Given the example above, the first fault phase starts at the  12333th measurements (corresponding time can be seen by printing I AM HERE!  dataArray{1,1}(12333)  

# Fixed2Float_MPW3
This project is the fixed point to floating point converter targetted for any DSP operations. 
When writing signal processing application or interfacing hardware to get some decimal data and process it, more likely we are going to bounce into floating and fixed-point conversion. So there would be a need to convert from floating point to fixed point and vice versa when storing and retrieving decimal values from embedded systems that store the data at fixed length memory locations or registers. 
# I/O
        a:19bit fixed point number
        b:Single precision IEEE floating point number
# Simulation Results
## Pre-Synthesis
    
<img width="700" alt="sim_res" src="https://user-images.githubusercontent.com/61288836/139244314-78fc3ac2-b24c-408c-9da9-15ce61e1e8f0.PNG">
    

## Post Synthesis
    
<img width="700" alt="gls_sim" src="https://user-images.githubusercontent.com/61288836/139244286-7bde09a1-ed9a-420a-b06b-6cd6a3bef7e3.PNG">


# RTL to GDSII

    
<img width="700" alt="fxd2float" src="https://user-images.githubusercontent.com/61288836/139287161-1c6dc5bd-5397-46a4-be7e-ad35e3af9a82.png">

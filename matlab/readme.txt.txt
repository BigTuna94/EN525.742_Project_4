Files in this directory :

sim_100k_0x020c49.txt  : this is the output of a VHDL simulation of the Xilinx DDS running at a frequency near 100kHz (using phase increment = 0x20c49).
file_100k_0x20c49.csv : comma-separated-value file which is the result of running the DDS in the final Lab3 design on the Zedboard.  Outputs were captured from the ILA.  


Note : the matlab script compares the results from 3 things :

1) a matlab simulation of a DDS.  The relevant parameters are at the top
2) a simulation file, the result of doing a VHDL simulation of the DDS
3) the recorded data from the ILA

The results are then plotted in a variety of ways which can help to visualize the similarities / differences.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;    -- Added textio library for file operations

package MatrixPackage is                                -- A package was created to define a two-dimensional matrix.
    type matrix_type is array (natural range <>, natural range <>) of integer range 0 to 255;
end package MatrixPackage;

use work.MatrixPackage.all;
use std.textio.all;

entity read_pixels is
generic(
 Row : integer :=520;       -- Constant values are defined in the generic part, these values are the dimensions of the image and the size of the filter.
 Col : integer :=520;
 mask: integer :=3
);

end read_pixels;

architecture Behavioral of read_pixels is
    signal p1,p2,p3,p4,p5,p6,p7,p8,p9 : integer range 0 to 255;   -- As a 3x3 filter is used, 9 integer variables are defined.
    type ArrArray is array (0 to mask*mask-1) of integer range 0 to 255;   
    signal ArrTmp : ArrArray;       -- Define array to assign elements of 3x3 filter
    signal i1,j1,i2,j2 : integer :=0 ;
    signal image: matrix_type(0 to Row-1,0 to Col-1);  -- A matrix is defined in the dimensions of the input image.
   
    signal Sliding_window:matrix_type(0 to mask-1,0 to mask-1);  -- A 3x3 matrix is defined named sliding_window
    
    -- buffer to store text from input and output
    file input_buf : text; 
    file output_buf: text; 
    
    function find_median(arr: ArrArray) return integer is   -- A function is defined that takes the array "arr" and returns the median value of the array.
        variable sorted_arr: ArrArray := arr;
        variable temp: integer;
    begin
        -- Simple bubble sort is applied to sort the array in ascending order
        for i1 in 0 to mask*mask-1 loop
            for j1 in 0 to mask*mask-2 loop
                if sorted_arr(j1) > sorted_arr(j1 + 1) then
                    temp := sorted_arr(j1);
                    sorted_arr(j1) := sorted_arr(j1 + 1);
                    sorted_arr(j1 + 1) := temp;
                end if;
            end loop;
        end loop;

        -- Return median value from sorted array
        return sorted_arr(mask+1);
    end function;
 
    
begin

    tb: process
        variable read_col_from_input_buf: line; -- Read rows one by one from input_buf
        variable write_col_to_output_buf : line; -- Write rows one by one from output_buf
        variable val_col : integer; -- To save a 1-bit col value
        variable val_SPACE: character;  -- for spaces between data in the file
          
    begin
    -- output_image.txt file opens in write mode to write the pixels of the median filtered image
    file_open(output_buf, "C:\Users\GUL\MezuniyetProjesi\project_18.srcs\sim_1\new\output_image.txt", WRITE_MODE);
    -- File written by pixels of noisy image from matlab opens in read mode
    file_open(input_buf,"input_image.txt",READ_MODE);
       
    while not endfile(input_buf) loop  -- loop until end of file
    for i1 in 0 to Row-1 loop
        for j1 in 0 to Col-1 loop
            readline(input_buf,read_col_from_input_buf);  -- pixel values in the file are read line by line
            read(read_col_from_input_buf,val_col);        -- read values are assigned to image matrix
            read(read_col_from_input_buf,val_SPACE);
            image(i1,j1)<=val_col;  
        end loop;
    end loop;
    

    	
    for i1 in 1 to Row-2 loop
		for j1 in 1 to Col-2 loop
		
		    wait for 10 ns;
		
			Sliding_window(0,0) <= image(i1-1,j1-1);   -- The sliding_window is populated with the corresponding pixel values and the 'find_median' function is called to find the median value.
			Sliding_window(0,1) <= image(i1-1,j1);
			Sliding_window(0,2) <= image(i1-1,j1+1);
			Sliding_window(1,0) <= image(i1,j1-1);
			Sliding_window(1,1) <= image(i1,j1);
			Sliding_window(1,2) <= image(i1,j1+1);
			Sliding_window(2,0) <= image(i1+1,j1-1);
			Sliding_window(2,1) <= image(i1+1,j1);
			Sliding_window(2,2) <= image(i1+1,j1+1);
			
		    wait for 10 ns;

		    
			p1 <= Sliding_window(0,0) ;
			p2 <= Sliding_window(0,1) ;
			p3 <= Sliding_window(0,2) ;
			p4 <= Sliding_window(1,0) ;   -- Values in sliding_window are assigned to variables
			p5 <= Sliding_window(1,1) ;
			p6 <= Sliding_window(1,2) ;
			p7 <= Sliding_window(2,0) ;
			p8 <= Sliding_window(2,1) ;
			p9 <= Sliding_window(2,2) ;
			
		    wait for 10 ns;
			
			ArrTmp(0)<=p1;
			ArrTmp(1)<=p2;
			ArrTmp(2)<=p3;
			ArrTmp(3)<=p4;
			ArrTmp(4)<=p5;  -- p1,p2,...,p9 values are assigned to ArrTmp array respectively
			ArrTmp(5)<=p6;
			ArrTmp(6)<=p7;
			ArrTmp(7)<=p8;
			ArrTmp(8)<=p9;
			
			
			image(i1,j1)<=find_median(ArrTmp); -- The median value of ArrTmp is found with find_median and assigned to the image matrix
		    
		end loop;
	end loop;
	
		wait for 10 ns;
       
        for i1 in 0 to Row-1 loop
            for j1 in 0 to Col-1 loop
                write(write_col_to_output_buf,image(i1,j1));   -- The values in the image matrix are written to the output_image.txt file one after the other.
                writeline(output_buf, write_col_to_output_buf); 
            end loop;
        end loop;
         
         wait for 20 ns;
      end loop;
    
      file_close(input_buf);   -- After the process is completed, the input and output files are closed.
      file_close(output_buf);
      
      wait;
    
    end process tb;
    
end Behavioral; 





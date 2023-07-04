library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;    -- Dosya i�lemleri i�in std_logic_textio k�t�phanesi eklendi

package MatrixPackage is                                -- �ki boyutlu matris tan�mlamak i�in package olu�turuldu.
    type matrix_type is array (natural range <>, natural range <>) of integer range 0 to 255;
end package MatrixPackage;

use work.MatrixPackage.all;
use std.textio.all;

entity read_pixels is
generic(
 Row : integer :=520;       -- Sabit de�erler generic k�sm�nda tan�mlan�r bu de�erler g�r�nt�n�n boyutlar� ve filtrenin boyutudur.
 Col : integer :=520;
 mask: integer :=3
);

end read_pixels;

architecture Behavioral of read_pixels is
    signal p1,p2,p3,p4,p5,p6,p7,p8,p9 : integer range 0 to 255;   -- 3x3 l�k filtre kullan�ld��� i�in 9 adet integer de�i�ken tan�mlan�r
    type ArrArray is array (0 to mask*mask-1) of integer range 0 to 255;   
    signal ArrTmp : ArrArray;       -- 3x3 l�k filtrenin elemanlar�n� atamak i�in dizi tan�mlan�r
    signal i1,j1,i2,j2 : integer :=0 ;
    signal image: matrix_type(0 to Row-1,0 to Col-1);  -- giri� g�r�nt�s�n�n boyutlar�nda bir matris tan�mlan�r.
   
    signal Sliding_window:matrix_type(0 to mask-1,0 to mask-1);  -- Sliding_window ad�nda 3x3 boyutunda matris tan�mlan�r
    
    -- girdiden ve ��kt�dan gelen metni depolamak i�in buffer
    file input_buf : text; 
    file output_buf: text; 
    
    function find_median(arr: ArrArray) return integer is   -- "arr" dizisini alan ve dizinin medyan de�erini d�nd�ren bir fonksiyon tan�mlan�r.
        variable sorted_arr: ArrArray := arr;
        variable temp: integer;
    begin
        -- Diziyi artan d�zende s�ralamak i�in basit bubble sort uygulan�r
        for i1 in 0 to mask*mask-1 loop
            for j1 in 0 to mask*mask-2 loop
                if sorted_arr(j1) > sorted_arr(j1 + 1) then
                    temp := sorted_arr(j1);
                    sorted_arr(j1) := sorted_arr(j1 + 1);
                    sorted_arr(j1 + 1) := temp;
                end if;
            end loop;
        end loop;

        -- S�ralanm�� diziden medyan de�eri d�nd�r
        return sorted_arr(mask+1);
    end function;
 
    
begin

    tb: process
        variable read_col_from_input_buf: line; -- input_buf'tan sat�rlar� tek tek oku
        variable write_col_to_output_buf : line; -- output_buf'a sat�r sat�r yaz
        variable val_col : integer; -- 1 bitlik col de�erini kaydetmek i�in
        variable val_SPACE: character;  -- dosyadaki veriler aras�ndaki bo�luklar i�in
          
    begin
    -- medyan filtre uygulanm�� g�r�nt�n�n piksellerini yazmak i�in output_image.txt dosyas� yazma modunda a��l�r
    file_open(output_buf, "C:\Users\GUL\MezuniyetProjesi\project_18.srcs\sim_1\new\output_image.txt", WRITE_MODE);
    -- matlab'dan al�nm�� g�r�lt�l� g�r�nt�n�n piksellerinin yazd��� dosya okuma modunda a��l�r
    file_open(input_buf,"input_image.txt",READ_MODE);
       
    while not endfile(input_buf) loop  -- dosyan�n sonuna gelene kadar devam eden d�ng�
    for i1 in 0 to Row-1 loop
        for j1 in 0 to Col-1 loop
            readline(input_buf,read_col_from_input_buf);  --dosyadaki piksel de�erler sat�r sat�r okunur
            read(read_col_from_input_buf,val_col);        -- okunan de�erler image matrisine atan�r
            read(read_col_from_input_buf,val_SPACE);
            image(i1,j1)<=val_col;  
        end loop;
    end loop;
    

    	
    for i1 in 1 to Row-2 loop
		for j1 in 1 to Col-2 loop
		
		    wait for 10 ns;
		
			Sliding_window(0,0) <= image(i1-1,j1-1);   -- Sliding_window kar��l�k gelen piksel de�erleriyle doldurulur medyan de�eri bulmak i�in 'find_median' i�levi �a�r�l�r.
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
			p4 <= Sliding_window(1,0) ;   -- Sliding_window'daki de�erler de�i�kenlere atan�r
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
			ArrTmp(4)<=p5;  --P1,p2,...,p9 de�erleri s�ars�yla ArrTmp dizisine atan�r
			ArrTmp(5)<=p6;
			ArrTmp(6)<=p7;
			ArrTmp(7)<=p8;
			ArrTmp(8)<=p9;
			
			
			image(i1,j1)<=find_median(ArrTmp); -- ArrTmp'in medyan de�eri find_median ile bulunur ve g�r�nt� matrisine atan�r
		    
		end loop;
	end loop;
	
		wait for 10 ns;
       
        for i1 in 0 to Row-1 loop
            for j1 in 0 to Col-1 loop
                write(write_col_to_output_buf,image(i1,j1));   -- image matrisindeki de�erler alt alta output_image.txt dosyas�na yaz�l�r
                writeline(output_buf, write_col_to_output_buf); 
            end loop;
        end loop;
         
         wait for 20 ns;
      end loop;
    
      file_close(input_buf);   -- i�lem tamamland�ktan sonra girdi ve ��kt� dosyalar� kapat�l�r.
      file_close(output_buf);
      
      wait;
    
    end process tb;
    
end Behavioral; 





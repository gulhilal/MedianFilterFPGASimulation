library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_textio.all;    -- Dosya iþlemleri için std_logic_textio kütüphanesi eklendi

package MatrixPackage is                                -- Ýki boyutlu matris tanýmlamak için package oluþturuldu.
    type matrix_type is array (natural range <>, natural range <>) of integer range 0 to 255;
end package MatrixPackage;

use work.MatrixPackage.all;
use std.textio.all;

entity read_pixels is
generic(
 Row : integer :=520;       -- Sabit deðerler generic kýsmýnda tanýmlanýr bu deðerler görüntünün boyutlarý ve filtrenin boyutudur.
 Col : integer :=520;
 mask: integer :=3
);

end read_pixels;

architecture Behavioral of read_pixels is
    signal p1,p2,p3,p4,p5,p6,p7,p8,p9 : integer range 0 to 255;   -- 3x3 lük filtre kullanýldýðý için 9 adet integer deðiþken tanýmlanýr
    type ArrArray is array (0 to mask*mask-1) of integer range 0 to 255;   
    signal ArrTmp : ArrArray;       -- 3x3 lük filtrenin elemanlarýný atamak için dizi tanýmlanýr
    signal i1,j1,i2,j2 : integer :=0 ;
    signal image: matrix_type(0 to Row-1,0 to Col-1);  -- giriþ görüntüsünün boyutlarýnda bir matris tanýmlanýr.
   
    signal Sliding_window:matrix_type(0 to mask-1,0 to mask-1);  -- Sliding_window adýnda 3x3 boyutunda matris tanýmlanýr
    
    -- girdiden ve çýktýdan gelen metni depolamak için buffer
    file input_buf : text; 
    file output_buf: text; 
    
    function find_median(arr: ArrArray) return integer is   -- "arr" dizisini alan ve dizinin medyan deðerini döndüren bir fonksiyon tanýmlanýr.
        variable sorted_arr: ArrArray := arr;
        variable temp: integer;
    begin
        -- Diziyi artan düzende sýralamak için basit bubble sort uygulanýr
        for i1 in 0 to mask*mask-1 loop
            for j1 in 0 to mask*mask-2 loop
                if sorted_arr(j1) > sorted_arr(j1 + 1) then
                    temp := sorted_arr(j1);
                    sorted_arr(j1) := sorted_arr(j1 + 1);
                    sorted_arr(j1 + 1) := temp;
                end if;
            end loop;
        end loop;

        -- Sýralanmýþ diziden medyan deðeri döndür
        return sorted_arr(mask+1);
    end function;
 
    
begin

    tb: process
        variable read_col_from_input_buf: line; -- input_buf'tan satýrlarý tek tek oku
        variable write_col_to_output_buf : line; -- output_buf'a satýr satýr yaz
        variable val_col : integer; -- 1 bitlik col deðerini kaydetmek için
        variable val_SPACE: character;  -- dosyadaki veriler arasýndaki boþluklar için
          
    begin
    -- medyan filtre uygulanmýþ görüntünün piksellerini yazmak için output_image.txt dosyasý yazma modunda açýlýr
    file_open(output_buf, "C:\Users\GUL\MezuniyetProjesi\project_18.srcs\sim_1\new\output_image.txt", WRITE_MODE);
    -- matlab'dan alýnmýþ gürültülü görüntünün piksellerinin yazdýðý dosya okuma modunda açýlýr
    file_open(input_buf,"input_image.txt",READ_MODE);
       
    while not endfile(input_buf) loop  -- dosyanýn sonuna gelene kadar devam eden döngü
    for i1 in 0 to Row-1 loop
        for j1 in 0 to Col-1 loop
            readline(input_buf,read_col_from_input_buf);  --dosyadaki piksel deðerler satýr satýr okunur
            read(read_col_from_input_buf,val_col);        -- okunan deðerler image matrisine atanýr
            read(read_col_from_input_buf,val_SPACE);
            image(i1,j1)<=val_col;  
        end loop;
    end loop;
    

    	
    for i1 in 1 to Row-2 loop
		for j1 in 1 to Col-2 loop
		
		    wait for 10 ns;
		
			Sliding_window(0,0) <= image(i1-1,j1-1);   -- Sliding_window karþýlýk gelen piksel deðerleriyle doldurulur medyan deðeri bulmak için 'find_median' iþlevi çaðrýlýr.
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
			p4 <= Sliding_window(1,0) ;   -- Sliding_window'daki deðerler deðiþkenlere atanýr
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
			ArrTmp(4)<=p5;  --P1,p2,...,p9 deðerleri sýarsýyla ArrTmp dizisine atanýr
			ArrTmp(5)<=p6;
			ArrTmp(6)<=p7;
			ArrTmp(7)<=p8;
			ArrTmp(8)<=p9;
			
			
			image(i1,j1)<=find_median(ArrTmp); -- ArrTmp'in medyan deðeri find_median ile bulunur ve görüntü matrisine atanýr
		    
		end loop;
	end loop;
	
		wait for 10 ns;
       
        for i1 in 0 to Row-1 loop
            for j1 in 0 to Col-1 loop
                write(write_col_to_output_buf,image(i1,j1));   -- image matrisindeki deðerler alt alta output_image.txt dosyasýna yazýlýr
                writeline(output_buf, write_col_to_output_buf); 
            end loop;
        end loop;
         
         wait for 20 ns;
      end loop;
    
      file_close(input_buf);   -- iþlem tamamlandýktan sonra girdi ve çýktý dosyalarý kapatýlýr.
      file_close(output_buf);
      
      wait;
    
    end process tb;
    
end Behavioral; 





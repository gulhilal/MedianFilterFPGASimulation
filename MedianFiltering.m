ROW=520;   % The dimensions of the image are defined.
COL=520;
D=520;

result=imread("tiger.jpg");

result=imnoise(result,'salt & pepper',0.08); % Adding salt and pepper noise.

[ylength,xlength]=size(result);                  % The size of the image is obtained using the size function                                                   
output_image(1:ylength,1:xlength/3,1:3)=result;  % and a new matrix is created to store the filtered image.

for r=1:D
    for s=1:D
        M(s,r)=uint8(result(s,r)); % Pixel values in the result are assigned to the M matrix.
    end
end

fid=fopen('file directory','wt'); % The file is opened to write 
for r=1:D                        % the pixel values of the image.
    for s=1:D
        fprintf(fid,'%u\n',M(r,s)); % Pixel values in the M matrix are written to the opened input_image.txt file.
    end
end

subplot(1,3,1),imshow(M);
title('Image with Salt and Pepper Noise');
fclose(fid);


for y=1:ylength
    for x=1:xlength/3-2
        window=result(y,x:(x+2));           % The 3x3 filter that applies to rows is applied to the image.
        sorted_list=sort(window);           % Sort pixels with the 'sort' function.
        output_image(y,x+1)=sorted_list(2); % The outut_image matrix is assigned median values (excluding edge pixels).
    end
end

for r=1:D
    for s=1
        M(s,r)=uint8(output_image(s,r));  % The pixels of the filtered image are assigned to the M matrix.
    end
end

fid=fopen('expected_image.txt file directory','wt');

for r=1:D
    for s=1:D
        fprintf(fid,'%u\n',M(r,s));   % The values in the M matrix are written to the expected_image.txt file one after the other.
    end
end
fclose(fid);

for x=1:xlength/3
    for y=1:ylength-2
        window=output_image(y:(y+2),x);   % Applying a 3x3 filter that applies to columns.
        sorted_list=sort(window);          % Sort pixels with the 'sort' function.
        output_image(y+1,x)=sorted_list(2); % The outut_image matrix is assigned median values (excluding edge pixels).
    end
end

for r=1:D
    for s=1:D
        M(s,r)=uint8(output_image(s,r)); % The pixels of the filtered image are assigned to the M matrix.
    end
end

fid=fopen('matlab_output_image.txt file directory','wt');
for r=1:D
    for s=1:D
        fprintf(fid,'%u\n',M(r,s));  % pixels of image with median filter applied to both dimensions are printed to matlab_output_image.txt
    end                              
end

fclose(fid);

subplot(1,3,2),imshow(M);
title('Output Image (Matlab)');

 
A1=textread('output_image.txt file directory','%u'); % The file containing the pixels 
                                                    % of the median filtered image 
                                                    % from the FPGA simulation is being opened.
k=1;
for r=1:D-4
    for s=1:D
        M1(r,s)=uint8(A1(k));
        k=k+1;
    end
end
subplot(1,3,3),imshow(M1);
title('Output Image (VHDL)');



ROW=520;   % görüntünün boyutları tanımlanıyor.
COL=520;
D=520;

result=imread('C:\Users\GUL\OneDrive\Masaüstü\MatlabMedian\tiger.jpg');

result=imnoise(result,'salt & pepper',0.08); % Tuz-biber gürültüsü ekleniyor.

[ylength,xlength]=size(result);                  % size fonksiyonu kullanılarak görüntünün boyutları elde ediliyor                                                    
output_image(1:ylength,1:xlength/3,1:3)=result;  % ve filtrelenmiş görüntüyü depolamak için yeni bir matris oluşturuluyor.

for r=1:D
    for s=1:D
        M(s,r)=uint8(result(s,r)); % Result'daki piksel değerleri M matrisine atanıyor.
    end
end

fid=fopen('C:\Users\GUL\OneDrive\Masaüstü\MatlabMedian\input_image.txt','wt'); % Görüntünün piksel değerlerinin
for r=1:D                                                                      % yazılması için dosya açılıyor.
    for s=1:D
        fprintf(fid,'%u\n',M(r,s)); % M matrisindeki piksel değerleri açılan input_image.txt dosyasına yazılıyor.
    end
end

subplot(1,3,1),imshow(M);
title('Tuz-Biber Gürültüsü Eklenmiş Görüntü');
fclose(fid);


for y=1:ylength
    for x=1:xlength/3-2
        window=result(y,x:(x+2));           % Görüntüye 3x3'lük ve satırlar için geçerli olan filtre uygulanıyor.
        sorted_list=sort(window);           % 'sort' fonksiyonu ile pikseller sıralanıyor.
        output_image(y,x+1)=sorted_list(2); % outut_image matrisine medyan değerleri atanıyor(kenar pikselleri hariç).
    end
end

for r=1:D
    for s=1
        M(s,r)=uint8(output_image(s,r));  % M matrisine satırları filtrelenmiş görüntünün pikselleri atanıyor.
    end
end

fid=fopen('C:\Users\GUL\OneDrive\Masaüstü\MatlabMedian\expected_image.txt','wt');

for r=1:D
    for s=1:D
        fprintf(fid,'%u\n',M(r,s));   % M matrisindeki değerler alt alta expected_image.txt dosyasına yazılıyor.
    end
end
fclose(fid);

for x=1:xlength/3
    for y=1:ylength-2
        window=output_image(y:(y+2),x);   % Görüntüye 3x3'lük ve sütunlar için geçerli olan filtre uygulanıyor.
        sorted_list=sort(window);          % 'sort' fonksiyonu ile pikseller sıralanıyor.
        output_image(y+1,x)=sorted_list(2); % outut_image matrisine medyan değerleri atanıyor(kenar pikselleri hariç).
    end
end

for r=1:D
    for s=1:D
        M(s,r)=uint8(output_image(s,r)); % M matrisine sütünları filtrelenmiş görüntünün pikselleri atanıyor.
    end
end

fid=fopen('C:\Users\GUL\OneDrive\Masaüstü\MatlabMedian\matlab_output_image.txt','wt');
for r=1:D
    for s=1:D
        fprintf(fid,'%u\n',M(r,s));  % iki boyutuna da medyan filtre uygulanmış 
    end                              % görüntünün pikselleri matlab_output_image.txt'ye yazdırılıyor
end

fclose(fid);

subplot(1,3,2),imshow(M);
title('Çıkış Görünütüsü(Matlab)');

 
A1=textread('C:/Users/GUL/MezuniyetProjesi/project_18.srcs/sim_1/new/output_image.txt','%u'); % The file containing the pixels 
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
title('Çıkış Görünütüsü(VHDL)');



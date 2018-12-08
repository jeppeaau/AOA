function data=bin2complex(f)
% Reads the specified file and returns the
% data it contains as complex64 numbers

if f~=-1
    raw_byte=fread(f,inf,'float32');
    
    odd_real=1:2:length(raw_byte);
    even_imag=2:2:length(raw_byte);
    
    data=raw_byte(odd_real)+1i*raw_byte(even_imag);
else
    data=[];
end

end
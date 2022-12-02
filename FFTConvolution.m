%%This script implements a function that takes two time domain audio
%%sequences as input and computes their convolution in the frequency domain

function output = FFTConvolution(in1, in2)

    n1 = length(in1);
    n2 = length(in2);
    
    if n1*n2 < (n1+n2-1) * (3 * log2(n1+n2-1)+1)
        output = conv(in1,in2);
    else
        %frequency domain convolution
        x1 = fft(in1,n1+n2-1);
        x2 = fft(in2, n1+n2-1);
        
        y = x1 .* x2;
        
        if(isreal(in1) && isreal(in2))
            output = real(ifft(y));
        else
            output = ifft(y);
        end
    end
end
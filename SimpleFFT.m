function [ Freq,Magnitude ] = SimpleFFT(Signal, SampleFreq)
%SimpleFFT This is a quick Function To Calculate FFT 
%   This function was created to simplify code for FFT analysis, based upon
%   the matlab fft example line by line. 
        
        Fs = SampleFreq;              % Sampling frequency (hz)
        T = 1/Fs;                     % Sample time
        L = length(Signal);           % Length of signal
        t = (0:L-1)*T;                % Time vector
        y = Signal;     % Sinusoids plus noise

        
        NFFT = 2^nextpow2(L); % Next power of 2 from length of y
        Y = fft(y,NFFT)/L;
        f = Fs/2*linspace(0,1,NFFT/2+1);
        Freq = f;
        Magnitude = 2*abs(Y(1:NFFT/2+1));
end


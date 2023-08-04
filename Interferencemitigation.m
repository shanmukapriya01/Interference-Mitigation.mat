% OFDM parameters
N = 64;                % Number of subcarriers
CP = 16;               % Cyclic prefix length
numSymbols = 1000;     % Number of OFDM symbols
SNR_dB = 20;           % Signal-to-Noise Ratio (in dB)

% Generate random QAM symbols for the desired signal
desiredSymbols = qammod(randi([0 3], N, numSymbols), 4);

% Generate random interferer symbols
interfererSymbols = qammod(randi([0 3], N, numSymbols), 4);

% Generate random channel impulse response
channel = complex(randn(N, 1), randn(N, 1));

% Apply channel to desired signal and interferer
desiredSignal = ifft(channel .* fft(desiredSymbols));
interfererSignal = ifft(channel .* fft(interfererSymbols));

% Add AWGN to the received signal
noisePower = 10^(-SNR_dB/10);
noiseMatrix = sqrt(noisePower/2)*(randn(N, numSymbols)+1i*randn(N, numSymbols));
receivedSignal = desiredSignal + interfererSignal + repmat(noiseMatrix, 1, 1);

% Frequency Domain Equalization (FDE)
equalizedSignal = zeros(N, numSymbols);
for sym = 1:numSymbols
    receivedSymbols = fft(receivedSignal(:, sym));
    equalizedSignal(:, sym) = receivedSymbols ./ fft(channel);
end

% Demodulate the equalized symbols
demodulatedSymbols = qamdemod(equalizedSignal, 4);

% Calculate Bit Error Rate (BER)
ber = sum(sum(demodulatedSymbols ~= desiredSymbols)) / (N * numSymbols * log2(4));

% Calculate Signal-to-Interference-plus-Noise Ratio (SINR)
interference = sum(abs(interfererSignal).^2, 1);
noisePowerTotal = noisePower * N;
sinr = 10*log10(sum(abs(desiredSignal).^2, 1) ./ (interference + noisePowerTotal));

% Display results
fprintf('Bit Error Rate (BER): %.4f\n', ber);
fprintf('Signal-to-Interference-plus-Noise Ratio (SINR): %.2f dB\n', mean(sinr));

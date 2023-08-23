% Simulation parameters
numBits = 10000;         % Number of bits to transmit (change accordingly)
SNRdB = 0:2:20;          % Range of SNR values in dB (change accordingly)
SNR = 10.^(SNRdB/10);    % Convert SNR values from dB to linear scale
modulationSchemes = {'BPSK', 'QPSK', '16-QAM'};
numModulations = length(modulationSchemes);
numSNR = length(SNR);

% Initialize BER arrays to store results
BER = zeros(numModulations, numSNR);

% Iterate through each modulation scheme
for modulationIndex = 1:numModulations
    modulation = modulationSchemes{modulationIndex};
    
    % Iterate through each SNR value
    for snrIndex = 1:numSNR
        % Generate random bits for transmission
        bits = randi([0 1], 1, numBits);
        
        % Modulation process based on the selected scheme
        if strcmp(modulation, 'BPSK')
            modulatedSignal = 2 * bits - 1;
        elseif strcmp(modulation, 'QPSK')
            bitsInSymbols = reshape(bits, 2, []);
            modulatedSignal = (1 - 2 * bitsInSymbols(1,:)) + 1i * (1 - 2 * bitsInSymbols(2,:));
        elseif strcmp(modulation, '16-QAM')
            bitsInSymbols = reshape(bits, 4, []);
            constellation = [-3 -1 1 3];
            realPart = constellation(bitsInSymbols(1,:) * 2 + bitsInSymbols(2,:) + 1);
            imagPart = constellation(bitsInSymbols(3,:) * 2 + bitsInSymbols(4,:) + 1);
            modulatedSignal = realPart + 1i * imagPart;
        end
        
        % Introduce AWGN channel noise
        receivedSignal = awgn(modulatedSignal, SNRdB(snrIndex));
        
        % Demodulation and BER calculation
        if strcmp(modulation, 'BPSK')
            demodulatedBits = receivedSignal > 0;
        elseif strcmp(modulation, 'QPSK')
            demodulatedBits = [real(receivedSignal) > 0; imag(receivedSignal) > 0];
            demodulatedBits = demodulatedBits(:)';
        elseif strcmp(modulation, '16-QAM')
            % Add demodulation logic for 16-QAM here if needed
        end
        
        % Calculate and store Bit Error Rate (BER)
        bitErrors = sum(bits ~= demodulatedBits);
        BER(modulationIndex, snrIndex) = bitErrors / numBits;
    end
end

% Plot BER curves for different modulation schemes
figure;
for modulationIndex = 1:numModulations
    semilogy(SNRdB, BER(modulationIndex, :), '-o', 'DisplayName', modulationSchemes{modulationIndex});
    hold on;
end
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Bit Error Rate (BER) vs SNR for Different Modulation Schemes');
legend('Location', 'best');

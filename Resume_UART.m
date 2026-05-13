clc;
clear;
close all;

%% =========================================================
%%          UART COMMUNICATION PROTOCOL SIMULATION
%% =========================================================

%% ================= UART PARAMETERS =================
baud_rate = 9600;              % Baud rate
data_bits = 8;                 % Number of data bits
stop_bits = 1;                 % Stop bits
parity_enable = 1;             % 1 = Enable parity

%% ================= SIMULATION PARAMETERS =================
N = 1000;                      % Number of transmitted frames
SNR_dB = 0:2:20;               % SNR range

%% ================= PREALLOCATIONS =================
BER = zeros(size(SNR_dB));
Throughput = zeros(size(SNR_dB));

%% =========================================================
%%                  MAIN SIMULATION
%% =========================================================

for i = 1:length(SNR_dB)

    snr_linear = 10^(SNR_dB(i)/10);

    total_errors = 0;
    total_bits = 0;

    successful_frames = 0;

    %% ==============================================
    %%          TRANSMIT MULTIPLE FRAMES
    %% ==============================================

    for frame = 1:N

        %% ------------------------------------------
        %%          GENERATE RANDOM DATA
        %% ------------------------------------------

        tx_data = randi([0 1], 1, data_bits);

        %% ------------------------------------------
        %%          PARITY BIT GENERATION
        %% ------------------------------------------

        if parity_enable == 1

            parity_bit = mod(sum(tx_data),2);

        else

            parity_bit = [];

        end

        %% ------------------------------------------
        %%          UART FRAME FORMAT
        %% ------------------------------------------
        % Start Bit = 0
        % Data Bits
        % Parity Bit
        % Stop Bit = 1

        uart_frame = [0 tx_data parity_bit ones(1,stop_bits)];

        %% ------------------------------------------
        %%          BPSK MODULATION
        %% ------------------------------------------

        tx_signal = 2*uart_frame - 1;

        %% ------------------------------------------
        %%              AWGN CHANNEL
        %% ------------------------------------------

        noise_sigma = sqrt(1/(2*snr_linear));

        noise = noise_sigma * randn(size(tx_signal));

        rx_signal = tx_signal + noise;

        %% ------------------------------------------
        %%          RECEIVER DETECTION
        %% ------------------------------------------

        rx_bits = rx_signal > 0;

        %% ------------------------------------------
        %%          EXTRACT UART FRAME
        %% ------------------------------------------

        rx_start = rx_bits(1);

        rx_data = rx_bits(2:data_bits+1);

        if parity_enable == 1

            rx_parity = rx_bits(data_bits+2);

        end

        rx_stop = rx_bits(end);

        %% ------------------------------------------
        %%          PARITY CHECK
        %% ------------------------------------------

        parity_error = 0;

        if parity_enable == 1

            calculated_parity = mod(sum(rx_data),2);

            if calculated_parity ~= rx_parity

                parity_error = 1;

            end

        end

        %% ------------------------------------------
        %%          FRAME VALIDATION
        %% ------------------------------------------

        if rx_start == 0 && rx_stop == 1 && parity_error == 0

            successful_frames = successful_frames + 1;

        end

        %% ------------------------------------------
        %%              BER CALCULATION
        %% ------------------------------------------

        bit_errors = sum(tx_data ~= rx_data);

        total_errors = total_errors + bit_errors;

        total_bits = total_bits + data_bits;

    end

    %% ==============================================
    %%          PERFORMANCE METRICS
    %% ==============================================

    BER(i) = total_errors / total_bits;

    Throughput(i) = ...
        successful_frames / N;

end

%% =========================================================
%%                  BER PLOT
%% =========================================================

figure;

semilogy(SNR_dB, BER, 'b-o', ...
    'LineWidth',2);

grid on;

xlabel('SNR (dB)', ...
    'FontWeight','bold');

ylabel('Bit Error Rate (BER)', ...
    'FontWeight','bold');

title('BER vs SNR for UART Communication System', ...
    'FontWeight','bold');

set(gca,'FontSize',12);

%% =========================================================
%%              THROUGHPUT PLOT
%% =========================================================

figure;

plot(SNR_dB, Throughput, 'r-s', ...
    'LineWidth',2);

grid on;

xlabel('SNR (dB)', ...
    'FontWeight','bold');

ylabel('Successful Frame Ratio', ...
    'FontWeight','bold');

title('Throughput vs SNR for UART Communication System', ...
    'FontWeight','bold');

set(gca,'FontSize',12);

%% =========================================================
%%              DISPLAY UART FRAME FORMAT
%% =========================================================

disp(' ');
disp('===========================================');
disp('UART FRAME FORMAT');
disp('===========================================');
disp('[ Start Bit | Data Bits | Parity | Stop ]');
disp('===========================================');

%% =========================================================
%%                  DISPLAY SUMMARY
%% =========================================================

fprintf('\n============================================\n');
fprintf('UART PROTOCOL SIMULATION COMPLETED\n');
fprintf('============================================\n');

fprintf('FEATURES INCLUDED:\n');
fprintf('1. UART Frame Generation\n');
fprintf('2. Start and Stop Bit Detection\n');
fprintf('3. Parity Bit Error Checking\n');
fprintf('4. AWGN Channel Modeling\n');
fprintf('5. BER Analysis\n');
fprintf('6. Throughput Analysis\n');
fprintf('7. Monte Carlo Simulation\n');
fprintf('8. BPSK-Based Transmission\n');

fprintf('============================================\n');
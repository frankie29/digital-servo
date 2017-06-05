% Plot a transfer function using the data generated by the measure transfer function command.
% The amplitude is in arbitrary units.

% inputs
clear;

dname = 'C:\data\SuperLaserLand\'; % directory that the data is saved in
timestamp = '20121211_112613'; % timestamp (should be a folder in the above directory)

chan = 1; % plot the transfer function from the transfer function modulation to this ADC channel, counted starting from 1
adcRange = [4 1]; % input range settings for the two ADC channels (4 means +/- 4 V input range)

% make a list of the file names and modulation frequencies
directory = dir([dname timestamp]);

index = 0;
fname = {};
for i = 1:length(directory)
    if not(isempty(strfind(directory(i).name, '.dat')))
        index = index + 1;
        fname{index} = directory(i).name;
        modulationFrequency(index) = str2num(strrep(fname{index}(1:end-4), '_', '.'));
    end
end

% loop through the files and calculate the transfer function
for index = 1:length(fname)
    fprintf('Modulation frequency = %f Hz, ', modulationFrequency(index));
    data = readSuperLaserLandSimplePI([dname timestamp '\' fname{index}]);

    % scale the data
    for i = 1:size(data.adc, 1)
        data.adc(i,:) = 2*adcRange(i)/2^16*data.adc(i,:); % [V]
    end
    
    % calculate the transfer function
    i1 = 1;
    i2 = max(find(data.time <= data.time(i1) + floor((data.time(end) - data.time(i1))*modulationFrequency(index))/modulationFrequency(index))); % use an integer number of periods of the modulation
    transferFunction(index) = (2/(data.time(i2) - data.time(i1)))*trapz(data.time(i1:i2), (data.modSin(i1:i2) + sqrt(-1)*data.modCos(i1:i2)).*data.adc(chan,i1:i2));
    fprintf('transfer function = %f\n', transferFunction(index));
end

% plot the transfer function
figure(1);
subplot(2, 1, 1);
loglog(modulationFrequency, abs(transferFunction), 'o');
ylabel('Magnitude');
title([strrep(timestamp, '_', '\_') ', modulation -> ADC' num2str(chan - 1) ' transfer function']);

subplot(2, 1, 2);
semilogx(modulationFrequency, unwrap(angle(transferFunction))*360/(2*pi), 'o');
xlabel('Frequency [Hz]');
ylabel('Phase [deg]');

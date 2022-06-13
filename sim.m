%
% Simulador de cobertura para GSM Rural
% 
% Comunicações Móveis 2021-22
% João Silva
% N. 2191733
%

clear all;
close all;
clc;

%% Config
RUN_CALCULATIONS = 0; % If disabled will import data from prop_data.mat
PROPAGATION_MODEL = 0; % 0 = Longley Rice, 1 = Free Space, 2 = Okumura-Hata
SHOW_CELL_RADIATION_PATTERN = 0;
SHOW_SNIR = 1;
SHOW_RX_POWER = 1;
SHOW_BEST_SERVER_BY_SNIR = 1;
SHOW_BEST_SERVER_BY_POWER = 1;
SHOW_CAPACITY = 1;
SHOW_LOS = 1;
SHOW_HANDOVER = 1;
EXPORT_KML = 1;
EXPORT_SUMMARY = 1;

%% Calculation config
calcResolution = 100; % meters
calcRadialResFactor = 2; % radians

%% Technology data (GSM)
fBase = 935e6; % Hz
cSpacing = 200e3; % Hz
nChannels = 125;
nCircuits = 8; % Circuits per channel
rxSens = -102; % dBm
rxNoiseFigure = 7; % dB
rxGain = 2; % dBi
rxHeight = 1.5; % meter
minSnir = 9; % dB

%% Channel Frequency
fc = (0 : 1 : (nChannels - 1)) * cSpacing + fBase;

%% RX
rxNames = ["Center", "Top Right", "Top Left", "Bottom Right", "Bottom Left"];
rxLats = [42.036910, 42.104323, 42.104323, 41.969425, 41.969425];
rxLons = [-8.500895, -8.409984, -8.591806, -8.591613, -8.410177];
srxCount = 31;
srxLats = linspace(min(rxLats), max(rxLats), srxCount);
srxLons = linspace(min(rxLons), max(rxLons), srxCount);

rxs = rxsite(...
    "Name", rxNames, ...
    "Latitude", rxLats, ...
    "Longitude", rxLons, ...
    "Antenna", design(dipole, fBase), ...
    "ReceiverSensitivity", rxSens);

%% TX
txNames = [
    "9", ...
    "10", ...
    "11", ...
    "13", ...
    "1a", "1b", "1c" ...
    "2a", "2b", "2c" ...
    "3a", "3b", "3c" ...
    "4a", "4b", "4c", ...
    "5a", "5b", "5c", ...
    "6a", "6b", "6c", ...
    "7a", "7b", "7c", ...
    "8a", "8b", "8c", ...
];
txLats = [42.068856, 42.061157, 42.077441, 42.059097, 42.046738, 42.046738, 42.046738, 42.027433, 42.027433, 42.027433, 41.982544, 41.982544, 41.982544, 41.972541, 41.972541, 41.972541, 42.098816, 42.098816, 42.098816, 42.091744, 42.091744, 42.091744, 42.064172, 42.064172, 42.064172, 42.032382, 42.032382, 42.032382];
txLons = [-8.486488, -8.507538, -8.477855, -8.519211, -8.578262, -8.578262, -8.578262, -8.493118, -8.493118, -8.493118, -8.557477, -8.557477, -8.557477, -8.432130, -8.432130, -8.432130, -8.557693, -8.557693, -8.557693, -8.464898, -8.464898, -8.464898, -8.499533, -8.499533, -8.499533, -8.424882, -8.424882, -8.424882];
txHeights = [5, 5, 5, 5, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30];
txChannels = [12, 13, 14, 15, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
txNumChannels = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2];
txFreqs = fc(txChannels + 1);
txAntennas = {...
    design(dipole, txFreqs(1)), ...
    design(dipole, txFreqs(2)), ...
    design(dipole, txFreqs(3)), ...
    design(dipole, txFreqs(4)), ...
    design(hornConical, txFreqs(5)), ...
    design(hornConical, txFreqs(6)), ...
    design(hornConical, txFreqs(7)), ...
    design(hornConical, txFreqs(8)), ...
    design(hornConical, txFreqs(9)), ...
    design(hornConical, txFreqs(10)), ...
    design(hornConical, txFreqs(11)), ...
    design(hornConical, txFreqs(12)), ...
    design(hornConical, txFreqs(13)), ...
    design(hornConical, txFreqs(14)), ...
    design(hornConical, txFreqs(15)), ...
    design(hornConical, txFreqs(16)), ...
    design(hornConical, txFreqs(17)), ...
    design(hornConical, txFreqs(18)), ...
    design(hornConical, txFreqs(19)), ...
    design(hornConical, txFreqs(20)), ...
    design(hornConical, txFreqs(21)), ...
    design(hornConical, txFreqs(22)), ...
    design(hornConical, txFreqs(23)), ...
    design(hornConical, txFreqs(24)), ...
    design(hornConical, txFreqs(25)), ...
    design(hornConical, txFreqs(26)), ...
    design(hornConical, txFreqs(27)), ...
    design(hornConical, txFreqs(28)), ...
};
txAntennaAngles = [0, 0, 0, 0, 60, 180, 300, 60, 180, 300, 60, 180, 300, 60, 180, 300, 60, 180, 300, 60, 180, 300, 60, 180, 300, 60, 180, 300];
txPowers = [0.5, 0.5, 0.5, 0.5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2];

txAntennas{1, 1}.Tilt = 0;
txAntennas{1, 1}.TiltAxis = "y";
txAntennas{1, 2}.Tilt = 0;
txAntennas{1, 2}.TiltAxis = "y";
txAntennas{1, 3}.Tilt = 0;
txAntennas{1, 3}.TiltAxis = "y";
txAntennas{1, 4}.Tilt = 0;
txAntennas{1, 4}.TiltAxis = "y";
txAntennas{1, 5}.Tilt = 10;
txAntennas{1, 5}.TiltAxis = "x";
txAntennas{1, 6}.Tilt = 10;
txAntennas{1, 6}.TiltAxis = "x";
txAntennas{1, 7}.Tilt = 10;
txAntennas{1, 7}.TiltAxis = "x";
txAntennas{1, 8}.Tilt = 10;
txAntennas{1, 8}.TiltAxis = "x";
txAntennas{1, 9}.Tilt = 10;
txAntennas{1, 9}.TiltAxis = "x";
txAntennas{1, 10}.Tilt = 10;
txAntennas{1, 10}.TiltAxis = "x";
txAntennas{1, 11}.Tilt = 10;
txAntennas{1, 11}.TiltAxis = "x";
txAntennas{1, 12}.Tilt = 10;
txAntennas{1, 12}.TiltAxis = "x";
txAntennas{1, 13}.Tilt = 10;
txAntennas{1, 13}.TiltAxis = "x";
txAntennas{1, 14}.Tilt = 10;
txAntennas{1, 14}.TiltAxis = "x";
txAntennas{1, 15}.Tilt = 10;
txAntennas{1, 15}.TiltAxis = "x";
txAntennas{1, 16}.Tilt = 10;
txAntennas{1, 16}.TiltAxis = "x";
txAntennas{1, 17}.Tilt = 10;
txAntennas{1, 17}.TiltAxis = "x";
txAntennas{1, 18}.Tilt = 10;
txAntennas{1, 18}.TiltAxis = "x";
txAntennas{1, 19}.Tilt = 10;
txAntennas{1, 19}.TiltAxis = "x";
txAntennas{1, 20}.Tilt = 10;
txAntennas{1, 20}.TiltAxis = "x";
txAntennas{1, 21}.Tilt = 10;
txAntennas{1, 21}.TiltAxis = "x";
txAntennas{1, 22}.Tilt = 10;
txAntennas{1, 22}.TiltAxis = "x";
txAntennas{1, 23}.Tilt = 10;
txAntennas{1, 23}.TiltAxis = "x";
txAntennas{1, 24}.Tilt = 10;
txAntennas{1, 24}.TiltAxis = "x";
txAntennas{1, 25}.Tilt = 10;
txAntennas{1, 25}.TiltAxis = "x";
txAntennas{1, 26}.Tilt = 10;
txAntennas{1, 26}.TiltAxis = "x";
txAntennas{1, 27}.Tilt = 10;
txAntennas{1, 27}.TiltAxis = "x";
txAntennas{1, 28}.Tilt = 10;
txAntennas{1, 28}.TiltAxis = "x";

txs = txsite(...
    "Name", txNames, ...
    "Latitude", txLats, ...
    "Longitude", txLons, ...
    "Antenna", txAntennas, ...
    "AntennaAngle", txAntennaAngles, ...
    "AntennaHeight", txHeights, ...
    "TransmitterFrequency", txFreqs, ...
    "TransmitterPower", txPowers);

%% Transmitter sites w/ antennas
if SHOW_CELL_RADIATION_PATTERN == 1
    aViewer = siteviewer;
    aViewer.Basemap = "topographic";

    show(rxs);
    show(txs);
  
    for i = 1:length(txs)
        pattern(txs(i));
    end
end

%% Compute signal power for all stations
if RUN_CALCULATIONS == 1
    cpViewer = siteviewer("Basemap", "topographic");
    
    % Determine the range required for each TX station to reach the
    % most distant point in the coverage zone
    txRanges = [];

    for i = 1:length(txs)
        tx_i = txs(i);

        p1 = [tx_i.Latitude tx_i.Longitude];

        txRanges = [txRanges 0];

        for j = 1:length(rxLats)
           p2 = [rxLats(j) rxLons(j)];

           [d1, d2] = lldistkm(p1, p2);

           d1 = d1 * 1e3;
           d2 = d2 * 1e3;

           txRanges(i) = max([txRanges(i) d1 d2]);
        end
    end

    if PROPAGATION_MODEL == 0
        pModel = rfprop.LongleyRice;
    elseif PROPAGATION_MODEL == 1
        pModel = rfprop.FreeSpace;
    elseif PROPAGATION_MODEL == 2
        pModel = OkumuraHata;
    end
    coverage
    % There are two additional parameters for the
    % radialReceiverLocationsLayoutData function in 2021a
    if version('-release') == "2021a"
        tic
        [sslats, sslons, ~, ss] = radialReceiverLocationsLayoutData(...
            txs, rfprop.internal.AntennaSiteCoordinates.createFromAntennaSites(txs, cpViewer), 'power', ...
            '', '', pModel, cpViewer, calcResolution, calcRadialResFactor, txRanges, ...
            min(rxLons), max(rxLons), min(rxLats), max(rxLats), rxGain, rxHeight);
        toc
    else
        tic
        [sslats, sslons, ~, ss] = radialReceiverLocationsLayoutData(...
            txs, rfprop.internal.AntennaSiteCoordinates.createFromAntennaSites(txs, cpViewer), 'power', ...
            pModel, cpViewer, calcResolution, calcRadialResFactor, txRanges, ...
            min(rxLons), max(rxLons), min(rxLats), max(rxLats), rxGain, rxHeight);
        toc
    end

    close(cpViewer);
    
    save("out/prop_data.mat", "ss", "sslats", "sslons");
elseif isfile("out/prop_data.mat")
    load("out/prop_data.mat");
else
    error("RUN_CALCULATIONS is set to 0 and no previously computed data file was found!");
end

%% Compute KPIs
sssz = size(ss);
pwrData = [];
snirData = [];
bsPwrData = [];
bsSnirData = [];
capData = [];
lats = [];
lons = [];

srxPwr = ones(srxCount, 1) * -Inf;
srxSnir = ones(srxCount, 1) * 0;
srxBsPwr = ones(srxCount, 1) * 0;
srxBsSnir = ones(srxCount, 1) * 0;
srxCap = ones(srxCount, 1) * 0;

TSys = 290; % Kelvin
Boltzmann_K = 1.380649e-23;
noisePwrDensity = 10 * log10(Boltzmann_K * TSys) + 30;

tic
for i = 1:sssz(2)
    ssPoint = ss(:, i);

    if sum(isnan(ssPoint)) > 0
        continue;
    end
    
    rxPwr = [];
    snir = [];
    cAvailable = 0;
    uFreqs = unique(txFreqs);

    for j = 1:length(uFreqs)
        fPoint = uFreqs(j);
        fPwr = ssPoint(txFreqs == fPoint);

        % Received power is the maximum of all cells
        % Best server by strongest RSSI
        sigPwr = max(fPwr);
        sigPwrLin = 10 .^ (sigPwr / 10);
        
        % Sum all powers from cells in the same channel, subtract the power
        % of the serving cell
        interfPwrLin = sum(10 .^ (fPwr / 10)) - sigPwrLin;
        noisePwrLin = 10 ^ ((noisePwrDensity + 10 * log10(cSpacing) + rxNoiseFigure) / 10);
        snirLin = sigPwrLin / (interfPwrLin + noisePwrLin);
        snirdB = 10 * log10(snirLin);
        
        if(sigPwr >= rxSens && snirdB >= minSnir)
            cAvailable = cAvailable + nCircuits * txNumChannels(ssPoint == sigPwr);
        end
        
        rxPwr = [rxPwr sigPwr];
        snir = [snir snirdB];
    end
    
    maxRxPwr = max(rxPwr);
    maxSnir = max(snir);
    
    bsPwrIdx = find(ssPoint == maxRxPwr);
    bsSnirIdx = find(ssPoint == rxPwr(snir == maxSnir));
    
    if cAvailable < 1
        bsPwrIdx = 0;
        bsSnirIdx = 0;
    end

    pwrData = [pwrData maxRxPwr];
    snirData = [snirData maxSnir];
    bsPwrData = [bsPwrData bsPwrIdx];
    bsSnirData = [bsSnirData bsSnirIdx];
    capData = [capData cAvailable];
    lats = [lats sslats(i)];
    lons = [lons sslons(i)];
    
    if i < 2
        continue;
    end
    
    for j = 1:srxCount
        if srxLats(j) >= lats(i - 1) && srxLats(j) < lats(i)
            if srxLons(j) >= lons(i - 1) && srxLons(j) < lons(i)
                srxPwr(j) = maxRxPwr;
                srxSnir(j) = maxSnir;
                srxBsPwr(j) = bsPwrIdx;
                srxBsSnir(j) = bsSnirIdx;
                srxCap(j) = cAvailable;
                
                break;
            end
        end
    end
end
toc

%% Best server
bsColorMap = [...
    000 120 000
    120 000 000
    000 000 120
    089 035 033
    040 114 051
    245 064 033
    132 195 190
    222 076 138
    150 153 146
    234 137 154
    077 086 069
    087 166 057
    006 057 113
    052 235 201
    255 255 255
    185 155 250
    099 255 071
    179 128 075
    097 000 097
    057 093 102
    252 186 003
    255 000 238
    255 000 013
    013 000 255
    000 255 123
    255 255 000
    144 000 255
    004 064 000
    ] / 255;
bsColorLimits = [1, length(txs)];

if SHOW_BEST_SERVER_BY_SNIR == 1
    bsSnirPd = propagationData(lats, lons, ...
        'Name', 'Best server by SNIR', ...
        'BestServer', bsSnirData(:));
    
    bsSnirViewer = siteviewer("Basemap", "topographic");
    show(rxs);
    show(txs);
    contour(bsSnirPd, ...
        'ColorLimits', bsColorLimits, ...
        'Colormap', bsColorMap, ...
        'Transparency', 0.5);
end

if SHOW_BEST_SERVER_BY_POWER == 1
    bsPwrPd = propagationData(lats, lons, ...
        'Name', 'Best server by RX Power', ...
        'BestServer', bsPwrData(:));
    
    bsPwrViewer = siteviewer("Basemap", "topographic");
    show(rxs);
    show(txs);
    contour(bsPwrPd, ...
        'ColorLimits', bsColorLimits, ...
        'Colormap', bsColorMap, ...
        'Transparency', 0.5);
end

%% SNIR
sValues = minSnir:1:40;
sColorMap = [linspace(-1, 0, length(sValues))' * -1, linspace(0, 1, length(sValues))', zeros(length(sValues), 1)];
sColorLimits = [minSnir, 40];
    
if SHOW_SNIR == 1
    sPd = propagationData(lats, lons, ...
        'Name', 'SNIR', ...
        'SNIR', snirData(:));
    
    sViewer = siteviewer("Basemap", "topographic");
    show(rxs);
    show(txs);
    contour(sPd, ...
        'Type', 'sinr', ...
        'ColorLimits', sColorLimits, ...
        'Colormap', sColorMap, ...
        'Levels', sValues, ...
        'Transparency', 0.5);
end

%% Received signal
pValues = rxSens:3:-50;
pColorMap = [linspace(-1, 0, length(pValues))' * -1, linspace(0, 1, length(pValues))', zeros(length(pValues), 1)];
pColorLimits = [rxSens, -50];
    
if SHOW_RX_POWER == 1
    pPd = propagationData(lats, lons, ...
        'Name', 'RX Power', ...
        'RXPower', pwrData(:));
    
    pViewer = siteviewer("Basemap", "topographic");
    show(rxs);
    show(txs);
    contour(pPd, ...
        'Type', 'power', ...
        'ColorLimits', pColorLimits, ...
        'Colormap', pColorMap, ...
        'Levels', pValues, ...
        'Transparency', 0.5);
end

%% Capacity
cValues = [nCircuits:nCircuits:max(capData)];
cColorMap = [linspace(0, 1, length(cValues))', linspace(-1, 0, length(cValues))' * -1, linspace(-1, 0, length(cValues))' * -1];
cColorLimits = [nCircuits, max(capData)];
    
if SHOW_RX_POWER == 1
    cPd = propagationData(lats, lons, ...
        'Name', 'Cpacity', ...
        'Capacity', capData(:));
    
    cViewer = siteviewer("Basemap", "topographic");
    show(rxs);
    show(txs);
    contour(cPd, ...
        'ColorLimits', cColorLimits, ...
        'Colormap', cColorMap, ...
        'Transparency', 0.5);
end

%% Line of Sight
if SHOW_LOS == 1
    lViewer = siteviewer("Basemap", "topographic");
    show(rxs);
    show(txs);
    
    for i = 1:length(txs)
        for j = 1:length(txs)
            if i == j
                continue;
            end
            
            los(txs(i), txs(j));
        end
    end
end

%% Handover
if SHOW_HANDOVER == 1
    hx = 1:1:srxCount;
    
    figure("Name", "Handover data");
    
    subplot(5, 1, 1);
    plot(hx, srxPwr);
    axis([1 srxCount -Inf Inf]);
    ylabel("RSSI (dBm)");
    title("Handover performance");
    
    subplot(5, 1, 2);
    plot(hx, srxSnir);
    axis([1 srxCount -Inf Inf]);
    ylabel("SNIR (dB)");
    
    subplot(5, 1, 3);
    plot(hx, srxBsPwr);
    axis([1 srxCount -Inf Inf]);
    ylabel("Best Server (RSSI)");
    
    subplot(5, 1, 4);
    plot(hx, srxBsSnir);
    axis([1 srxCount -Inf Inf]);
    ylabel("Best Server (SNIR)");
    
    subplot(5, 1, 5);
    plot(hx, srxCap);
    axis([1 srxCount -Inf Inf]);
    ylabel("Capacity (circ.)");
end

%% Export to KML
if EXPORT_KML == 1
    kml_n_cols = sum(sslats == sslats(1));
    kml_n_lines = sum(sslons == sslons(1));

    % RX Power
    kml_data = reshape(pwrData, kml_n_lines, kml_n_cols);
    
    kml_r = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_g = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_b = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_a = ones(kml_n_lines, kml_n_cols) * 0.7;
    
    for i = 1:length(pValues)
        if i < length(pValues)
            kml_pwr_max = pValues(i + 1);
        else
            kml_pwr_max = Inf;
        end
        
        kml_pwr_min = pValues(i);

        kml_r(kml_data < kml_pwr_max & kml_data >= kml_pwr_min) = uint8(pColorMap(i, 1) * 255);
        kml_g(kml_data < kml_pwr_max & kml_data >= kml_pwr_min) = uint8(pColorMap(i, 2) * 255);
        kml_b(kml_data < kml_pwr_max & kml_data >= kml_pwr_min) = uint8(pColorMap(i, 3) * 255);
    end
    
    kml_img(:, :, 1) = kml_r;
    kml_img(:, :, 2) = kml_g;
    kml_img(:, :, 3) = kml_b;
    
    kml_a(kml_r == 0 & kml_g == 0 & kml_b == 0) = 0;
    
    imwrite(kml_img, "out/kml/sim_pwr.png", 'Alpha', kml_a);
    imwrite(make_legend(pValues, "dBm", pColorMap * 255, 80, 30), "out/kml/pwr_legend.png");
    
    % Best server by RX Power
    kml_data = reshape(bsPwrData, kml_n_lines, kml_n_cols);
    
    kml_r = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_g = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_b = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_a = ones(kml_n_lines, kml_n_cols) * 0.7;
    
    for i = 1:length(txs)
        kml_r(kml_data == i) = uint8(bsColorMap(i, 1) * 255);
        kml_g(kml_data == i) = uint8(bsColorMap(i, 2) * 255);
        kml_b(kml_data == i) = uint8(bsColorMap(i, 3) * 255);
    end
    
    kml_img(:, :, 1) = kml_r;
    kml_img(:, :, 2) = kml_g;
    kml_img(:, :, 3) = kml_b;
    
    kml_a(kml_r == 0 & kml_g == 0 & kml_b == 0) = 0;
    
    imwrite(kml_img, "out/kml/sim_best_server_by_pwr.png", 'Alpha', kml_a);
    
    % Best server by SNIR
    kml_data = reshape(bsSnirData, kml_n_lines, kml_n_cols);
    
    kml_r = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_g = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_b = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_a = ones(kml_n_lines, kml_n_cols) * 0.7;
    
    for i = 1:length(txs)
        kml_r(kml_data == i) = uint8(bsColorMap(i, 1) * 255);
        kml_g(kml_data == i) = uint8(bsColorMap(i, 2) * 255);
        kml_b(kml_data == i) = uint8(bsColorMap(i, 3) * 255);
    end
    
    kml_img(:, :, 1) = kml_r;
    kml_img(:, :, 2) = kml_g;
    kml_img(:, :, 3) = kml_b;
    
    kml_a(kml_r == 0 & kml_g == 0 & kml_b == 0) = 0;
    
    imwrite(kml_img, "out/kml/sim_best_server_by_snir.png", 'Alpha', kml_a);
    
    % SNIR
    kml_data = reshape(snirData, kml_n_lines, kml_n_cols);
    
    kml_r = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_g = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_b = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_a = ones(kml_n_lines, kml_n_cols) * 0.7;
    
    for i = 1:length(sValues)
        if i < length(sValues)
            kml_snir_max = sValues(i + 1);
        else
            kml_snir_max = Inf;
        end
        
        kml_snir_min = sValues(i);

        kml_r(kml_data < kml_snir_max & kml_data >= kml_snir_min) = uint8(sColorMap(i, 1) * 255);
        kml_g(kml_data < kml_snir_max & kml_data >= kml_snir_min) = uint8(sColorMap(i, 2) * 255);
        kml_b(kml_data < kml_snir_max & kml_data >= kml_snir_min) = uint8(sColorMap(i, 3) * 255);
    end
    
    kml_img(:, :, 1) = kml_r;
    kml_img(:, :, 2) = kml_g;
    kml_img(:, :, 3) = kml_b;
    
    kml_a(kml_r == 0 & kml_g == 0 & kml_b == 0) = 0;
    
    imwrite(kml_img, "out/kml/sim_snir.png", 'Alpha', kml_a);
    imwrite(make_legend(sValues, "dB", sColorMap * 255, 80, 30), "out/kml/snir_legend.png");
    
    % Capacity
    kml_data = reshape(capData, kml_n_lines, kml_n_cols);
    
    kml_r = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_g = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_b = uint8(zeros(kml_n_lines, kml_n_cols));
    kml_a = ones(kml_n_lines, kml_n_cols) * 0.7;
    
    for i = 1:length(cValues)
        if i < length(cValues)
            kml_cap_max = cValues(i + 1);
        else
            kml_cap_max = Inf;
        end
        
        kml_cap_min = cValues(i);

        kml_r(kml_data < kml_cap_max & kml_data >= kml_cap_min) = uint8(cColorMap(i, 1) * 255);
        kml_g(kml_data < kml_cap_max & kml_data >= kml_cap_min) = uint8(cColorMap(i, 2) * 255);
        kml_b(kml_data < kml_cap_max & kml_data >= kml_cap_min) = uint8(cColorMap(i, 3) * 255);
    end
    
    kml_img(:, :, 1) = kml_r;
    kml_img(:, :, 2) = kml_g;
    kml_img(:, :, 3) = kml_b;
    
    kml_a(kml_r == 0 & kml_g == 0 & kml_b == 0) = 0;
    
    imwrite(kml_img, "out/kml/sim_capacity.png", 'Alpha', kml_a);
    imwrite(make_legend(cValues, "circ.", cColorMap * 255, 80, 30), "out/kml/capacity_legend.png");
    
    write_kml(...
        "out/kml/sim.kml", ...
        "GSM Converage data", ...
        ["RX Power", "sim_pwr.png", "pwr_legend.png", min(rxLats), max(rxLats), max(rxLons), min(rxLons)
         "SNIR", "sim_snir.png", "snir_legend.png", min(rxLats), max(rxLats), max(rxLons), min(rxLons)
         "Best Server (by RX Power)", "sim_best_server_by_pwr.png", "", min(rxLats), max(rxLats), max(rxLons), min(rxLons)
         "Best Server (by SNIR)", "sim_best_server_by_snir.png", "", min(rxLats), max(rxLats), max(rxLons), min(rxLons)
         "Capacity", "sim_capacity.png", "capacity_legend.png", min(rxLats), max(rxLats), max(rxLons), min(rxLons)], ...
         [txs]...
         );
end

%% Summary
if EXPORT_SUMMARY == 1
    s_fid = fopen("out/sim.txt", 'w');
    
    fprintf(s_fid, "GSM Coverage simulation summary\n");
    fprintf(s_fid, "Date: %d-%d-%d %d:%d:%d\n", datetime().Year, datetime().Month, datetime().Day, datetime().Hour, datetime().Minute, ceil(datetime().Second));
    fprintf(s_fid, "------------------------------\n");
    
    used_carriers = length(unique(txChannels));
    fprintf(s_fid, "Used carriers: %d\n", used_carriers);
    fprintf(s_fid, "Sectorial antenna gain: %.2f dB\n", max(max(pattern(txAntennas{5}, txFreqs(5)))));
    fprintf(s_fid, "Omni antenna gain: %.2f dB\n", max(max(pattern(txAntennas{1}, txFreqs(1)))));
    fprintf(s_fid, "------------------------------\n");
    
    area_hyp = lldistkm([max(rxLats) min(rxLons)], [min(rxLats) max(rxLons)]);
    area_size = area_hyp ^ 2 / 2;
    
    fprintf(s_fid, "Area size: %.2f km^2\n", area_size);
    
    pct_covered_area = sum(pwrData >= rxSens & snirData >= minSnir) / length(pwrData);
    fprintf(s_fid, "Area covered: %.2f%% (%.2f km^2)\n", pct_covered_area * 100, pct_covered_area * area_size);
    
    pct_covered_area = sum(pwrData >= -90 & snirData >= minSnir) / length(pwrData);
    fprintf(s_fid, "Area covered (RX Power >= -90 dBm): %.2f%% (%.2f km^2)\n", pct_covered_area * 100, pct_covered_area * area_size);
    
    pct_covered_area = sum(pwrData >= -70 & snirData >= minSnir) / length(pwrData);
    fprintf(s_fid, "Area covered (RX Power >= -70 dBm): %.2f%% (%.2f km^2)\n", pct_covered_area * 100, pct_covered_area * area_size);
    
    pct_covered_area = sum(pwrData >= rxSens & snirData >= 12) / length(pwrData);
    fprintf(s_fid, "Area covered (SNIR >= 12 dB): %.2f%% (%.2f km^2)\n", pct_covered_area * 100, pct_covered_area * area_size);
    
    pct_covered_area = sum(pwrData >= rxSens & snirData >= 18) / length(pwrData);
    fprintf(s_fid, "Area covered (SNIR >= 18 dB): %.2f%% (%.2f km^2)\n", pct_covered_area * 100, pct_covered_area * area_size);
    
    fclose(s_fid);
end
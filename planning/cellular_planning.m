 %
% Planeamento celular para GSM Rural
% 
% Comunicações Móveis 2021-22
% João Silva
% N. 2191733
%

clear all;
close all;
clc;

%% Study area data
nHab_c = 17818; % (2021) (concelho) pordata.
area_c = 211.31; % km2 (concelho)
nHab_v = 3279; % (2021) (vila)
area_v = 8.68; % km2 (vila)

nHab = nHab_c;
area = area_c;

sArea = 15 * 15; % Area de estudo, km2

fprintf("Área de estudo: %.2f km^2\n", sArea);
fprintf("Densidade populacional: %.2f hab/km^2\n", nHab / area);

%% Global technology data
%tp = 1.776; % (2021) anacom relatorio anual serviços moveis 2021, inclui M2M
tp = 1.257; % (2021) anacom relatorio anual serviços moveis 2021
vdfMarketShare = 0.293; % (2021) anacom factos e números
callTotal = 35434100000; % min (total 2021) anacom factos e números
callAvg = 192; % sec (2021 Q4) anacom relatorio anual serviços moveis 2021
nSub = 18400000; % (2021 Q4) anacom relatorio anual serviços moveis 2021
busyHourRatio = 10; % 10x tráfego para hora mais carregada
nCircuits = 8; % Circuitos por portadora (GSM débito total = 8, parcial = 16)
nCarriers = 2; % Portadoras por setor
nSectors = 3; % GSM -> 1 omni, 3 ou 6 setores
nCells = 4; % GSM -> 4 celulas por agregado
pBlock = 0.01; % 1% prob. bloqueio

fprintf("Taxa de penetração da tecnologia: %.2f %%\n", tp * 100);
fprintf("Cota de mercado Vodafone: %.2f %%\n", vdfMarketShare * 100);
fprintf("Duração média de cada chamada: %d s\n", callAvg);
fprintf("Aumento de tráfego na hora mais carregada: %.2fx\n", busyHourRatio);
fprintf("Portadoras por setor: %d\n", nCarriers);
fprintf("Setores por célula: %d\n", nSectors);
fprintf("Células por agregado: %d\n", nCells);
fprintf("Probabilidade de bloqueio: %.2f %%\n", pBlock * 100);

%%
nCalls = callTotal * 60 / callAvg;
nCallsHour = nCalls / (24 * 365);
nCallsBH = nCallsHour * busyHourRatio;
nCallsPerSubBH = nCallsBH / nSub;
trafficPerSubBH = nCallsPerSubBH * callAvg / (60 * 60); % Erlang
nHabStudyArea = nHab / area * sArea;
nSubStudyArea = nHabStudyArea * tp * vdfMarketShare;
trafficBH = trafficPerSubBH * nSubStudyArea;

nCircuitsPerSector = nCarriers * nCircuits;
trafficPerSector = inverlangb(nCircuitsPerSector, pBlock);
trafficPerCell = trafficPerSector * nSectors;
trafficPerCluster = trafficPerCell * nCells;

nReqCells = trafficBH / trafficPerCell;
nReqClusters = floor(nReqCells / nCells);
nReqStandaloneCells = ceil(mod(nReqCells, nCells));

if nReqStandaloneCells == 4
    nReqStandaloneCells = 0;
    nReqClusters = nReqClusters + 1;
end

nTotalReqCells = nReqStandaloneCells + nReqClusters * nCells;
offeredTraffic = nTotalReqCells * trafficPerCell;

cellCoverage = sArea / nTotalReqCells;
cellRadius = sqrt(cellCoverage / pi);

fprintf("\n----------- RESULTADOS ------------\n\n");
fprintf("Tráfego na hora mais carregada: %.2f Erlang\n", trafficBH);
fprintf("Número total de células necessárias: %d\n", nTotalReqCells);
fprintf("Número de agregados necessário: %d\n", nReqClusters);
fprintf("Número de células isoladas necessário: %d\n", nReqStandaloneCells);
fprintf("Tráfego oferecido: %.2f Erlang\n", offeredTraffic);
fprintf("Área coberta por célula estimada: %.2f km^2\n", cellCoverage);
fprintf("Raio celular estimado: %.2f km\n", cellRadius);


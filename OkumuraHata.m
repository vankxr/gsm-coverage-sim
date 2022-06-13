classdef OkumuraHata < rfprop.PropagationModel
    methods(Access = protected)
        function pl = pathlossOverDistance(~, rx, tx, d, ~)
            %c = rfprop.Constants.LightSpeed;
            f = tx.TransmitterFrequency;
            h_tx = tx.AntennaHeight;
            h_rx = rx.AntennaHeight;
            
            f = f / 1e6;

            if f >= 150 && f <= 200
                c_rx = 8.29 * (log10(1.54 * h_rx) ^ 2) - 1.1;
            elseif f >= 200 && f <= 1500
                c_rx = 3.2 * (log10(11.75 * h_rx) ^ 2) - 4.97;
            else
                c_rx = 0.8 + (1.1 * log10(f) - 0.7) * h_rx - 1.56 * log10(f);
            end

            pl_u = 69.55 + 26.16 * log10(f) - 13.82 * log10(h_tx) - c_rx + (44.9 - 6.55 * log10(h_tx)) * log10(d / 1000);

            %if strcmp(type, "u") == 1
            %    pl = pl_u;
            %elseif strcmp(type, "su") == 1
            %    pl = pl_u - 2 * (log10(f / 28) ^ 2) - 5.4;
            %elseif strcmp(type, "o") == 1
                pl = pl_u - 4.78 * (log10(f) ^ 2) + 18.33 * log10(f) - 40.97;
            %else
            %    pl = d * 0;
            %end
        end
    end
    
    methods
        function r = range(pm, txs, pl)
            % Validate inputs
            validateattributes(pm,{'rfprop.FreeSpace'}, ...
                {'scalar'},'range','',1);
            validateattributes(txs,{'txsite'},{'nonempty'},'range','',2);
            validateattributes(pl,{'numeric'}, ...
                {'real','finite','nonnan','nonsparse','scalar'},'range','',3);
            
            numTx = numel(txs);
            r = zeros(numTx,1);
            for txInd = 1:numel(txs)
                tx = txs(txInd);
                maxrange = pm.fsrange(tx.TransmitterFrequency, pl);
                r(txInd) = validateRange(pm, maxrange);
            end
        end
    end
    
    % Use static method for range computation so it can be called by
    % rfprop.PropagationModel.range
    methods(Static, Hidden)
        function d = fsrange(f, h_tx, h_rx, pl)
            f = f / 1e6;

            if f >= 150 && f <= 200
                c_rx = 8.29 * (log10(1.54 * h_rx) ^ 2) - 1.1;
            elseif f >= 200 && f <= 1500
                c_rx = 3.2 * (log10(11.75 * h_rx) ^ 2) - 4.97;
            else
                c_rx = 0.8 + (1.1 * log10(f) - 0.7) * h_rx - 1.56 * log10(f);
            end
            
            pl_u = pl + 4.78 * (log10(f) ^ 2) - 18.33 * log10(f) + 40.97;
            d = (10 ^ ((pl_u - 69.55 - 26.16 * log10(f) + 13.82 * log10(h_tx) + c_rx) / (44.9 - 6.55 * log10(h_tx)))) * 1000;
        end
    end
end


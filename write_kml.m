%
% write_kml.m
% 
% Comunicações Móveis 2021-22
% João Silva
% N. 2191733
%

function write_kml(file, name, overlays, txSites)
    fid_write = fopen(file, 'w');
    
    fprintf(fid_write, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid_write, '<kml xmlns="http://earth.google.com/kml/2.1">\n');
    fprintf(fid_write, '  <Folder>\n');
    fprintf(fid_write, '    <name>%s</name>\n', name);
    fprintf(fid_write, '    <open>1</open>\n');
    
    for f_idx = 1:size(overlays, 1)
        f = overlays(f_idx, :);
        
       overlay_name = f(1);
       overlay_file = f(2);
       legend_file = f(3);
       maxLat = f(4);
       minLat = f(5);
       maxLon = f(6);
       minLon = f(7);

        fprintf(fid_write, '<Folder>\n');
        fprintf(fid_write, '  <name>%s</name>\n', overlay_name);
        fprintf(fid_write, '  <GroundOverlay>\n');
        fprintf(fid_write, '    <name>%s overlay</name>\n', overlay_name);
        fprintf(fid_write, '    <Icon>\n');
        fprintf(fid_write, '      <href>%s</href>\n', overlay_file);
        fprintf(fid_write, '    </Icon>\n');
        fprintf(fid_write, '    <LatLonBox>\n');
        fprintf(fid_write, '      <north>%s</north>\n', num2str(maxLat));
        fprintf(fid_write, '      <south>%s</south>\n', num2str(minLat));
        fprintf(fid_write, '      <east>%s</east>\n', num2str(maxLon));
        fprintf(fid_write, '      <west>%s</west>\n', num2str(minLon));
        fprintf(fid_write, '      <rotation>0.0</rotation>\n');
        fprintf(fid_write, '    </LatLonBox>\n');
        fprintf(fid_write, '  </GroundOverlay>\n');
        fprintf(fid_write, '  <ScreenOverlay>\n');
        fprintf(fid_write, '    <name>%s legend</name>\n', overlay_name);
        fprintf(fid_write, '    <Icon>\n');
        fprintf(fid_write, '      <href>%s</href>\n', legend_file);
        fprintf(fid_write, '    </Icon>\n');
        fprintf(fid_write, '    <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
        fprintf(fid_write, '    <screenXY x="0" y="1" xunits="fraction" yunits="fraction"/>\n');
        fprintf(fid_write, '    <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
        fprintf(fid_write, '    <size x="0" y="0" xunits="fraction" yunits="fraction"/>\n');
        fprintf(fid_write, '  </ScreenOverlay>\n');
        fprintf(fid_write, '</Folder>\n');
    end

    fprintf(fid_write, '    <Folder>\n');
    fprintf(fid_write, '      <name>TX Sites</name>\n');
    fprintf(fid_write, '      <open>1</open>\n');
    
    for s_idx = 1:length(txSites)
        tx = txSites(s_idx);
        
        txFreq = "Frequency: " + num2str(tx.TransmitterFrequency / 1e6) + " MHz";
        txPower = "Power: " + num2str(10 * log10(tx.TransmitterPower * 1000)) + " dBm";
        txHeight = "Height: " + num2str(tx.AntennaHeight) + " m";
        
        fprintf(fid_write, '      <Placemark>\n');
        fprintf(fid_write, '        <name>%s</name>\n', tx.Name);
        fprintf(fid_write, '        <description>%s\n%s\n%s</description>\n', txFreq, txPower, txHeight);
        fprintf(fid_write, '        <Point>\n');
        fprintf(fid_write, '          <coordinates>%s,%s,%s</coordinates>\n', num2str(tx.Longitude), num2str(tx.Latitude), num2str(tx.AntennaAngle));
        fprintf(fid_write, '        </Point>\n');
        fprintf(fid_write, '      </Placemark>\n');
    end
    
    fprintf(fid_write, '    </Folder>\n');
    fprintf(fid_write, '  </Folder>\n');
    fprintf(fid_write, '</kml>\n');

    fclose(fid_write);
end


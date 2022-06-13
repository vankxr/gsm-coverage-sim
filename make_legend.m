%
% make_legend.m
% 
% Comunicações Móveis 2021-22
% João Silva
% N. 2191733
%

function img_rgb = make_legend(values, unit, colorMap, width, height)
    img_r = [];
    img_g = [];
    img_b = [];
    
    for c = 1:length(colorMap)
        img_r = [img_r; uint8(repmat(colorMap(c, 1), height, width))];
        img_g = [img_g; uint8(repmat(colorMap(c, 2), height, width))];
        img_b = [img_b; uint8(repmat(colorMap(c, 3), height, width))];
    end
    
    img_rgb(:, :, 1) = img_r;
    img_rgb(:, :, 2) = img_g;
    img_rgb(:, :, 3) = img_b;
    
    f = figure;
    imshow(img_rgb);
    
    set(gca,'units', 'pixels');
    x = get(gca, 'position');
    set(gcf,'units', 'pixels');
    y = get(gcf, 'position');
    set(gcf,'position', [y(1) y(2) x(3) x(4)]);
    set(gca,'units', 'normalized', 'position', [0 0 1 1]);
    
    for c = 1:length(values)
        text(10, height * (c - 1) + height / 2, strcat(num2str(values(c)), " ", unit), 'Color', [0 0 0], 'FontSize', 8, 'FontWeight', 'bold');
    end
    
    img_rgb = getframe(f).cdata;
    
    close(f);
end


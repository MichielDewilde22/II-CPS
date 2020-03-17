function [x, y] = laeap(taz, tel)
    for i = 1:1:length(tel)
        for j = 1:1:length(taz)
            x(i, j) = ka(taz(j), tel(i)) * cos(deg2rad(tel(i))) * sin(deg2rad(taz(j) - 0));
            y(i, j) = ka(taz(j), tel(i)) * ((cos(deg2rad(0)) * sin(deg2rad(tel(i)))) - (sin(deg2rad(0)) * cos(deg2rad(tel(i))) * cos(deg2rad(taz(j) - 0))));
        end
    end
end

function k = ka(az, el)
    k = sqrt(2 / (1 + (sin(deg2rad(0)) * sin (deg2rad(el))) + (cos(deg2rad(0)) * cos(deg2rad(el)) * cos(deg2rad(az - 0)))));
end


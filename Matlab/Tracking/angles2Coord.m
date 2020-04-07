function [mosquitoPos] = angles2Coord(Azel1,Azel2,Azel3)
    angles = [Azel1(1), Azel1(2);
              Azel2(1), Azel2(2);
              Azel3(1), Azel3(2)];
    endpoints = [cos(angles(:,2))*cos(angles(:,1)), cos(angles(:,2))*sin(angles(:,1)), sin(angles(:,2))];
    mosquitoPos = lineIntersect3D(nodes, endpoints);
end


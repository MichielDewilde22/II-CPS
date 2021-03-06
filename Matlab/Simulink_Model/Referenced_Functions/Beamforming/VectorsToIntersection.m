function [x,y,z] = VectorsToIntersection(vectors)
%VECTORSTOINTERSECTION Calculates nearest intersection point of vectors.
%   - vectors contains of n vectors of 6 elements (6DOF)
n_vectors = size(vectors,1);

dist_p_2 = 10;

p_1 = zeros(n_vectors, 3);
p_2 = zeros(n_vectors, 3);

for i_vector = 1:size(vectors,1)
    p_1(i_vector,:) = [vectors(i_vector,1) vectors(i_vector, 2) vectors(i_vector, 3)];
    
    p_2(i_vector,:) = [vectors(i_vector,1) + (dist_p_2*vectors(i_vector, 4)), ...
        vectors(i_vector,2) + (dist_p_2*vectors(i_vector, 5)), ...
        vectors(i_vector,3) + (dist_p_2*vectors(i_vector, 6))];
end

[P_intersect, ~] = lineIntersect3D(p_1,p_2);

x = P_intersect(1);
y = P_intersect(2);
z = P_intersect(3);

end


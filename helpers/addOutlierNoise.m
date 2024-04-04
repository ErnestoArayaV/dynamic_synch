function [ H ] = addOutlierNoise(H, G, etasm)

%% Add outlier noisy measurements to a single slice
% H is the matrix of clean measurements on top of which to insert the outliers (it can be empty)
% G is the measurement graph of existing edges; a subset of which will be turned into outlier edges.
% etasm is the noise level; (eg fraction of edges turned outliers)

n = length(G);

% Make each existing edge "bad" with some probability
Gbad = rand(n);
Gbad = Gbad <= etasm;
Gbad = triu(Gbad,1);
Gbad = Gbad .* G;

badEdges = find(Gbad == 1);
nrBadEdges = length(badEdges);

allEdges = find( triu(G,1) == 1);
nrEdges = length(allEdges);

disp(['nrBadEdges=' int2str(nrBadEdges)  ' out of nrEdges='  int2str(nrEdges) ]);

Hbad = Gbad;

Hbad(badEdges) = exp(2 * pi * rand(nrBadEdges,1)*complex(0,1));

% Make Hermitian and the support graph symmetric: 
Hbad = (Hbad + Hbad');
Gbad = Gbad + Gbad';
badEdges = find(Gbad == 1);


if isempty(H)
    H = Hbad;
else
    % Insert the outliers in the given matrix:
    H(badEdges) = Hbad(badEdges);
end

end


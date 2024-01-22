function  ANG_EST = get_ANG_EST(eigVect)
% from complex numbers to angles

n = length(eigVect);

% Fixed November 6 !!!!
% ANG_EST = atan2(real(eigVect),imag(eigVect));
ANG_EST = atan2(imag(eigVect),real(eigVect));

% ANG_EST = ANG_EST - repmat(ANG_EST(1),n,1);

ANG_EST = mod(ANG_EST, 2*pi);
ANG_DEG_EST = mod(rad2deg(ANG_EST), 360);
% ANG_EST = ANG_DEG_EST;
end



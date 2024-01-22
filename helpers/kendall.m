
function [perc, nr_flips, nrP, corrKend] = kendall( trueRanks, xi)

n = length(trueRanks);
nrP = n * (n-1) / 2;

% [~, orderTrueRanks] = sort(trueRanks);
% [~, orderSolRank] = sort(xi);
% nr_flips = kendalltau_dist( orderTrueRanks , orderSolRank);
% tau = myround(tau,3)
% perc = nr_flips / nrP;
% [ nr_flips  perc]

% corrKend = corr(pi,xi,'type','Kendall');
Y = [ trueRanks xi ];
corrKend = kendalltau(Y);
corrKend = corrKend(1,2); % input('see new corrKend');
% corrKend = myround(corrKend,3)

perc = (1 - corrKend) / 2;
% perc
nr_flips = perc * nrP;
[ nr_flips  perc];

% nr_flips

% [perc,nr_flips,nrP, corrKend] = kendall_old( trueRanks, xi);
% perc

% input('asad'); 

end
 

function tau = kendalltau_dist( order1 , order2 )
%% Returns the Kendall tau distance between two orderings
% Note: this is not the most efficient implementation
[ dummy , ranking1 ] = sort( order1(:)' , 2 , 'ascend' );
[ dummy , ranking2 ] = sort( order2(:)' , 2 , 'ascend' );
N = length( ranking1 );
[ii,jj]=meshgrid(1:N,1:N);
ok = find( jj(:) > ii(:) );
ii=ii(ok);
jj=jj(ok);
nok = length( ok );
sign1 = ranking1( jj ) > ranking1( ii );
sign2 = ranking2( jj ) > ranking2( ii );
tau = sum( sign1 ~= sign2 );
end


function [perc,nr_flips,nrP, corrKend] = kendall_old( pi, xi)

% the number of pairs of candidates that are ranked 
% in different orders

% pi = [ 1, 3, 2, 4]'
% xi = [ 2, 3, 1, 4]'

[pi xi];
% figure(1); plot(pi, xi , '.r');     input('see   kendall');

n = length(pi);

num = (1:n)';

Qp = [pi num];
Qx = [xi num];

P = nchoosek(num,2);
nrP = length(P);

reversed = 0;
same_order = 0;

for p=1:nrP
   i = P(p,1);
   j = P(p,2);  % these are id's of the people
   [ i j ];
   
   poz_ip = find(Qp(:,1)==i);
   poz_jp = find(Qp(:,1)==j);
   [poz_ip poz_jp];
   
   poz_ix = find(Qx(:,1)==i);
   poz_jx = find(Qx(:,1)==j);
   [poz_ix poz_jx];
   
   if (poz_ip < poz_jp && poz_ix < poz_jx) || ( poz_ip > poz_jp && poz_ix > poz_jx )
        same_order = same_order + 1;
   else
       reversed = reversed + 1;
   end
   % disp('-------');
end

same_order;
reversed;

perc = min ( same_order / nrP,  reversed / nrP );
perc = myround(perc,3);

% disp(['# flips = ' int2str(min(same_order,reversed)) ' out of ' int2str(nrP) ]);
% disp(['% flips = ' num2str(perc) ]);

nr_flips = min(same_order,reversed);

% corrKend = corr(pi,xi,'type','Kendall');
Y = [ pi xi ];
corrKend = kendalltau(Y);
corrKend = corrKend(1,2);	%%% input('see new corrKend');

corrKend = myround(corrKend,3);

end





function G = ErdosRenyi(n,p)
R = rand(n); 
R = triu(R,1);  R = (R+R'); 
G = (R<=p)+0;
G = G - diag(diag(G));
end
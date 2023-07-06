%projection onto the product of complex circles 
function proj = proj_1(g)
proj=g./abs(g);
proj(g==0)=1;

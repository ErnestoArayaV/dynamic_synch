%projection onto the product of complex circles 
function proj = proj_C(g)
proj=g./abs(g);
proj(g==0)=1;

function x_com = realtocomplex(x_real)
if min([size(x_real,1) size(x_real,2)])>1
    return
end
l=length(x_real);
if mod(l,2) == 0
    if size(x_real,1)==1
        x_com = complex(x_real(1,1:l/2),x_real(1,l/2+1:l));
         %x_com = complex(x_real(1:l/2,1),x_real(l/2+1:l,1));
    elseif size(x_real,2)==1
        x_com = complex(x_real(1:l/2,1),x_real(l/2+1:l,1));
         %x_com = complex(x_real(1,1:l/2),x_real(1,l/2+1:l));
    end
end
        
             
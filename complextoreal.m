%script to transform a complex vector or matrix into a real vector to
%create an equivalent quadratic form.
function x_real = complextoreal(x_complex)
if size(x_complex,1)==1
    x_real = [real(x_complex) imag(x_complex)];
elseif  size(x_complex,2)==1
    x_real = [real(x_complex); imag(x_complex)];
else
    x_real = [real(x_complex) -imag(x_complex);imag(x_complex) real(x_complex)];
end

        

%generate ground truth signal close to the low frequency space with different smoothness classes.
%There are 3 methods implemented, depending on the user's choice. 

%Input:        n,T      - number of elements, number of blocks (resp)
%              
%              varargin{1} 
%                           - method   - string with the name of the
%                                        method:'lip_constant','discontinuities' or
%                                       'projection'.
%              varargin{2}  
%                          - smoothness (methods 'lip_constant' and'discontinuities') - It is a string describing the smoothness class.
%                           Classes supported:'sqrt(T)','1','1/T','1/sqrt(T)'.
%                           NOTE:It's important to write the exact string.  
%                          - proj_mat(method 'projection') = psd matrix of size TXT, used to define a 'low frequency' space. See
%                                                             projmat_smalleigs_lap.m
%
%Output:       gt       -'low frenquency' ground truth vector. Size nTx1

function gt = generate_ground_truth_copy(n,T,varargin)
grid = (1/T)*(1:1:T);% initial time grid
if strcmp(varargin{1},'lip_constant')
    if strcmp(varargin{2},'1/T')
        a = .5+4.5*rand(1,n-1); %random coefficients in [0.5,5]
    elseif strcmp(varargin{2},'1/sqrt(T)')
        a = .5+T^(.25)*4.5*rand(1,n-1);%random coefficients in [0.5,T^.25]
    elseif strcmp(varargin{2},'1')
        a = .5+T^(.5)*4.5*rand(1,n-1);%random coefficients in [0.5,T^.5]
    elseif strcmp(varargin{2},'sqrt(T)')
        a = .5+T^(.75)*4.5*rand(1,n-1);%random coefficients in [0.5,T^.75]
    end
    outer = (2/pi)*a'*grid;% (n-1)*T array where the smooth fucntion f(x)=4*cos^3(x) will be evualuted entrywise 
    Z=[ones(1,T);exp((4/n)*2*pi*1i*(cos(outer)).^3)];
    gt=Z(:);
    
elseif strcmp(varargin{1},'discontinuities')
    a = .5+4.5*rand(1,n-1);%random coefficients in [0.5,5]
    if strcmp(varargin{2},'1/sqrt(T)')
        val_discont = 2/sqrt(T); % size of the jump
        nb_discont = 2; % number of discontinuities
    elseif strcmp(varargin{2},'1')
         val_discont = 1; % size of the jump
         nb_discont = 2;% number of discontinuities
    elseif strcmp(varargin{2},'sqrt(T)')
        val_discont = 1;% size of the jump
        nb_discont = ceil(sqrt(T));% number of discontinuities
    end
    size_discont = ceil(T/nb_discont);
    %create discontinuity matrix
    discont_mat = zeros(n-1,T);
    for k=1:nb_discont
        discont_mat(:,(k-1)*size_discont+1:k*size_discont)= (k-1)*val_discont*ones(n-1,size_discont);
    end
    outer = (2/pi)*a'*grid;
    Z=[ones(1,T);exp((4/n)*2*pi*1i*((cos(outer)).^3+discont_mat))];%apply discontinuities
    gt=Z(:);
elseif strcmp(varargin{1},'projection')
    proj_mat = varargin{2};
    P_tau_n1 = kron(proj_mat,speye(n-1));
    rand_unif = rand((n-1)*T,1); %create a uniform random vector in [0,1]
    Z =P_tau_n1*rand_unif; %project it onto the 'low freq space' defined by 'proj_mat'
    Z = exp(2*pi*Z*complex(0,1)); %put into the manifold in a 'smooth' manner
    Z=reshape(Z, n-1,T);
    Z=[ones(1,T);Z];
    gt=Z(:);
end

   


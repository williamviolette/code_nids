function mf = maxfunction_tog(a)

global Y N1 N2 N alpha1 alpha2 e Z2;

% a=[5 5 5 5]
c1=a(1,1);
c2=a(1,2);
% z1=a(1,3);
% n1=a(1,4);
% z2=a(1,4);

% mf=-((((c1/(n1+1))^alpha1)*(z1+e))+(((c2/(N-n1+1))^alpha2)*(Z2-e)));

% change health production function
mf=-((((c1-.1*(N^2))^alpha1)*(Z2+e))+(((c2-.1*(N^2))^alpha2)*(Z2-e)));

end
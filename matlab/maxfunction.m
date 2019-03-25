function mf = maxfunction(a)

global Y N1 N2 alpha1 alpha2 e;

% a=[1 1 0 0]
c1=a(1,1);
c2=a(1,2);
z1=a(1,3);
z2=a(1,4);



mf=-((((c1/N1)^alpha1)*(z1+e))+(((c2/N2)^alpha2)*(z2-e)));

end
function mf = maxfunction_joint(a)

global Y N1 N2 alpha1 alpha2 e;

% a=[1 1 0 0]
c1=a(1,1);
c2=a(1,2);
z=a(1,3);

mf=-((((c1/N1)^alpha1)*(z+e))+(((c2/N2)^alpha2)*(z-e)));

end
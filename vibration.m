%????????

syms m p E I N A mf Ui Ca Cb ma Uo

ma=input('')
mf=input('???????')
%???????
Me=m/420*[156*p 22*p^2 54*p -13*p^2;...
    22*p^2 4*p^3 13*p^2 -3*p^3;...
    54*p 13*p^2 156*p -22*p^2;
    -13*p^2 -3*p^3 -22*p^2 4*p^3];

% ?????? a
Kea=E*I/p^3*[12 6*p -12 6*p;...
    6*p 4*p^2 -6*p 2*p^2; ...
    -12 -6*p 12 -6*p;... 
    6*p 2*p^2 -6*p 4*p^2];

	% ?????? b
Keb=(N*A-mf*Ui^2)*...
    [6/5*p 1/10 -6/5*p 1/10;...
    1/10 2*p/15 -1/10 -1/30;...
    -6/5*p -1/10 6/5*p -1/10;...
    1/10 -1/30 -1/10 2*p/15];
%?????????  a  

Ca=c/420*[156*p 22*p^2 54*p -13*p^2;...
    22*p^2 4*p^3 13*p^2 -3*p^3;...
    54*p 13*p^2 156*p -22*p^2;
    -13*p^2 -3*p^3 -22*p^2 4*p^3];

%?????????  b ??????
Cb=-(2*mf*Ui + ma*Uo)*[
    -1/2 -p/10 -1/2 p/10;
    p/10 0 -p/10 p^2/60;
    1/2 p/10 1/2 -p/10;
    -p/10 -p^2/60 p/10 0];











   

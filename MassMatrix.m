function me = MassMatrix( ie )
%  计算单元质量矩阵
%     ie -------  单元号
%     m  ----  整体坐标系下的质量矩阵

   global gNode gElement 
   xi=gNode(gElement(ie,2),2);
   xj=gNode(gElement(ie,3),2);
   yi=gNode(gElement(ie,2),3);
   yj=gNode(gElement(ie,3),3);
   p = ( (xj-xi)^2 + (yj-yi)^2 )^(1/2) ;                  % 微元体长度
  
    me=m/420*...            
	[156*p   22*p^2  54*p    -13*p^2;...
    22*p^2  4*p^3  13*p^2   -3*p^3;...
    54*p     13*p^2    156*p    -22*p^2;...
    -13*p^2  -3*p^3  -22*p^2  4*p^3];

    T = TransformMatrix( ie ) ;
    me = T*me*transpose(T) ;
return

% 已检查，没有问题
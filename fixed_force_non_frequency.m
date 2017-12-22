L=22;
Nel=100;
E=2.1;
N=17;
Q=1.5;
B=0.1651;
D=0.1397;
d=0.12426;
ef=1800;
ep=7800;
gTimeEnd=10;
gDeltaT=0.02;
Force=2000;                                                     % 强迫振动时需要算固有振动频率
Distance_For=5.5; 
Q=Q/60;                                                         % 单位换算
N=10^6 * N;                                                     % 单位压强换算
I=pi*(D^4-d^4)/64;                                              % 惯性距的求解
A1=pi*(B^2)/4;                                                  % 井眼横截面积
A2=pi*(D^2)/4;                                                  % 套管外面积
A3=pi*(d^2)/4;                                                  % 过流面积
Uo=Q/(A1-A2);                                                   % 环空外返速
Ui=Q/A3;                                                        % 环空内流速
E=E*10^11;
cm=(B^2+D^2)/(B^2-D^2);
timestep=gTimeEnd/gDeltaT;                                      % 计算步长
ma=cm*ef*A2;                                                    % 环空影响系数
mf=ef*A3;
mp=ep*(A2-A3);
m=mf+mp+ma;

% No.2 
%微元体节点进行编号
Nnode=Nel+1;                                                  % 节点总数
node=(1:Nnode);                                               % 生成节点向量
x=0:(L/Nel):L;                                                % 对节点进行坐标编号
xx=x';                                                        % 节点x坐标向量
yy=zeros(Nnode,1);                                            % 节点的node
                %节点编号      节点x坐标            节点y坐标
gNode=[        node'             xx                    yy];   %节点进行编号

%No.3微元体和节点的关系矩阵

               %微元体编号             左端节点             右端节点
gElement=[    (1:Nel)',               (1:Nel)',            (2:Nnode)'];  

%No.4 第一边界条件条件

	    %节点号          自由度号            边界值
 gBco=[    1,               1,                 0
	       1,               2,                 0
	        Nnode,          1,                 0
		    Nnode,          2,                 0];
         
 %No.5 微元体的长度
   xi=gNode(gElement(1,2),2);
   xj=gNode(gElement(1,3),2);
   yi=gNode(gElement(1,2),3);
   yj=gNode(gElement(1,3),3);
   p=sqrt((xi-xj)^2+(yi-yj)^2);
    
    f= zeros(2*Nnode,timestep);
    r=Distance_For/p;
    For_Node=(floor(r)+1)*2;
    cos=r-floor(r);
    
    % 定义初始载荷！！！
    for i=1
         if r-floor(r)==0
              %  力作用的节点            自由度                            力作用大小
  gNF=[ For_Node,                         1,                                Force;
        For_Node,                         2,                                 0  ];
   f(For_Node,i)=gNF(1,3); 
   f(For_Node+1,i)=gNF(2,3);
    else
        gNF=[ ceil(r),                   1,                      (p-cos/p)*Force; 
                    ceil(r),             2,                               0;
                    ceil(r)+1,           1,                      (cos/p)*Force;
                    ceil(r)+1,           2,                               0]; 
     f(For_Node,i)=gNF(1,3);
     f(For_Node+1,i)=gNF(2,3);
     f(For_Node+2,i)=gNF(3,3);
     f(For_Node+3,i)=gNF(4,3);
         end
    end
      
    for i=2: timestep  
    if r-floor(r)==0

              %  力作用的节点            自由度                            力作用大小
    gNF=[ For_Node,                         1,                          Force;
          For_Node,                         2,                                 0  ];
   f(For_Node,i)=gNF(1,3);
   f(For_Node+1,i)=gNF(2,3);
    else
        gNF=[ ceil(r),                   1,                      (p-cos/p)*Force; 
                    ceil(r),             2,                               0;
                    ceil(r)+1,           1,                      (cos/p)*Force;
                    ceil(r)+1,           2,                               0]; 
          
     f(For_Node,i)=gNF(1,3);
     f(For_Node+1,i)=gNF(2,3);
     f(For_Node+2,i)=gNF(3,3);
     f(For_Node+3,i)=gNF(4,3);
    end
    end 
    
   % No.6 质量矩阵和刚度矩阵 
   % 计算微元体的质量矩阵
     me=m/420*...            
	[156*p  22*p^2  54*p  -13*p^2;...
    22*p^2 4*p^3 13*p^2  -3*p^3;...
    54*p 13*p^2 156*p    -22*p^2;...
    -13*p^2  -3*p^3  -22*p^2  4*p^3];

	%套管的微元刚度矩阵
    Kea=E*I/(p^3)*...
	[12     6*p     -12         6*p;...
    6*p   4*p^2     -6*p      2*p^2;...
    -12    -6*p     12         -6*p;...
    6*p    2*p^2    -6*p     4*p^2];

    %由科氏力产生的微元刚度矩阵
	Keb=(N*A3+mf*Ui^2)*...
    [6/(5*p) 1/10    -6/(5*p)    1/10;...
    1/10    2*p/15   -1/10      -1/30;...
    -6/(5*p) -1/10   6/(5*p)    -1/10;...
    1/10    -1/30     -1/10      2*p/15];
	%微元的总体刚度矩阵
	ke=Kea+Keb;
    
    % No7. 质量矩阵和刚度矩阵进行组装 
       gK=zeros(Nnode*2);
       gM=zeros(Nnode*2);
     %按照微元体进行装配       
   for ie=1:Nel        % Nel 表示有多少个微元
     for i=1:2
       for j=1:2
           for p=1:2
               for q=1:2
                   m=(i-1)*2+p;
                   n=(j-1)*2+q;
                   M=(gElement(ie,i)-1)*2+m;      
                   N=(gElement(ie,j)-1)*2+n;
                   gK(M,N)=gK(M,N)+ke(m,n);
                   gM(M,N)=gM(M,N)+me(m,n);
               end
           end
        end
     end
   end
       
   % No.8 采用第一边界条件进行施加边界条件 
  [bc1_number,~]=size(gBco);
  w2max = max( diag(gK)./diag(gM) ); 
    
   for ibc=1:1:bc1_number
        n = gBco(ibc, 1 );                                      %这里查找的是节点
        d = gBco(ibc, 2 );                                      %查找约束施加的自由度
        m = (n-1)*2 + d;                                        %计算约束自由度在总刚矩阵中占用的自由度
        gK(:,m) = zeros( Nnode*2, 1 );                          %列化成0
        gK(m,:) = zeros( 1, Nnode*2 );                          %行化成0
        gK(m,m) = 1;  
   end
    
   for ibc=1:1:bc1_number
        n = gBco(ibc, 1 );
        d = gBco(ibc, 2 );
        m = (n-1)*2 + d;      
        gM(:,m) = zeros( Nnode*2, 1 );
        gM(m,:) = zeros( 1, Nnode*2 ) ;
        gM(m,m) = gK(m,m)/w2max/1e10 ;         
   end
    
    for i=1:Nnode*2
           for j=i:Nnode*2
               gK(j,i) = gK(i,j);
               gM(j,i) = gM(i,j);                          %进行对称化矩阵
           end
    end
  
    % 计算特征值和特征想
    [gEigVector, gEigValue] = eigs(gK, gM, 3, 'SM' );      %提取三阶特征值 
    fre_number=length(diag(gEigValue));
    
    for ibc=1:1:bc1_number
	    n = gBco(ibc, 1 );
        d = gBco(ibc, 2 );
        m = (n-1)*2 + d;                                   
        gEigVector(m,:) = gBco(ibc,3);                  %对振型进行边界化
    end
                     
    w1=sqrt(gEigValue(1,1))/2/pi;                                    
    w2=sqrt(gEigValue(2,2))/2/pi;                       %提取前两阶固有振动频率
    
    %No.9 水泥浆引起的微元的粘性阻尼矩阵 
    % 采用粘性阻尼进行求解
    dRatio=0.008;                                            % 结构阻尼比，钢材水泥选取0.008
    % Rayleigh Damping                                       % 粘性阻尼，采用比例阻尼方式
    alpha=2*(w1*w2)*dRatio/(w1+w2);                          % w1、w2是管材的固有振动频率
    beta= 2*dRatio/(w1+w2); 
    Ca=alpha*gM+beta*gK;                                     % rayleigh 方法确定的结构阻尼矩阵
    
    %科氏阻尼矩阵
	cb=-(2*mf*Ui + ma*Uo)*...
    [0          -p/10       -1/2            p/10;...
    p/10       0           -p/10          p^2/60;...
    1/2        p/10           0            -p/10;...
    -p/10     -p^2/60       p/10              0];                                
   % 对阻尼矩阵进行组装，从而能够的出整体的阻尼矩阵
 
 Cb=zeros(Nnode*2);
    for ie=1:Nel                                                    % Nel 表示有多少个微元
     for i=1:2
       for j=1:2
           for p=1:2
               for q=1:2
                   m=(i-1)*2+p;
                   n=(j-1)*2+q;
                   M=(gElement(ie,i)-1)*2+m;      
                   N=(gElement(ie,j)-1)*2+n;
                   Cb(M,N)=Cb(M,N)+cb(m,n);
               end
           end
        end
     end
    end
   
   gC=Cb+Ca;
    
   % 打印特征值
    fprintf( '\n\n\n\n 表二   特征值(频率)列表  \n' ) ;
    fprintf( '----------------------------------------------------------\n') ; 
    fprintf( '   阶数            特征值          频率(Hz)         圆频率(Hz)\n' ) ;
    fprintf( '---------------------------------------------------------\n') ;
    for i=fre_number:-1:1
        fprintf( '%6d   %15.7e   %15.7e   %15.7e\n', fre_number-i+1, ...
            gEigValue(i,i), sqrt(gEigValue(i,i))/2/pi, sqrt(gEigValue(i,i)) ) ;
    end
    fprintf( '----------------------------------------------------------\n') ;
    
% -----------------------------------------------------------------------------------------------------  计算振型图没有任何问题
% gDeltaT ------ 时间步长
% gTimeEnd ----- 计算结束时刻
% gDisp -------- 位移时程响应
% gVelo -------- 速度时程响应
% gAcce -------- 加速度时程响应
% 定义位移，速度和加速度
    gDisp = zeros( Nnode*2, timestep ) ;
    gVelo = zeros( Nnode*2, timestep ) ;
    gAcce = zeros( Nnode*2, timestep ) ;
  
    % 初始条件
    gDisp(:,1) = zeros(Nnode*2, 1 ) ;                   %初始位移
    gVelo(:,1) = zeros(Nnode*2, 1) ;                    %初始速度
 
    % 这里需要重新定义没有施加边界条件的质量矩阵、刚度矩阵
   
    hK=zeros(Nnode*2);
    hM=zeros(Nnode*2);
    
   for ie=1:Nel                                                     % Nel 表示有多少个微元
     for i=1:2
       for j=1:2
           for p=1:2
               for q=1:2
                   m=(i-1)*2+p;
                   n=(j-1)*2+q;
                   M=(gElement(ie,i)-1)*2+m;      
                   N=(gElement(ie,j)-1)*2+n;
                   hK(M,N)=hK(M,N)+ke(m,n);
                   hM(M,N)=hM(M,N)+me(m,n);
               end
           end
        end
     end
   end
   
   %计算初始加速度
    gAcce(:,1) =hM\(f(:,1)-hK*gDisp(:,1)-gC*gVelo(:,1)); 
   %采用振动Newmark方法进行振动分析
    gama = 0.5 ;
    beta = 0.25 ;                                                   % 采用平均加速度方法 Newmark- beta 方法
    alpha0 = 1/beta/gDeltaT^2;
    alpha1 = gama/beta/gDeltaT;
    alpha2 = 1/beta/gDeltaT;
    alpha3 = 1/2/beta - 1;
    alpha4 = gama/beta - 1;
    alpha5 = gDeltaT/2*(gama/beta-2);
    alpha6 = gDeltaT*(1-gama);
    alpha7 = gama*gDeltaT;
    K1 = hK + alpha0*hM + alpha1*gC;            %计算有效刚度矩阵
     
%-------------------------------------------------------------------------
% 把集中力集成到整体节点力向量中

   [bc1_number, ~ ]=size(gBco);
   K1im = zeros(Nnode*2, bc1_number);
    for ibc=1:1:bc1_number
        n=gBco(ibc,1);
        d=gBco(ibc,2);
        m=(n-1)*2+d;
        K1im(:,ibc)=K1(:,m);                                 %这是将原始边界条件储存到Klim中去，方便后面对力进行施加边界条件
        K1(:,m) = zeros( Nnode*2, 1 );                       %将有效刚度矩阵进行赋值
        K1(m,:) = zeros( 1, Nnode*2);                        %化行、化列法对边界条件进行施加
        K1(m,m) = 1.0;                                       %施加边界条件
    end
  [KL,KU]=lu(K1);
   
 %对每一个时间步计算、是按照时间步长进行计算
  
    for i=2:1:timestep
        
        if mod(i,100) == 0
            fprintf( '当前时间步：%d\n', i );          % 显示整数步长，模为零的情况
        end        
  
        f1 =f(:,i)+hM*(alpha0*gDisp(:,i-1)+alpha2*gVelo(:,i-1)+alpha3*gAcce(:,i-1)) ...
                  + gC*(alpha1*gDisp(:,i-1)+alpha4*gVelo(:,i-1)+alpha5*gAcce(:,i-1)) ;
       
        % 对f1进行边界条件处理, 施加力的边界条件
        [bc1_number,~] = size( gBco ) ;
        for ibc=1:1:bc1_number
            n = gBco(ibc, 1 ) ;
            d = gBco(ibc, 2 ) ;
            m = (n-1)*2 + d ;
        %如果是力  那么需要对力进行施加边界条件
            f1 = f1 - gBco(ibc,3) * K1im(:,ibc) ;      % 这个是施加边界条件    采用化行化列法施加边界条件    
            f1(m)=gBco(ibc,3);
        end
        y=KL\f1;
        gDisp(:,i) = KU\y ;
        gAcce(:,i) = alpha0*(gDisp(:,i)-gDisp(:,i-1)) - alpha2*gVelo(:,i-1) - alpha3*gAcce(:,i-1) ;
        gVelo(:,i) = gVelo(:,i-1) + alpha6*gAcce(:,i-1) + alpha7*gAcce(:,i) ;
    end
    % 绘制时程曲线
    t = 0:gDeltaT:(gTimeEnd-gDeltaT);
    d = gDisp((floor(Nnode/4)*2)+1,:);
    plot( t, d);
    title( 'L/2处挠度时程曲线');
    xlabel( '时间(s)');
    ylabel( '挠度(m)' );
    hold on 

% Experiment Cap 3, CSBOOK: Haykin
% Edit: Coronel Jose, EIE-FCEIA, Nov 2016

clear all  clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A=20;           % A: amplitud de la Sx Senoidal, 5 a 20, default 10
ciclos=1;       % periodos de la Sx Senoidal, default 1
M=100;          % M: muestreo de la Sx Senoidal, 50 a 200, default 100

delta=1;        % D: escalon de la modulacion DPCM y ADPCM, 1 a 3, default 1
mindelta=1/8;   % ADM minDelta, default 1/8
                % Sy: cantidad de simbolos PCM


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sx: generating sinwave
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P=2*pi;
t=(0 : P/M : P*ciclos);       
a=A*sin(t);  
n=length(a);
x(1:n)=a;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Linear Delta Modulation - LDM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init
xhat_d(1:n-1) = 0;
d_d(1:n) = 0;
sb_d = 0;

 for k=1: n
	if (x(k)-xhat_d(k)) > 0               % error de la modulacion
        d_d(k)=1;                
    else
        d_d(k)=-1;
    end
    
    if(k>1  &&  d_d(k-1) ~= d_d(k))     % contador de simbolos
            sb_d = sb_d+1;
    end

   xhat_d(k+1) = xhat_d(k) + d_d(k) * delta;    % modulacion LDM

 end
xhat_d = xhat_d(1:n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adaptive  Delta Modulation - ADM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init
xhat(1:n-1)=0;
p_md= 1+mindelta;

% ADPCM
d(1:n)=0;
sb=0;
for k=2:n
 	
	if ((x(k)-xhat(k-1)) > 0 )    % error del modulador
		d(k)=1; 	
    else
        d(k)=-1;
    end
    
    if(d(k-1) ~= d(k))            % Contador de simbolos           
        sb = sb+1;
    end            

	if k==2                       % 1ros valores para k=1 k=2
		xhat(k) = d(k) * delta + xhat(k-1);
    end

    delta_k = abs(xhat(k)-xhat(k-1));   % escalon del instante k

    if (d(k-1)  == -1 && d(k) == 1)                     % modo granular >> prox esc +50%
        xhat(k+1) = xhat(k) + 0.5 * delta_k;	  
    elseif (d(k-1)  == 1 && d(k) == 1)                  % modo sobrecarga ce pendiente >> prox esc + p_md
        xhat(k+1) = xhat(k) + p_md * delta_k;
    elseif (d(k-1)  == 1 && d(k) == -1)                 % modo granular >> prox esc -50%
        xhat(k+1) = xhat(k) - 0.5 * delta_k;
    elseif (d(k-1)  == -1 && d(k) == -1)                % modo sobrecarga ce pendiente >> prox esc - p_md
        xhat(k+1) = xhat(k) - p_md * delta_k;
    end
end
xhat = xhat(1:n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure() 

%LDM
subplot(1,2,1) 
hold on;
y2=A+5;

str = sprintf('LDM, M:%3d, A:%2d, D:%d y Sy:%2d', M, A, delta, sb_d);
title(str)
plot(t, a, 'Color','red' , 'LineWidth',2)
stairs(t, xhat_d, 'LineWidth',2);
% plot(t, xhat_d, 'Color','green');
plot(t, d_d-y2,  'Color','green' , 'LineWidth',2);
axis([0 t(n) -y2-2 A+2])

%ADM
subplot(1,2,2)
hold on;

str = sprintf('ADM, M:%3d, A:%2d, D:%d y Sy:%3d', M, A, delta, sb);
title(str)
plot(t, a, 'Color','red', 'LineWidth',2);
stairs(t, xhat, 'LineWidth',2);
% plot(t, xhat);
plot(t, d-y2,  'Color','magenta' , 'LineWidth',2)
axis([0 t(n) -y2-2 A+2])
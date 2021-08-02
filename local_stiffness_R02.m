function [k,Ar,R] = local_stiffness_R02(input)
%% local_stiffness_R01
% Funcion para obtener la matriz de rigidez local de un elemento
% También se obrtiene la matriz de rotacion y el vector de restriccion
% 
% INPUT
%   [A-I-E-L-alpha-BR1-BR2-w-v-x]
%   A: Area de la seccion transversal [m2]
%   I: Inercia de la seccion [m4]
%   E: Modulo de Elasticidad [ton/m2]
%   L: Longitud del elemento [m]
%   alpha: angulo de inclinacion respecto a la horizontal [rad]
%   BR1: longitud del brazo rigido respecto a la derecha [m]
%   BR2: longitud del brazo rigido respecto a la izquierda [m]
%   w: Carga distribuida [ton/m]
%   v: Modulo de Poisson
%   x: Tipo de Barra
% OUTPUT
%   k: Matriz de rigidez local
%   A: Matriz de transformacion
%   R: Vector de restricciones
%
% Hecho por: jeanp_251
%% PROCEDIMIENTOS
A = input(1);
I = input(2);
E = input(3);
L = input(4);
alpha = input(5);
w = input(8);
x = input(10);
switch x
    %--------------------------------------------------------------------------------------
    %---CASO 1 -> BARRA CON 3GDL POR NUDO (V,N Y M)
    %--------------------------------------------------------------------------------------
    case 1        
        aux1 = E*A/L;
        aux2 = 12*E*I/(L^3);
        aux3 = 6*E*I/(L^2);
        aux4 = 4*E*I/L;
        aux5 = 2*E*I/L;
        %---MATRIZ DE RIGIDEZ LOCAL 6X6
        k = [aux1 0 0 -aux1 0 0;...
            0 aux2 aux3 0 -aux2 aux3;...
            0 aux3 aux4 0 -aux3 aux5;...
            -aux1 0 0 aux1 0 0;...
            0 -aux2 -aux3 0 aux2 -aux3;...
            0 aux3 aux5 0 -aux3 aux4];  
        %-------------------------------
        c = cos(alpha);
        s = sin(alpha);
        r = [c s 0;...
             -s c 0;...
              0 0 1];
        A_aux = zeros(3,3);
        %---MATRIZ DE TRANSFORMACION 6X6
        Ar = [r A_aux; A_aux r];
        %-------------------------------
        V = w*L/2;
        M = (w*L^2)/12;
        %---VECTOR DE RESTRICCION 6X1
        R = [0; V; M; 0; V; -M];
    %--------------------------------------------------------------------------------------
    %---CASO 2 -> BARRA CON 2GDL POR NUDO (V Y M)
    %--------------------------------------------------------------------------------------
    case 2
        aux1 = 12*E*I/(L^3);
        aux2 = 6*E*I/(L^2);
        aux3 = 4*E*I/L;
        aux4 = 2*E*I/L;
        %---MATRIZ DE RIGIDEZ LOCAL 4X4
        k = [aux1 aux2 -aux1 aux2;...
            aux2 aux3 -aux2 aux4;...
            -aux1 -aux2 aux1 -aux2;...
            aux2 aux4 -aux2 aux3];
        %-------------------------------
        s = sin(alpha);
        c = cos(alpha);
        r = [-s c 0;...
              0 0 1];
        A_aux = zeros(2,3);
        %---MATRIZ DE TRANSFORMACION 4X6
        Ar = [r A_aux; A_aux r];
        %-------------------------------
        V = w*L/2;
        M = (w*L^2)/12;
        %---VECTOR DE RESTRUCCION 4X1
        R = [V;M;V;-M];
    %--------------------------------------------------------------------------------------
    %---CASO 3 -> BARRA 1GDL POR NUDO (N)
    %--------------------------------------------------------------------------------------
    case 3
        aux = E*A/L;
        %---MATRIZ DE RIGIDEZ LOCAL 2X2
        k = [aux -aux; -aux aux];
        %-------------------------------
        s = sin(alpha);
        c = cos(alpha);
        r = [c s];
        A_aux = zeros(1,2);
        %---MATRIZ DE TRANSFORMACIÓN 2X4
        Ar = [r A_aux; A_aux r];
        %---VECTOR DE RESTRICCION 4X1
        R = zeros(2,1);
    %--------------------------------------------------------------------------------------
    %---CASO 4 -> VIGA CON BRAZOS RIGIDOS (M,V)
    %--------------------------------------------------------------------------------------
    case 4
        a = input(6);
        c = input(7);
        b = L-a-c;
        %---MATRIZ DE RIGIDEZ LOCAL 2X2
        aux = 2*E*I/b;
        aux1 = 6/(b^2);
        aux2 = (3/b)*(1+2*a/b);
        aux3 = (3/b)*(1+2*c/b);
        aux4 = 2*(1+3*(a/b)+3*(a/b)^2);
        aux5 = 1+ 3*(a+c)/b +6*a*c/(b^2);
        aux6 = 2*(1+3*(c/b)+3*(c/b)^2);
        k = aux*[aux1, aux2, -aux1, aux3;...
                 aux2, aux4, -aux2, aux5;...
                 -aux1, -aux2, aux1, -aux3;...
                 aux3, aux5, -aux3, aux6];
        %-------------------------------
        s = sin(alpha);
        c = cos(alpha);
        r = [-s c 0;...
              0 0 1];
        A_aux = zeros(2,3);
        %---MATRIZ DE TRANSFORMACION 4X6
        Ar = [r A_aux; A_aux r];
        %-------------------------------
        V = w*L/2;
        M = (w*L^2)/12;
        %---VECTOR DE RESTRUCCION 4X1
        R = [V;M;V;-M];
    %--------------------------------------------------------------------------------------
    %---CASO 5 -> BARRA CON DEFORMACION POR CORTE (V,M)
    %--------------------------------------------------------------------------------------
    case 5
        v = input(9);
        %---MATRIZ DE RIGIDEZ LOCAL 4X4
        G = E/(2*(1+v));
        Ac = A/1.2;
        theta = 12*E*I/(L^2*G*Ac);
        aux = E*I/((1+theta)*L);
        aux1 = 4 + theta;
        aux2 = 2 - theta;
        aux3 = 6/L;
        aux4 = 12/(L^2);
        k = aux*[aux4 aux3 -aux4 aux3;...
                aux3 aux1 -aux3 aux2;...
                -aux4 -aux3 aux4 -aux3;...
                aux3 aux2 -aux3 aux1];
        %-------------------------------
        s = sin(alpha);
        c = cos(alpha);
        r = [-s c 0;...
              0 0 1];
        A_aux = zeros(2,3);
        %---MATRIZ DE TRANSFORMACION 4X6
        Ar = [r A_aux; A_aux r];
        %-------------------------------
        V = w*L/2;
        M = (w*L^2)/12;
        %---VECTOR DE RESTRUCCION 4X1
        R = [V;M;V;-M];
end
end
function [K_aporte, R_aporte] = glob_stiff_R01(k, R, input_globstiff,n)
%% global_stiffness
% Funcion para obtener el aporte a la matriz de rigidez global de un
% elemento y el aporte al Vector de Restriccion Global
% 
% INPUT
%   kest:  Matriz de rigidez local con direccion a los ejes globales 
%   R:     Vector de Restriccion
%   gdlx1: Grado de libertad x del nudo 1
%   gdly1: Grado de libertad y del nudo 1
%   gdlz1: Grado de libertad z del nudo 1
%   gdlx2: Grado de libertad x del nudo 2
%   gdly2: Grado de libertad y del nudo 2
%   gdlz2: Grado de libertad z del nudo 3
%   n: # de grados de libertad de la estructura
%   x: tipo de barra
% OUTPUT
%   K_porte: Aporte a la matriz de rigidez global del elemento i
%   R_aporte: Aporte al vector de restriccion global del elemento i
%
% Hecho por: jeanp_251
%% APORTE DE MATRIZ DE RIGIDEZ
gdl = input_globstiff;
%---DEFINIMOS LA MATRIZ DE APORTE DE RIGIDEZ GLOBAL
K_aporte = zeros(n,n);
%---TAMANO DE LA MATRIZ DE RIGIDEZ LOCAL
aux = size(k);
num = aux(1);
%---REDEFINIENDO EL VECTOR DE GDL SI FUESE BARRA TIPO ARMADURA
if num==4
    gdl = [gdl(1), gdl(2), gdl(4), gdl(5)];
end
%---APORTE DE LA MATRIZ DE RIGIDEZ
for i=1:num
    x = gdl(i);
    for j=1:num
        y = gdl(j); 
        K_aporte(x,y) = k(i,j);
    end
end
%% VECTOR DE APORTE RESTRICCION
%---DEFINIMOS EL VECTOR DE APORTE DE RESTRICCION
R_aporte = zeros(n,1);
%---APORTE DEL VECTOR DE RESTRICCION
for i=1:aux(1)
    aux2 = gdl(i);
    R_aporte(aux2) = R(i);
end
end
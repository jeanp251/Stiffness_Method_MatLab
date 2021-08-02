function [KLL, RL, QL, gdll] = stiff_red(K, R, Q, n, gdlr)
%% global_stiffness
% Funcion para obtener la matriz de Rigidez Reducida KLL, con solo los GDLL
% y el vector de Restruccion Reducido RLL
% 
% INPUT
%   K: Matriz de rigidez Global
%   R: Vector de Restriccion Global
%   n: #gdl
%   gdlr: Grados de Libertad Restringidos
% OUTPUT
%   KLL: Matriz de Rigidez Global Reducida con los gdl libres
%   RLL: Vector de Restriccion Global con los gdl libres
%
% Hecho por: jeanp_251
%% OBTENER GDLL
gdll = 1:1:n;
aux = length(gdlr);
for i=1:aux
    gdll = gdll(gdll~=gdlr(i));
end
%% MATRIZ DE RIGIDEZ GLOBAL REDUCIDA KLL
KLL = K(gdll,gdll);
%% VECTOR DE RESTRICCION GLOBAL REDUCIDO RL
RL = R(gdll);
%% VECTOR DE CARGAS REDUCIDO QL
QL = Q(gdll);
end
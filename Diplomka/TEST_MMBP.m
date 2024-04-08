
clear;clc
addpath('C:\Users\patri\Documents\GitHub\MATLAB\Diplomka\funkcie');

M = load("C:\Users\patri\Downloads\a100203.mat");

[ET,ET2] = zisti_et_from_bits(M.ab);

mmrp_bits = generate_mmrp(M.NN,M.Mx, M.alf,M.bet);


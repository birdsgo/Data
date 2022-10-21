function AnaWnd = AnalysisWindowFunction(W,SP)
% Function AnalysisWindowFunction
%INPUT
%W: 1 * 1 :Length of the window
%OUTPUT
%AnaWnd: W * 1 :Analysis Window
M0 = W - W * SP;
AnaWnd = ones(W,1);
AnaWnd(1 : M0) = sqrt(0.5 * (1 - cos(pi * (1 : M0)/M0)));
AnaWnd(W - M0 : W) = sqrt(0.5 * (1 - cos(pi * ((W - ((W - M0) : W))/M0))));
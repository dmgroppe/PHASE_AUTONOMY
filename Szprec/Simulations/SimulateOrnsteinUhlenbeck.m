function [ S ] = SimulateOrnsteinUhlenbeck(S0, mu, sigma, lambda, deltat, npoints )
% Simulate an ornstein uhlenbeck process.
% Looks more complicated than expected, because if we don't include the
% exp() terms, we are not accurate as deltat becomes large.
% Reference
% Based on the equation described in see
% http://www.puc-rio.br/marco.ind/sim_stoc_proc.html#mc-mrd
% For a formal treatment, see
% Gillespie, D. T. 1996. 'Exact numerical simulation of the Ornstein-Uhlenbeck process
% and its integral.' Physical review E 54, no. 2: 2084–2091.
% License
% Copyright 2010, William Smith, CommodityModels.com . All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification, are
% permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice, this list of
% conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice, this list
% of conditions and the following disclaimer in the documentation and/or other materials
% provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER, WILLIAM SMITH ``AS IS'' AND ANY EXPRESS
% OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
% THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
% OF SUBSTITUTE GOODS ORSERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.s

% Code
periods = npoints;
S = zeros(periods, 1);
S(1) = S0;
exp_minus_lambda_deltat = exp(-lambda*deltat);
% Calculate the random term.
if (lambda == 0)
 % Handle the case of lambda = 0 i.e. no mean reversion.
 dWt = sqrt(deltat) * randn(periods,1);
else
 dWt = sqrt((1-exp(-2*lambda* deltat))/(2*lambda)) * randn(periods,1);
end
% And iterate through time calculating each price.
for t=2:1:periods
 S(t) = S(t-1)*exp_minus_lambda_deltat + mu*(1-exp_minus_lambda_deltat) + sigma*dWt(t);
end
% OPTIM Note : % Precalculating all dWt's rather than one-per loop makes this function
% approx 50% faster. Useful for Monte-Carlo simulations.
% OPTIM Note : calculating exp(-lambda*deltat) makes it roughly 50% faster
% again.
% OPTIM Note : this is only about 25% slower than the rough calculation
% without the exp correction.
end
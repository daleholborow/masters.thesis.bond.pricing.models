function lognormalassets()
	clc
	clear all
	close all
	
	randn('state',1); % Remove this later
	
	T		= 1;
	a0		= 1;
	mu		= 0.05;
	sigma	= 0.2;

	N		= 2^18;
	h		= T/N;		% Set mesh to be very fine
	w		= randn(N,1);
	W		= [0; cumsum(w)*sqrt(h)];
	
	% Generate our Black Scholes asset path 
	finePath = GenerateBSPathEuler(a0,mu,sigma,N,T,W);
	% Calculate the relative times so our graph x axis is in years
	fineTimes = [0:h:T];
	
	hold on
	plot(fineTimes,finePath,'b');
	axis([0,T,0.9*min(finePath),1.1*max(finePath)]);
	title('Simulated asset path using Black-Scholes log-normal model');
	xlabel('Time in years');
	ylabel('Asset value');
	legend(['drift=' num2str(mu) ', volatility=' num2str(sigma)]);
	
end


function [aPath] = GenerateBSPathEuler(a0,mu,sigma,N,T,W)
	h		= T/N;
	
	% Store the path of our asset process in a predefined
	% variable for speed.
	aPath	= zeros(1,N+1);
	% Set our initial value for the process a_t at time t=0;
	aPath(1)= a0;
	
	a_i	= mu;
	b_i	= sigma;
	
	for ind = 1 : 1 : N
		aPath(ind+1) = aPath(ind) + h*a_i + b_i*(W(ind+1)-W(ind));
	end
end













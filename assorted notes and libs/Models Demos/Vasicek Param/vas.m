%MATLAB FILE FOR GENERATING ORNSTEIN-UHLENBECK PROCESS

%function gen = Generate_variables%
function vas()
% 	power = 2
% 	n = 10^power;
	n = 12*10;
	
	tic
	% =====================================================
	x = normrnd(0,1/n,n,1); % normal random variable
	% Setting parameters for Olsten-Uhlenbeck process:
	% =====================================================
% 	x
% 	plot(x)
	b = 20;
	a = 120;
	sigma = 10;
	r_0 = 4;

	% Generating Ornstein-Uhlenbeck process:
	% =====================================================
	i = 0;
	y = zeros(n,1);
	for i = 1:n
		y(i) = sigma*exp(b*i/n)*x(i);
	end

	z = ones(n,1);   % Ornstein-Uhlenbeck auxiliary vector
	i = 0;
	for i = 1:n
		z_aux = y(1:i,1); % auxiliary vector
		z(i) = sum(z_aux);
	end

	r = zeros(n,1);
	i = 0;
	for i = 1:n
		r(i) = a/b + exp(-b*i/n)*r_0 - a/b*exp(-b*i/n) + exp(-b*i/n)*z(i);
	end

	t = toc
	% figure
	% plot (y);
	% title('y i')
	% 
	% figure
	% plot (z);
	% title('z i')

	figure 
	plot (r);
	title('r i')

	save data r      % saving generated process in Matlab format
	
	'Using first estimator'
	tmp = Estimator_1(r);
	b_est = tmp(1)
	a_est = tmp(2)
	
	'Using second estimator'
	tmp = Estimator_2(r);
	b_est = tmp(1)
	a_est = tmp(2)
end

function est = Estimator_1(r);

load data   % loading saved data

% Estimating parematers:
% ===================================================================

[T, M] = size(r);

T_const = 1;
I = sum(r)/T;

% sigma_sq = 10000;
diff = r(2:T,1)-r(1:T-1,1); % we take vector of elements from 2nd to last
diff_aug = [r(1)- 4; diff];
J = sum(r.*diff_aug);

K = sum(r.^2)/T; % we first square each element in r, and then find the sum of vector

a_est = (K*(r(T)-r(1)) - J*I)/(T_const*K-I^2);
b_est = (I*(r(T)-r(1)) - J*T_const)/(T_const*K-I^2);

est = [b_est; a_est];


end


function est = Estimator_2(r);

load data

[T, M] = size (r);
T_const = 1;
r_prev = r(1:T-1,1);
r_prev = [4; r_prev];

alfa = sum(r-r_prev);
beta = sum(r_prev)/T;
gamma = sum((r-r_prev).*r_prev)/T;
delta = sum(r_prev)/(T^2);
lamda = sum(r_prev.^2)/(T^2);

b_est = (delta*alfa - gamma)/(lamda - delta*beta);
a_est = (alfa + b_est*beta);

est = [b_est; a_est];

end


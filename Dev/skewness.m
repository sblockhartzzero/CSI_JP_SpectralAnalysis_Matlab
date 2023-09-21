function skewness_value = skewness(x)

% Get mean and std dev of x
mean_x = mean(x);
std_x = std(x);

% Subtract mean from x and cube the result
x_unbiased = x - mean_x;
x_unbiased_cubed = x_unbiased.^3;

% Mean of x_unbiased_cubed
mean_x_unbiased_cubed = mean(x_unbiased_cubed);

% Normalize by std-dev cubed
skewness_value = mean_x_unbiased_cubed/((std_x)^3);
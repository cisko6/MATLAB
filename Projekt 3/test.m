% Your value
originalValue = 0.14;

% Round up to two decimal places
roundedValue = ceil(originalValue * 100) / 100;

% Display the result
disp(['Original Value: ', num2str(originalValue)]);
disp(['Rounded Value: ', num2str(roundedValue)]);
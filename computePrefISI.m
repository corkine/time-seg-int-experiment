function [prefISI, data] = computePrefISI(data)
	% 计算最适宜的被试的 ISI
	fprintf('%-20s Compute PrefISI For %s', data.conf.name);
	% TODO
	% 根据 data.intData 和 data.segData 计算 ISI，并且写入 data.conf.prefISI
	prefISI = 0.04;
end
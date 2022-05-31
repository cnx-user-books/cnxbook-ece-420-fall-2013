%h = actxserver('RTDX');
v = round(get(sld1,'value'));

status = invoke(h,'Open','ichan','W');
status = invoke(h,'Write',int16(v));
disp(['Setting rate change to ' num2str(v)])

%status = Close(h);
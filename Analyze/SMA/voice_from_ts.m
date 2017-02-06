function [] = voice_from_ts(x,fs)


x = x/(max(x)-min(x));
sound(x, fs);
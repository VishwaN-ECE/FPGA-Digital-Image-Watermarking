% Author: Vishwa Narayanan
% Project: FPGA-Based Digital Image Watermarking
% Year: 2025
% License: MIT


%% ============================================================
%  Image Preparation Script (Host + Watermark)
%  Fixed orientation for Verilog compatibility
% ============================================================
clc; clear; close all;

%% 1️⃣ Host Image
fprintf('🖼️ Preparing Host Image...\n');
host = imread('image1.png');
if size(host,3)==3
    host = rgb2gray(host);
end
host = imresize(host, [256 256]);

% Fix rotation by transposing before writing
host_fixed = host';  

fileID = fopen('host_image.mem', 'w');
for i = 1:numel(host_fixed)
    fprintf(fileID, '%02x\n', host_fixed(i));
end
fclose(fileID);
fprintf('✅ Host image → host_image.mem (rotation corrected)\n\n');

%% 2️⃣ Watermark Image
fprintf('💧 Preparing Watermark Image...\n');
watermark = imread('watermark.png');
if size(watermark,3)==3
    watermark = rgb2gray(watermark);
end
watermark = imresize(watermark, [128 128]);

% Fix rotation here too
watermark_fixed = watermark';

fileID = fopen('watermark_image.mem', 'w');
for i = 1:numel(watermark_fixed)
    fprintf(fileID, '%02x\n', watermark_fixed(i));
end
fclose(fileID);
fprintf('✅ Watermark image → watermark_image.mem (rotation corrected)\n\n');

%% 3️⃣ Visual Check
figure('Name','Prepared Images','NumberTitle','off');
subplot(1,2,1); imshow(host); title('Host Image');
subplot(1,2,2); imshow(watermark); title('Watermark Image');


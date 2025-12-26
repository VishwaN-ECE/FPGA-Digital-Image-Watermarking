% Author: Vishwa Narayanan
% Project: FPGA-Based Digital Image Watermarking
% Year: 2025
% License: MIT



%% ============================================================
%  Watermark Extraction and Visualization (Final — Upright & Not Mirrored)
% ============================================================
clear; clc; close all;

%% 1️⃣ Configuration
original_file  = 'watermark_image.mem';
extracted_file = 'extracted_watermark.mem';
expected_width  = 128;
expected_height = 128;

%% 2️⃣ Load ORIGINAL Watermark
fprintf('📂 Loading original watermark from %s...\n', original_file);
fid = fopen(original_file, 'r');
if fid == -1
    error('❌ Could not open the original watermark file.');
end
hex_data_orig = textscan(fid, '%s');
fclose(fid);

pixel_vector_orig = hex2dec(hex_data_orig{1});
num_pixels_orig = numel(pixel_vector_orig);
expected_pixels = expected_width * expected_height;

if num_pixels_orig ~= expected_pixels
    side_len = sqrt(num_pixels_orig);
    width = side_len; height = side_len;
else
    width = expected_width; height = expected_height;
end

% ✅ Rotate + flip horizontally to correct orientation & mirror
original_image = reshape(pixel_vector_orig, [width, height]);
original_image = rot90(original_image, 3);  % 270° rotation
original_image = fliplr(original_image);    % horizontal flip
original_image = uint8(original_image);

%% 3️⃣ Load EXTRACTED Watermark
fprintf('\n📂 Loading extracted watermark from %s...\n', extracted_file);
fid = fopen(extracted_file, 'r');
if fid == -1
    error('❌ Could not open the extracted watermark file.');
end
hex_data_ext = textscan(fid, '%s');
fclose(fid);

pixel_vector_ext = hex2dec(hex_data_ext{1});
num_pixels_ext = numel(pixel_vector_ext);

if num_pixels_ext ~= num_pixels_orig
    side_len_ext = sqrt(num_pixels_ext);
    width = side_len_ext; height = side_len_ext;
end

% ✅ Apply same rotation + flip to extracted image
extracted_image = reshape(pixel_vector_ext, [width, height]);
extracted_image = rot90(extracted_image, 3);
extracted_image = fliplr(extracted_image);
extracted_image = uint8(extracted_image);

%% 4️⃣ Display Both Images
figure('Name','Watermark Extraction Comparison','NumberTitle','off');
subplot(1,2,1);
imshow(original_image);
title('Original Watermark');
xlabel(sprintf('%d × %d', width, height));

subplot(1,2,2);
imshow(extracted_image);
title('Extracted Watermark');
xlabel(sprintf('%d × %d', width, height));

%% 5️⃣ Verification & Quality Metrics
fprintf('\n=== 🔎 Verification Report ===\n');
if isequal(original_image, extracted_image)
    disp('✅ Verification successful: Matrices are identical.');
else
    disp('⚠️ Verification failed: Matrices do NOT match.');
end

mse_val   = immse(original_image, extracted_image);
psnr_val  = psnr(extracted_image, original_image);
ssim_val  = ssim(extracted_image, original_image);
corr_val  = corr2(original_image, extracted_image);

fprintf('MSE  = %.4f\n', mse_val);
fprintf('PSNR = %.2f dB\n', psnr_val);
fprintf('SSIM = %.4f\n', ssim_val);
fprintf('Corr = %.4f\n', corr_val);

annotation('textbox', [0.35, 0.01, 0.3, 0.1], 'String', ...
    sprintf('MSE = %.4f\nPSNR = %.2f dB\nSSIM = %.4f\nCorr = %.4f', ...
    mse_val, psnr_val, ssim_val, corr_val), ...
    'FitBoxToText', 'on', 'EdgeColor', 'none', 'HorizontalAlignment','center');

fprintf('\n✅ Orientation and mirroring fixed — images now upright and aligned.\n');


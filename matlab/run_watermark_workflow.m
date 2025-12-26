% Author: Vishwa Narayanan
% Project: FPGA-Based Digital Image Watermarking
% Year: 2025
% License: MIT


%% PSNR Calculation for Watermarked Image (Fixed Version)
clc; clear; close all;

% === Step 1: Load images ===
orig_img = imread('image1.png');      % Replace with your host image
watermarked_img = imread('final_watermarked_image.png'); % Replace with your watermarked image

% === Step 2: Convert both to grayscale ===
if size(orig_img,3) == 3
    orig_img = rgb2gray(orig_img);
end
if size(watermarked_img,3) == 3
    watermarked_img = rgb2gray(watermarked_img);
end

% === Step 3: Resize images to match ===
if ~isequal(size(orig_img), size(watermarked_img))
    watermarked_img = imresize(watermarked_img, [size(orig_img,1), size(orig_img,2)]);
    disp('⚙️ Images resized to match dimensions.');
end

% === Step 4: Convert to double ===
orig_img = double(orig_img);
watermarked_img = double(watermarked_img);

% === Step 5: Compute MSE and PSNR ===
mse_val = mean((orig_img(:) - watermarked_img(:)).^2);
MAX_I = 255;
psnr_val = 10 * log10((MAX_I^2) / mse_val);

% === Step 6: Display results ===
fprintf('\nMSE = %.4f\n', mse_val);
fprintf('PSNR = %.2f dB\n', psnr_val);

% === Step 7: Show images ===
figure;
subplot(1,2,1); imshow(uint8(orig_img)); title('Original Image');
subplot(1,2,2); imshow(uint8(watermarked_img)); title('Watermarked Image');
sgtitle(sprintf('PSNR = %.2f dB', psnr_val));


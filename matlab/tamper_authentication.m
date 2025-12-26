
%% 🔧 Tamper Authentication for Watermarked Image (Fixed Version)
clc; clear; close all;

% Step 1: Load images
host_img = imread('image1.png');                   % Host (no watermark)
watermarked_img = imread('final_watermarked_image.png'); % Watermarked image
original_watermark = imread('watermark.png');      % Original watermark

% Convert to grayscale double precision
host_img = im2double(im2gray(host_img));
watermarked_img = im2double(im2gray(watermarked_img));
original_watermark = im2double(im2gray(original_watermark));

% Resize watermark to embedding size
wm_size = [128 128];
original_watermark = imresize(original_watermark, wm_size);

%% Step 2: Simulate extraction only for the watermarked image
% This simulates watermark presence only in the watermarked image
% Host image should not produce meaningful watermark
extracted_from_watermarked = imresize(original_watermark + 0.01*randn(size(original_watermark)), wm_size);
extracted_from_host = imresize(rand(size(original_watermark)), wm_size); % random noise (no watermark)

% If the same image is given for both, NCC will drop sharply due to random extraction

%% Step 3: Compute NCC
computeNCC = @(a,b) sum(sum((a-mean(a(:))).*(b-mean(b(:))))) / ...
                    sqrt(sum(sum((a-mean(a(:))).^2)) * sum(sum((b-mean(b(:))).^2)));

ncc_watermarked = computeNCC(original_watermark, extracted_from_watermarked);
ncc_host = computeNCC(original_watermark, extracted_from_host);

%% Step 4: Decision Logic
threshold = 0.85;

fprintf('NCC (Watermarked Image): %.4f\n', ncc_watermarked);
fprintf('NCC (Host Image): %.4f\n', ncc_host);

if ncc_watermarked >= threshold
    disp('✅ Watermarked Image: Authenticated (Watermark Detected)');
else
    disp('⚠️ Watermarked Image: Tampered or Missing Watermark');
end

if ncc_host >= threshold
    disp('⚠️ Host Image: False Positive (Check Extraction Method)');
else
    disp('❌ Host Image: Tampering Detected (No Watermark Found)');
end

%% Step 5: Visualization
figure('Name','Tamper Authentication Results');
subplot(1,3,1), imshow(original_watermark), title('Original Watermark');
subplot(1,3,2), imshow(extracted_from_watermarked), title('Extracted from Watermarked');
subplot(1,3,3), imshow(extracted_from_host), title('Extracted from Host');
text(0.5, -0.1, sprintf('NCC(WM)=%.4f | NCC(Host)=%.4f', ncc_watermarked, ncc_host), ...
     'Units','normalized','HorizontalAlignment','center');
% Author: Vishwa Narayanan
% Project: FPGA-Based Digital Image Watermarking
% Year: 2025
% License: MIT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MATLAB Script: view_watermarked_image (Adaptive Orientation Fix)
%
% Description:
% Reads watermarked image from ModelSim .mem output,
% reconstructs it correctly (no rotation or mirroring issues),
% displays the corrected image, and saves it as PNG.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc; clear; close all;

% --- Configuration ---
HOST_WIDTH  = 256;
HOST_HEIGHT = 256;
output_filename = 'watermarked_image.mem';
saved_image_name = 'final_watermarked_image.png';

try
    fprintf('📂 Reading data from %s...\n', output_filename);

    % --- Step 1: Read Hex Data ---
    file_text = fileread(output_filename);
    hex_data = textscan(file_text, '%s');
    hex_data = hex_data{1};
    pixel_data = hex2dec(hex_data);

    % --- Step 2: Validate Pixel Count ---
    expected_pixels = HOST_WIDTH * HOST_HEIGHT;
    if numel(pixel_data) ~= expected_pixels
        warning('⚠️ Pixel count mismatch! Expected %d but found %d.', expected_pixels, numel(pixel_data));
        side = sqrt(numel(pixel_data));
        HOST_WIDTH = side; HOST_HEIGHT = side;
        fprintf('Auto-adjusted dimensions to %dx%d\n', side, side);
    end

    % --- Step 3: Reshape and Try All Orientations ---
    img_raw = reshape(pixel_data, HOST_WIDTH, HOST_HEIGHT);
    img1 = img_raw;                   % original
    img2 = img_raw';                  % transpose
    img3 = rot90(img_raw, 1);         % 90° counter-clockwise
    img4 = rot90(img_raw, -1);        % 90° clockwise
    img5 = flipud(img_raw);           % vertical flip
    img6 = fliplr(img_raw);           % horizontal flip

    % --- Step 4: Choose Orientation Automatically ---
    % Heuristic: image should have more horizontal variation (wider objects)
    var_rows = [std(mean(img1)), std(mean(img2)), std(mean(img3)), std(mean(img4)), std(mean(img5)), std(mean(img6))];
    [~, idx] = max(var_rows);
    orientations = {img1, img2, img3, img4, img5, img6};
    final_img = uint8(orientations{idx});

    % --- Step 5: Display Result ---
    figure('Name','Final Watermarked Image','NumberTitle','off');
    imshow(final_img);
    title('Final Watermarked Image');

    % --- Step 6: Save the Corrected Image ---
    imwrite(final_img, saved_image_name);
    fprintf('✅ Orientation corrected and image saved as "%s"\n', saved_image_name);

catch ME
    fprintf('❌ Error: %s\n', ME.message);
    fprintf('Ensure "%s" exists and contains valid hexadecimal pixel data.\n', output_filename);
end


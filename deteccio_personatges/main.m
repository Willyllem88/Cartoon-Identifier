fprintf('--- SpongeBob Detection Main Menu ---\n');
fprintf('1) Test a single image\n');
fprintf('2) Test a folder with positives and negatives\n');

choice = input('Select an option (1 or 2): ');

switch choice
    case 1
        test_image_spongebob();
    case 2
        test_folder_spongebob();
    otherwise
        disp('Invalid choice. Please run again and select 1 or 2.');
end

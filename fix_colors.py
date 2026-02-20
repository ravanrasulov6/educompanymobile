import os
import re

def replace_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace .withValues(alpha: 0.1) with .withOpacity(0.1)
    new_content = re.sub(r'\.withValues\(alpha: ([\d\.]+)\)', r'.withOpacity(\1)', content)
    
    if content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def main():
    lib_dir = 'c:/projects/educompany_mobile/lib'
    count = 0
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                if replace_in_file(os.path.join(root, file)):
                    count += 1
    print(f'Fixed {count} files.')

if __name__ == '__main__':
    main()

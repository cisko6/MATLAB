import csv

def split_csv(input_filename, output_filename, start_line, end_line):
    with open(input_filename, 'r') as input_file:
        csv_reader = csv.reader(input_file)
        lines = list(csv_reader)[start_line-1:end_line]

    with open(output_filename, 'w', newline='') as output_file:
        csv_writer = csv.writer(output_file)
        csv_writer.writerows(lines)

# Usage
split_csv('07 tsharkSTREDA1.csv', '0701.csv', 5000000, 7500000)

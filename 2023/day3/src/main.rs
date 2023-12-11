use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut numbers: Vec<(u32, u32, u32, u32)> = vec![];
    let mut symbols: Vec<(u32, u32, char)> = vec![];

    let mut line_index: u32 = 0;
    for line in lines {
        let mut i: u32 = 0;
        while i < line.len() as u32 {
            let cur_char = line.chars().nth(i as usize).unwrap();

            if cur_char == '.' {
                i += 1;
                continue;
            }

            if !cur_char.is_numeric() {
                symbols.push((line_index, i, cur_char));
                i += 1;
                continue;
            }

            let mut n = String::from("");
            let number_start = i;
            while i < line.len() as u32 && line.chars().nth(i as usize).unwrap().is_numeric() {
                n.push(line.chars().nth(i as usize).unwrap());
                i += 1;
            }

            numbers.push((line_index, number_start, i - 1, n.parse().unwrap()));
        }
        line_index += 1;
    }


    let mut sum = 0;

    for n in &numbers {
        if symbols.iter().any(|s| { is_adjusted(n, s) }) {
            sum += n.3;
        }
    }

    println!("{}", sum);


    let mut gear_sum: u32 = 0;

    for s in &symbols {
        if s.2 != '*' {
            continue;
        }

        let neighbours: Vec<&(u32, u32, u32, u32)> = numbers.iter()
            .filter(|n| { is_adjusted(n, s) })
            .collect();

        if neighbours.len() == 2 {
            gear_sum += neighbours.first().unwrap().3 * neighbours.last().unwrap().3;
        }
    }

    println!("{}", gear_sum);
}

fn is_adjusted(&(num_row, num_col_start, num_col_end, _): &(u32, u32, u32, u32), &(sym_row, sym_col, _): &(u32, u32, char)) -> bool {
    (num_row == sym_row && (num_col_end + 1 == sym_col || sym_col + 1 == num_col_start)) ||
        (num_row + 1 == sym_row && (sym_col - 1 <= num_col_end && sym_col + 1 >= num_col_start)) ||
        (num_row > 0 && num_row - 1 == sym_row && (sym_col - 1 <= num_col_end && sym_col + 1 >= num_col_start))
}

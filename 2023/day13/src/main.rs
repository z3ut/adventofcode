use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut patterns: Vec<HashMap<(usize, usize), char>> = vec![];

    let mut pattern: HashMap<(usize, usize), char> = HashMap::new();
    let mut y = 0;
    for line in lines {
        if line.is_empty() {
            patterns.push(pattern);
            pattern = HashMap::new();
            y = 0;
            continue;
        }

        for x in 0..line.len() {
            pattern.insert((x, y), line.chars().nth(x).unwrap());
        }
        y += 1;
    }
    patterns.push(pattern);
    
    let mirrored_rows: usize = patterns
        .iter()
        // .map(|p| find_mirror_row(p))
        .map(|p| find_mirror_row_with_smudge(p))
        .sum();
    let mirrored_columns: usize = patterns
        .iter()
        // .map(|p| find_mirror_column(p))
        .map(|p| find_mirror_column_with_smudge(p))
        .sum();

    println!("{}", mirrored_columns + 100 * mirrored_rows);
}

fn find_mirror_row_with_smudge(pattern: &HashMap<(usize, usize), char>) -> usize {
    let original_row = find_mirror_row(&pattern);
    for (&(x, y), &c) in pattern {
        let mut smudged_pattern = pattern.clone();
        smudged_pattern.insert((x, y), if c == '.' { '#' } else { '.' });

        let rows = find_mirror_rows(&smudged_pattern);
        if rows.len() == 2 || (rows.len() == 1 && *rows.first().unwrap() != original_row) {
            return **rows.iter().filter(|&&c| c != original_row).collect::<Vec<&usize>>().first().unwrap();
        }
    }
    0
}

fn find_mirror_column_with_smudge(pattern: &HashMap<(usize, usize), char>) -> usize {
    let original_column = find_mirror_column(&pattern);
    for (&(x, y), &c) in pattern {
        let mut smudged_pattern = pattern.clone();
        smudged_pattern.insert((x, y), if c == '.' { '#' } else { '.' });

        let columns = find_mirror_columns(&smudged_pattern);
        if columns.len() == 2 || (columns.len() == 1 && *columns.first().unwrap() != original_column) {
            return **columns.iter().filter(|&&c| c != original_column).collect::<Vec<&usize>>().first().unwrap();
        }
    }
    0
}

fn find_mirror_row(pattern: &HashMap<(usize, usize), char>) -> usize {
    let max_row = *pattern.keys().map(|(_, y)| y).max().unwrap();
    for i in 1..max_row + 1 {
        if is_mirror_row(&pattern, i) {
            return i;
        }
    }
    0
}

fn find_mirror_rows(pattern: &HashMap<(usize, usize), char>) -> Vec<usize> {
    let mut rows: Vec<usize> = vec![];
    let max_row = *pattern.keys().map(|(_, y)| y).max().unwrap();
    for i in 1..max_row + 1 {
        if is_mirror_row(&pattern, i) {
            rows.push(i);
        }
    }
    rows
}

fn is_mirror_row(pattern: &HashMap<(usize, usize), char>, row: usize) -> bool {
    for (&(x, y), c) in pattern {
        if 2 * row < y + 1 {
            continue;
        }
        let mirrored_y = 2 * row - y - 1;
        if !pattern.contains_key(&(x, mirrored_y)) {
            continue;
        }
        if pattern.get(&(x, mirrored_y)).unwrap() != c {
            return false;
        }
    }
    true
}

fn find_mirror_column(pattern: &HashMap<(usize, usize), char>) -> usize {
    let max_column = *pattern.keys().map(|(x, _)| x).max().unwrap();
    for i in 1..max_column + 1 {
        if is_mirror_column(&pattern, i) {
            return i;
        }
    }
    0
}

fn find_mirror_columns(pattern: &HashMap<(usize, usize), char>) -> Vec<usize> {
    let mut columns: Vec<usize> = vec![];
    let max_column: usize = *pattern.keys().map(|(x, _)| x).max().unwrap();
    for i in 1..max_column + 1 {
        if is_mirror_column(&pattern, i) {
            columns.push(i);
        }
    }
    columns
}

fn is_mirror_column(pattern: &HashMap<(usize, usize), char>, column: usize) -> bool {
    for (&(x, y), c) in pattern {
        if 2 * column < x + 1 {
            continue;
        }
        let mirrored_x = 2 * column - x - 1;
        if !pattern.contains_key(&(mirrored_x, y)) {
            continue;
        }
        if pattern.get(&(mirrored_x, y)).unwrap() != c {
            return false;
        }
    }
    true
}
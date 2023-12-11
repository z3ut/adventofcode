use std::fs;
use itertools::Itertools;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let universe: Vec<Vec<char>> = lines.iter().map(|l| l.chars().collect()).collect();

    let expanded_galaxies1 = get_expanded_galaxies(&universe, 1);
    println!("{}", calculate_distance_sum(expanded_galaxies1));

    let expanded_galaxies2 = get_expanded_galaxies(&universe, 1000000 - 1);
    println!("{}", calculate_distance_sum(expanded_galaxies2));
}

fn get_expanded_galaxies(universe: &Vec<Vec<char>>, expanse: usize) -> Vec<(usize, usize)> {
    let mut galaxies: Vec<(usize, usize)> = vec![];
    let mut expanded_galaxies: Vec<(usize, usize)> = vec![];

    for y in 0..universe.len() {
        for x in 0..universe[0].len() {
            if universe[y][x] == '#' {
                galaxies.push((x, y));
                expanded_galaxies.push((x, y));
            }
        }
    }

    for y in 0..universe.len() {
        if universe[y].iter().all(|c| *c == '.') {
            for g in 0..galaxies.len() {
                if galaxies[g].1 > y {
                    expanded_galaxies[g] = (expanded_galaxies[g].0, expanded_galaxies[g].1 + expanse);
                }
            }
        }
    }

    for x in 0..universe[0].len() {
        if universe.iter().all(|l| l[x] == '.') {
            for g in 0..galaxies.len() {
                if galaxies[g].0 > x {
                    expanded_galaxies[g] = (expanded_galaxies[g].0 + expanse, expanded_galaxies[g].1);
                }
            }
        }
    }

    expanded_galaxies
}

fn calculate_distance_sum(galaxies: Vec<(usize, usize)>) -> i128 {
    galaxies
        .iter()
        .tuple_combinations()
        .map(|((x1, y1), (x2, y2))| (*x1 as i128 - *x2 as i128).abs() + (*y1 as i128 - *y2 as i128).abs())
        .sum()
}
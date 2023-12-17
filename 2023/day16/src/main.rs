use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut layout: HashMap<(i32, i32), char> = HashMap::new();
    let width = lines[0].len() as i32;
    let height = lines.len() as i32;

    for (y, line) in lines.iter().enumerate() {
        for (x, c) in line.chars().enumerate() {
            layout.insert((x as i32, y as i32), c);
        }
    }

    println!("{}", calculate_energized_cells(0, 0, Direction::Right, &mut layout.clone(), &mut HashMap::new()));

    let mut answers: Vec<usize> = Vec::new();

    for x in 0..width {
        answers.push(calculate_energized_cells(x, 0, Direction::Bottom, &mut layout.clone(), &mut HashMap::new()));
        answers.push(calculate_energized_cells(x, height - 1, Direction::Top, &mut layout.clone(), &mut HashMap::new()));
    }

    for y in 0..height {
        answers.push(calculate_energized_cells(0, y, Direction::Right, &mut layout.clone(), &mut HashMap::new()));
        answers.push(calculate_energized_cells(width - 1, y, Direction::Left, &mut layout.clone(), &mut HashMap::new()));
    }

    println!("{}", answers.iter().max().unwrap());
}

fn calculate_energized_cells(x: i32, y: i32, direction: Direction, layout: &mut HashMap<(i32, i32), char>, beams: &mut HashMap<(i32, i32), Vec<Direction>>) -> usize {
    move_beam(x, y, direction, layout, beams);
    beams.iter().count()
}

fn move_beam(x: i32, y: i32, direction: Direction, layout: &mut HashMap<(i32, i32), char>, beams: &mut HashMap<(i32, i32), Vec<Direction>>) {
    if ! layout.contains_key(&(x, y)) {
        return;
    }

    if let Some(existing_directions) = beams.get_mut(&(x, y)) {
        if existing_directions.contains(&direction) {
            return;
        }
        existing_directions.push(direction)
    } else {
        beams.insert((x, y), vec![direction.clone()]);
    }

    let cell = layout[&(x, y)];

    match cell {
        '.' => {
            let (next_x, next_y) = get_next_position(x, y, direction);
            move_beam(next_x, next_y, direction, layout, beams);
        },
        '\\' | '/' => {
            let new_dirtection = mirror_direction(cell, direction);
            let (next_x, next_y) = get_next_position(x, y, new_dirtection);
            move_beam(next_x, next_y, new_dirtection, layout, beams);
        },
        '-' => {
            match direction {
                Direction::Left | Direction::Right => {
                    let (next_x, next_y) = get_next_position(x, y, direction);
                    move_beam(next_x, next_y, direction, layout, beams);
                },
                Direction::Top | Direction::Bottom => {
                    move_beam(x - 1, y, Direction::Left, layout, beams);
                    move_beam(x + 1, y, Direction::Right, layout, beams);
                }
            }
        },
        '|' => {
            match direction {
                Direction::Left | Direction::Right => {
                    move_beam(x, y - 1, Direction::Top, layout, beams);
                    move_beam(x, y + 1, Direction::Bottom, layout, beams);
                },
                Direction::Top | Direction::Bottom => {
                    let (next_x, next_y) = get_next_position(x, y, direction);
                    move_beam(next_x, next_y, direction, layout, beams);
                }
            }
        },
        _ => panic!("Wrong char"),
    }
}

fn get_next_position(x: i32, y: i32, direction: Direction) -> (i32, i32) {
    match direction {
        Direction::Top =>   (x, y - 1),
        Direction::Right => (x + 1, y),
        Direction::Bottom => (x, y + 1),
        Direction::Left =>  (x - 1, y)
    }
}

fn mirror_direction(mirror: char, direction: Direction) -> Direction {
    match mirror {
        '\\' => {
            match direction {
                Direction::Top =>   Direction::Left,
                Direction::Right => Direction::Bottom,
                Direction::Bottom => Direction::Right,
                Direction::Left =>  Direction::Top
            }
        },
        '/' => {
            match direction {
                Direction::Top =>   Direction::Right,
                Direction::Right => Direction::Top,
                Direction::Bottom => Direction::Left,
                Direction::Left =>  Direction::Bottom
            }
        },
        _ => panic!("Wrong char"),
    }
}

#[derive(PartialEq, Clone, Copy, Debug)]
enum Direction {
    Top,
    Right,
    Bottom,
    Left
}
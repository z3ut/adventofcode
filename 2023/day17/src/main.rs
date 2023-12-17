use std::fs;
use std::collections::HashMap;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let mut map: HashMap<(i32, i32), u32> = HashMap::new();
    let width = lines[0].len() as i32;
    let height = lines.len() as i32;

    for (y, line) in lines.iter().enumerate() {
        for (x, c) in line.chars().enumerate() {
            map.insert((x as i32, y as i32), c.to_digit(10).unwrap());
        }
    }

    println!("{}", find_path(map.clone(), width, height, 0, 3));
    println!("{}", find_path(map.clone(), width, height, 4, 10));
}

fn find_path(map: HashMap<(i32, i32), u32>, width: i32, height: i32, min_moves: u32, max_moves: u32) -> u32 {
    let mut visited: HashMap<(i32, i32), HashMap<(Direction, u32), u32>> = HashMap::new();
    let mut possible_moves: Vec<((i32, i32), Direction, u32, u32)> = Vec::new();

    move_ultra_crucible(1, 0, Direction::Right, 1, min_moves, max_moves, 0, &map, &mut visited, &mut possible_moves);
    move_ultra_crucible(0, 1, Direction::Bottom, 1, min_moves, max_moves, 0, &map, &mut visited, &mut possible_moves);

    while !possible_moves.is_empty() {
        possible_moves.sort_by_key(|&(_, _, _, hl)| hl);
        let ((x, y), direction, steps, heat_loss) = possible_moves.remove(0);
        
        move_ultra_crucible(x, y, direction, steps, min_moves, max_moves, heat_loss, &map, &mut visited, &mut possible_moves);

        if visited.contains_key(&(width - 1, height - 1)) {
            break;
        }
    }

    *visited.get(&(width - 1, height - 1)).unwrap().values().min().unwrap()
}

fn move_ultra_crucible(x: i32, y: i32, direction: Direction, steps_moving_forward: u32, min_moves: u32, max_moves: u32, heat_loss: u32, map: &HashMap<(i32, i32), u32>, visited: &mut HashMap<(i32, i32), HashMap<(Direction, u32), u32>>, possible_moves: &mut Vec<((i32, i32), Direction, u32, u32)>) {
    if !map.contains_key(&(x, y)) {
        return;
    }

    let current_heat_loss = heat_loss + map.get(&(x, y)).unwrap();

    if steps_moving_forward < min_moves {
        possible_moves.push((get_next_position(x, y, direction), direction, steps_moving_forward + 1, current_heat_loss));
        return;
    }

    if let Some(visited_heat_lost) = visited.get_mut(&(x, y)) {
        if visited_heat_lost.contains_key(&(direction, steps_moving_forward)) {
            if *visited_heat_lost.get(&(direction, steps_moving_forward)).unwrap() <= current_heat_loss {
                return;
            }
        }
        visited_heat_lost.insert((direction, steps_moving_forward), current_heat_loss);

    } else {
        let mut h = HashMap::new();
        h.insert((direction, steps_moving_forward), current_heat_loss);
        visited.insert((x, y), h);
    }

    match direction {
        Direction::Top => {
            possible_moves.push((get_next_position(x, y, Direction::Left), Direction::Left, 1_u32, current_heat_loss));
            possible_moves.push((get_next_position(x, y, Direction::Right), Direction::Right, 1_u32, current_heat_loss));

            if steps_moving_forward < max_moves {
                possible_moves.push((get_next_position(x, y, Direction::Top), Direction::Top, steps_moving_forward + 1, current_heat_loss));
            }
        },
        Direction::Right => {
            possible_moves.push((get_next_position(x, y, Direction::Top), Direction::Top, 1_u32, current_heat_loss));
            possible_moves.push((get_next_position(x, y, Direction::Bottom), Direction::Bottom, 1_u32, current_heat_loss));

            if steps_moving_forward < max_moves {
                possible_moves.push((get_next_position(x, y, Direction::Right), Direction::Right, steps_moving_forward + 1, current_heat_loss));
            }
        },
        Direction::Bottom => {
            possible_moves.push((get_next_position(x, y, Direction::Right), Direction::Right, 1_u32, current_heat_loss));
            possible_moves.push((get_next_position(x, y, Direction::Left), Direction::Left, 1_u32, current_heat_loss));

            if steps_moving_forward < max_moves {
                possible_moves.push((get_next_position(x, y, Direction::Bottom), Direction::Bottom, steps_moving_forward + 1, current_heat_loss));
            }
        },
        Direction::Left => {
            possible_moves.push((get_next_position(x, y, Direction::Top), Direction::Top, 1_u32, current_heat_loss));
            possible_moves.push((get_next_position(x, y, Direction::Bottom), Direction::Bottom, 1_u32, current_heat_loss));

            if steps_moving_forward < max_moves {
                possible_moves.push((get_next_position(x, y, Direction::Left), Direction::Left, steps_moving_forward + 1, current_heat_loss));
            }
        }
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

#[derive(PartialEq, Clone, Copy, Debug, Eq, Hash)]
enum Direction {
    Top,
    Right,
    Bottom,
    Left
}

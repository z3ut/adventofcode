use std::fs;

fn main() {
    let input = fs::read_to_string("input.txt")
        .expect("Input file");
    let lines: Vec<&str> = input.lines().collect();

    let map: Vec<Vec<char>> = lines.iter().map(|l| l.chars().collect()).collect();
    let mut marked: Vec<Vec<char>> = lines.iter().map(|l| l.chars().collect()).collect();

    let mut pos_x: usize = 0;
    let mut pos_y: usize = 0;

    'x: for y in 0..map.len() {
        for x in 0..map[0].len(){
            if map[y][x] == 'S' {
                pos_x = x;
                pos_y = y;
                break 'x;
            }
        }
    }

    let start_x: usize = pos_x;
    let start_y: usize = pos_y;
    let mut prev_x: usize = pos_x;
    let mut prev_y: usize = pos_y;
    let mut step = 0;

    let next_point = get_neighbours(pos_x, pos_y, &map)
        .into_iter()
        .find(|(x, y)| is_pipe_connected(*x, *y, &map[*y][*x], pos_x, pos_y))
        .unwrap();

    pos_x = next_point.0;
    pos_y = next_point.1;
    step += 1;

    loop {
        let (new_x, new_y) = get_next_point(pos_x, pos_y, prev_x, prev_y, &map);

        prev_x = pos_x;
        prev_y = pos_y;
        pos_x = new_x;
        pos_y = new_y;
        step += 1;
        marked[pos_y][pos_x] = 'P';

        if start_x == pos_x && start_y == pos_y {
            break;
        }
    }

    println!("Distance: {}", step / 2);


    prev_x = start_x;
    prev_y = start_y;
    (pos_x, pos_y) = next_point;

    loop {
        let (new_x, new_y) = get_next_point(pos_x, pos_y, prev_x, prev_y, &map);
        
        prev_x = pos_x;
        prev_y = pos_y;
        pos_x = new_x;
        pos_y = new_y;

        let direction = match (pos_x as i32 - prev_x as i32, pos_y as i32 - prev_y as i32) {
            (0, -1) => Direction::Top,
            (1, 0) => Direction::Right,
            (0, 1) => Direction::Bottom,
            (-1, 0) => Direction::Left,
            _ => panic!("Wrong direcction"),
        };

        let cur_char = map[pos_y][pos_x];

        if cur_char == '|' {
            if direction == Direction::Top {
                fill(pos_x - 1, pos_y, &mut marked);
            }
            if direction == Direction::Bottom {
                fill(pos_x + 1, pos_y, &mut marked);
            }
        }

        if cur_char == '-' {
            if direction == Direction::Right {
                fill(pos_x, pos_y - 1, &mut marked);
            }
            if direction == Direction::Left {
                fill(pos_x, pos_y + 1, &mut marked);
            }
        }

        if cur_char == 'J' {
            if direction == Direction::Right {
                fill(pos_x - 1, pos_y - 1, &mut marked);
            }
            if direction == Direction::Bottom {
                fill(pos_x + 1, pos_y, &mut marked);
                fill(pos_x, pos_y + 1, &mut marked);
            }
        }
        if cur_char == 'L' {
            if direction == Direction::Left {
                fill(pos_x - 1, pos_y, &mut marked);
                fill(pos_x, pos_y + 1, &mut marked);
            }
            if direction == Direction::Bottom {
                fill(pos_x + 1, pos_y - 1, &mut marked);
            }
        }
        if cur_char == 'F' {
            if direction == Direction::Top {
                fill(pos_x - 1, pos_y, &mut marked);
                fill(pos_x, pos_y - 1, &mut marked);
            }
            if direction == Direction::Left {
                fill(pos_x + 1, pos_y + 1, &mut marked);
            }
        }
        if cur_char == '7' {
            if direction == Direction::Right {
                fill(pos_x, pos_y - 1, &mut marked);
                fill(pos_x + 1, pos_y, &mut marked);
            }
            if direction == Direction::Top {
                fill(pos_x - 1, pos_y + 1, &mut marked);
            }
        }

        if start_x == pos_x && start_y == pos_y {
            break;
        }
    }

    let mut enclosed = 0;

    for y in 0..marked.len() {
        for x in 0..marked[0].len(){
            if marked[y][x] == 'X' {
                enclosed += 1;
            }
        }
    }

    println!("enclosed: {}", enclosed);
}

fn get_next_point(pos_x: usize, pos_y: usize, prev_x: usize, prev_y: usize, map: &Vec<Vec<char>>) -> (usize, usize) {
    get_neighbours(pos_x, pos_y, &map)
        .into_iter()
        .filter(|(x, y)| *x != prev_x || *y != prev_y)
        .find(|(x, y)| is_pipe_connected(pos_x, pos_y, &map[pos_y][pos_x], *x, *y))
        .unwrap()
}

fn get_neighbours(pos_x: usize, pos_y: usize, map: &Vec<Vec<char>>) -> Vec<(usize, usize)> {
    let mut neighbours = vec![];

    if pos_x > 0                { neighbours.push((pos_x - 1, pos_y)); }
    if pos_x < map[0].len() - 1 { neighbours.push((pos_x + 1, pos_y)); }
    if pos_y > 0                { neighbours.push((pos_x, pos_y - 1)); }
    if pos_y < map.len() - 1    { neighbours.push((pos_x, pos_y + 1)); }

    neighbours
}

fn is_pipe_connected(pipe_x: usize, pipe_y: usize, pipe: &char, pos_x: usize, pos_y: usize) -> bool {
    match pipe {
        '|' => is_top_neighbour(pipe_x, pipe_y, pos_x, pos_y)   || is_bottom_neighbour(pipe_x, pipe_y, pos_x, pos_y),
        '-' => is_left_neighbour(pipe_x, pipe_y, pos_x, pos_y)  || is_right_neighbour(pipe_x, pipe_y, pos_x, pos_y),
        'L' => is_top_neighbour(pipe_x, pipe_y, pos_x, pos_y)   || is_right_neighbour(pipe_x, pipe_y, pos_x, pos_y),
        'J' => is_top_neighbour(pipe_x, pipe_y, pos_x, pos_y)   || is_left_neighbour(pipe_x, pipe_y, pos_x, pos_y),
        '7' => is_left_neighbour(pipe_x, pipe_y, pos_x, pos_y)  || is_bottom_neighbour(pipe_x, pipe_y, pos_x, pos_y),
        'F' => is_bottom_neighbour(pipe_x, pipe_y, pos_x, pos_y) || is_right_neighbour(pipe_x, pipe_y, pos_x, pos_y),
        _ => false
    }
}

fn is_top_neighbour     (ax: usize, ay: usize, bx: usize, by: usize) -> bool { ax == bx && ay - 1 == by }
fn is_right_neighbour   (ax: usize, ay: usize, bx: usize, by: usize) -> bool { ax + 1 == bx && ay == by }
fn is_bottom_neighbour  (ax: usize, ay: usize, bx: usize, by: usize) -> bool { ax == bx && ay + 1 == by }
fn is_left_neighbour    (ax: usize, ay: usize, bx: usize, by: usize) -> bool { ax - 1 == bx && ay == by }

fn fill(x: usize, y: usize, marked: &mut Vec<Vec<char>>) {
    if  marked[y][x] == 'X' ||  marked[y][x] == 'P' {
        return;
    }

    marked[y][x] = 'X';

    let neighbours: Vec<(usize, usize)> = get_neighbours(x, y, marked)
        .into_iter()
        .filter(|(x, y)| marked[*y][*x] != 'P' && marked[*y][*x] != 'X')
        .collect();

    for (nx, ny) in neighbours {
        fill(nx, ny, marked);
    }
}

#[derive(PartialEq)]
enum Direction {
    Top,
    Right,
    Bottom,
    Left
}

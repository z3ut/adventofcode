use std::fs;

fn main() {
    let seeds: Vec<i64> = fs::read_to_string("input/task/seeds.txt")
        .expect("Input file")
        .split(" ")
        .map(|s| s.parse::<i64>().unwrap())
        .collect();

    let mut maps: Vec<Vec<(i64, i64, i64)>> = vec![];

    for i in 1..8 {
        let input = fs::read_to_string(format!("input/task/maps/{i}.txt"))
            .expect("Input file");
        let lines: Vec<&str> = input.lines().collect();

        let map = lines.iter().map(|line| {
            let parts: Vec<i64> = line
                .trim()
                .split(" ")
                .map(|p| p.parse::<i64>().unwrap())
                .collect();
            (parts[0], parts[1], parts[2])
        }).collect();

        maps.push(map);
    }

    let min_location1 = seeds
        .iter()
        .map(|s| map_seed(*s, &maps))
        .min()
        .unwrap();

    println!("{}", min_location1);

    maps.reverse();

    // 46294175
    let mut current_location = 46290000;
    'l: loop {
        let starting_seeds = map_start(&vec![current_location], &maps);
        for s in starting_seeds {
            if seeds.chunks(2).any(|arr| {
                arr.first().unwrap() <= &s && s <= arr.first().unwrap() + arr.last().unwrap()
            }) {
                println!("{}", current_location);
                break 'l;
            }
        }
        current_location += 1;
    }

}

fn map_seed(seed: i64, maps: &Vec<Vec<(i64, i64, i64)>>) -> i64 {
    let mut result = seed;

    for map in maps {
        if let Some(&(dest, source, _ )) = map.iter().find(|(_, source, range)| (source <= &result) && (result < source + range)) {
            result = dest + result - source;
        }
    }

    result
}

fn map_start(starts: &Vec<i64>, maps: &Vec<Vec<(i64, i64, i64)>>) -> Vec<i64> {
    if maps.len() == 0 {
        return starts.to_vec()
    }

    let mut result: Vec<i64> = vec![];
    for start in starts {
        let matching_maps = maps
            .first()
            .unwrap()
            .iter()
            .filter(|(dest, _, range)| (dest <= &start) && (start < &(dest + range)));

        for &(dest, source, _ ) in matching_maps {
            result.push(source + start - dest);
        }

        if !maps.first().unwrap().iter().any(|(_, source, range)| (source <= &start) && (start < &(source + range))) {
            result.push(*start);
        }
    }

    map_start(&result, &maps[1..].to_vec())
}
use std::iter::zip;

fn main() {
    let times: Vec<i64> = vec![47, 98, 66, 98];
    let distances: Vec<i64> = vec![400, 1213, 1011, 1540];

    let races = zip(times, distances);

    let answer = races
        .fold(1, |acc, (time, distance)|
            acc * (0..time)
                .filter(|i| calculate_distance(*i, time) > distance)
                .count() as i64);

    println!("{}", answer);


    let time = 47986698;
    let distance = 400121310111540;

    let win_ways_count = (0..time)
        .filter(|i| calculate_distance(*i, time) > distance)
        .count();

    println!("{}", win_ways_count);
}

fn calculate_distance(time_pressing: i64, time_all: i64) -> i64 {
    time_pressing * (time_all - time_pressing)
}

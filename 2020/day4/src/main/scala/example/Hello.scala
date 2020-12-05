import scala.io.Source

object Hello extends App {
  val passportStrings =
    Source
      .fromFile("input.txt")
      .mkString
      .split("(\\r?\\n){2}")
      .map(_.replaceAll("\\r?\\n", " "))
      .toArray

  val filledPassports =
    passportStrings
      .map(s => s.split(' '))
      .filter(s => s.count(!_.startsWith("cid:")) == 7)
      .map(s => s.map(_.split(':')).map({ case Array(k, v) => (k, v) }).toMap)

  println(filledPassports.length)

  val validPassports =
    filledPassports.filter(p =>
      p("byr").matches("19[2-9][0-9]|200[0-2]") &&
        p("iyr").matches("201[0-9]|2020") &&
        p("eyr").matches("202[0-9]|2030") &&
        p("hgt").matches("((1[5-8][0-9]|19[0-3])cm)|((59|6[0-9]|7[0-6]))in") &&
        p("hcl").matches("#[0-9a-f]{6}") &&
        p("ecl").matches("amb|blu|brn|gry|grn|hzl|oth") &&
        p("pid").matches("[0-9]{9}"))

  println(validPassports.length)
}

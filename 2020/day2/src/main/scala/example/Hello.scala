import scala.io.Source

class PasswordPolicy(val val1: Int, val val2: Int, val char: Char, val password: String)

object Hello extends App {
  val filename = "input.txt"

  val passwordPolicies =
    Source.fromFile(filename).getLines()
      .map(line => {
        var parts = line.replace("-", " ").replace(":", "").split(" ")
        new PasswordPolicy(parts(0).toInt, parts(1).toInt, parts(2)(0), parts(3))
      })
      .toArray


  val validPasswords1 = passwordPolicies.filter(p =>
    (p.val1 to p.val2).contains(p.password.count(_ == p.char)))

  println(validPasswords1.length)


  val validPasswords2 = passwordPolicies.filter(p =>
    (if (p.password(p.val1 - 1) == p.char) 1 else 0) +
      (if (p.password(p.val2 - 1) == p.char) 1 else 0) == 1)

  println(validPasswords2.length)
}

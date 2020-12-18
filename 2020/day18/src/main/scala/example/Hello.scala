import scala.io.Source
import scala.collection.mutable.ArrayBuffer

object Hello extends App {
  val lines: Array[String] =
    Source
      .fromFile("input.txt")
      .getLines
      .toArray

  val result1 = lines
    .map(calculateExpression(_, calcParentlessExprSamePrecedence))
    .sum
  
  println(result1)

  val result2 = lines
    .map(calculateExpression(_, calcParentlessExprSumFirst))
    .sum
  
  println(result2)
  

  def calculateExpression(input: String, calcParentless: (String) => BigInt): BigInt = {
    var currentInput = input

    while (currentInput.contains('(')) {
      var expression = "\\([ 0-9\\*\\+]+\\)".r.findFirstIn(currentInput).get
      val value = calcParentless(expression.drop(1).dropRight(1))
      currentInput = currentInput.replace(expression, value.toString())
    }

    calcParentless(currentInput)
  }

  def calcParentlessExprSamePrecedence(line: String): BigInt = {
    val input = line.split(' ')
    var result = BigInt(input(0))
    var i = 1
    while (i < input.length) {
      input(i) match {
        case "+" =>  result += input(i + 1).toInt
        case "*" =>  result *= input(i + 1).toInt
      }
      i += 2
    }
    result
  }

  def calcParentlessExprSumFirst(line: String): BigInt = {
    var currentInput = line.split(' ').toBuffer

    def executeOperator(op: String, fun: (BigInt, BigInt) => BigInt) = {
      while(currentInput.exists(_ == op)) {
        val opIndex = currentInput.indexOf(op)
        currentInput(opIndex - 1) =
          fun(
            BigInt(currentInput(opIndex - 1)),
            BigInt(currentInput(opIndex + 1)))
          .toString()
        currentInput.remove(opIndex, 2)
      }
    }

    executeOperator("+", (a, b) => a + b)
    executeOperator("*", (a, b) => a * b)

    BigInt(currentInput(0))
  }
}
import scala.io.Source
import scala.collection.mutable.ArrayBuffer

object Hello extends App {
  val program: Array[(String, Int)] =
    Source
      .fromFile("input.txt")
      .getLines
      .map(_.split(" "))
      .map(parts => (parts(0), parts(1).toInt))
      .toArray

  def runProgram(program: Array[(String, Int)]): (Boolean, Int) = {
    var currentIndex = 0
    var accumulator = 0
    val visitedInstructions = ArrayBuffer[Int]()
    
    while (!visitedInstructions.contains(currentIndex) && currentIndex < program.length) {
      visitedInstructions.append(currentIndex)
      val (operation, argument) = program(currentIndex)
      operation match {
        case "acc" => {
          accumulator += argument
          currentIndex += 1
        }
        case "jmp" => currentIndex += argument
        case "nop" => currentIndex += 1
      }
    }
    (currentIndex >= program.length, accumulator)
  }

  println(runProgram(program)._2)


  var isExecuted = false
  var secondAcc = 0
  var currentChangeIndex = 0
  
  do {
    currentChangeIndex =
      currentChangeIndex + program
        .drop(currentChangeIndex)
        .indexWhere(i => i._1 == "jmp" || i._1 == "nop")

    val modifiedProgram = program.clone()

    modifiedProgram(currentChangeIndex) = (
      if (modifiedProgram(currentChangeIndex)._1 == "jmp") "nop" else "jmp",
      (modifiedProgram(currentChangeIndex)._2))

    val res = runProgram(modifiedProgram)
    isExecuted = res._1
    secondAcc = res._2
    currentChangeIndex += 1
  } while (isExecuted == false)

  println(secondAcc)
}

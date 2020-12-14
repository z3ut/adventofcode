import scala.io.Source
import scala.collection.mutable.Map
import java.math.BigInteger

object Hello extends App {
  var instructions: Array[String] =
    Source
      .fromFile("input.txt")
      .getLines
      .toArray
  
  val memory = Map[BigInt, BigInt]()
  var mask = ""

  instructions.foreach(line => {
    if (line.substring(0, 4) == "mask") {
      mask = line.substring(7)
    }
    if (line.substring(0, 3) == "mem") {
      val address = BigInt(line.substring(4).split(']').head)
      val value = BigInt(line.split("=").last.trim)
      val bitValue = convertToBinaryString(value.toInt)

      val maskedBinaryString =
        mask
          .zipWithIndex 
          .map{ case (c, i) =>
            c match {
              case 'X' => bitValue(i)
              case '0' => '0'
              case '1' => '1'
            }}
          .mkString

      memory(address) = BigInt.apply(maskedBinaryString, 2)
    }
  })

  println(memory.values.sum)


  memory.clear()
  mask = ""

  instructions.foreach(line => {
    if (line.substring(0, 4) == "mask") {
      mask = line.substring(7)
    }
    if (line.substring(0, 3) == "mem") {
      val address = line.substring(4).split(']').head.toInt
      val value = BigInt(line.split("=").last.trim)

      val maskedAddress =
        convertToBinaryString(address)
          .zipWithIndex
          .map{ case (c, i) => 
            mask(i) match {
              case 'X' => 'X'
              case '0' => c
              case '1' => '1'
            }}
          .mkString

      val numberOfVariants = maskedAddress.count(_ == 'X')

      (0 until scala.math.pow(2, numberOfVariants).toInt)
        .foreach(i => {
          var address = maskedAddress
          convertToBinaryString(i, numberOfVariants)
            .foreach(c => address = address.replaceFirst("X", c.toString))
          memory(BigInt.apply(address, 2)) = value
        })
    }
  })

  println(memory.values.sum)

  def convertToBinaryString(number: Int, numberOfDigits: Int = 36): String =
    String.format("%" + numberOfDigits + "s", number.toBinaryString).replace(' ', '0')
}

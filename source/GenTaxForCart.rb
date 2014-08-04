##############################################################################
# Script: GenTaxForCart.rb
# Author: Aravindan
# Created Date:04/Aug/2014
# Purpose: Reads the cart items from input csv file , applies the sales tax ,     #          import duty and caculates total amount including tax for each cart    #          item. Outputs the cart items and tax details to a csv file.
##############################################################################

require 'csv'


# TaxDetails Class - Maintains taxable & non taxable product names
class TaxDetails
  SALESTAXIGNORE=["chocolate","book" ,"pills" ]
  IMPORTTAXDUTY=["imported"]
  SALESTAX=0.1
  IMPORTDUTY=0.05
end

# CartItem Class - Holds cart item detail like quantity, product, price found     #           in the input csv file.  Has methods to caculate tax for the          #            product
class CartItem
  attr_reader :item_qty,:item_Product,:item_price,:item_salestax, :item_import_duty,:totalAmtInclTax

  def initialize(quantity, productName,price)
    @item_qty=quantity
    @item_Product=productName
    @item_price=price
    @item_salestax=0
    @item_import_duty=0
    @salesTax=TaxDetails::SALESTAX
    @importDuty=TaxDetails::IMPORTDUTY
    @totalAmtInclTax=0

  end

  #######################################################################
  # MethodName: calculateTax
  # Task: Calculates Sales tax ,import duty and total tax for the product.
  # Param:  None
  # Return: None
  #######################################################################
  def calculateTax()

    salesTaxIgnoreRegex = Regexp.new(TaxDetails::SALESTAXIGNORE.join("|"))
    #     puts "sales: #{@item_Product}"
    if ( salesTaxIgnoreRegex.match(@item_Product) )
      @totalAmtInclTax=@item_price
      @item_salestax=0
      #	 puts "Sales Tax Ignore"
    else
      @totalAmtInclTax=@item_price + (@item_price*@salesTax)
      @item_salestax=(@item_price*@salesTax)
      #	 puts "Sales Tax calculated"
    end
    importDutyRegex=Regexp.new(TaxDetails::IMPORTTAXDUTY.join("|"))
    #      puts "importduty: #{@item_Product}"
    if ( importDutyRegex.match(@item_Product) )
      @totalAmtInclTax=@totalAmtInclTax + (@item_price*@importDuty)
      @item_import_duty=@item_price*@importDuty
      #	 puts "Import Duty Calculated"
    else
      @item_import_duty=0
      #	 puts "Import Duty Ignored"
    end

    #      puts " Before ToalAmtInclTax: #{@totalAmtInclTax}"
    @totalAmtInclTax= @totalAmtInclTax.round(2)

    #      puts "Price: #{@item_price}"
    #      puts "salestax: #{@salestax}"
    #      puts " After ToalAmtInclTax: #{@totalAmtInclTax}"
  end


  #######################################################################
  # MethodName: to_s
  # Task: Retrieves the product details found in the cartitem object for display.
  # Param:  None
  # Return: None
  #######################################################################
  def to_s
    "(item_qty:#@item_qty,item_product:#@item_Product,item_price:#@item_price)"        +"(item_salestax:#@item_salestax,item_import_duty:#@item_import_duty,totalAmtInclTax:#@totalAmtInclTax)" +
      "(salestax:#@salesTax,importDuty:#@importDuty)"
      # string formatting of the object.
      end

end


#InputFile Class - Used for Reading the input csv file
class InputFile

  #######################################################################
  # MethodName: processCsvFile
  # Task: Reads the input csv file , creates the cartitem object
  #       and stores the csv fields into the cart item object.
  #       Tax calculation is performed in each cart item object
  # Param:  Input csv file name
  # Return: Array of cart item objects
  #######################################################################

  def processCsvFile(filename)

    recList = []
    cartItem=""
    lineCnt=0
    CSV.foreach(File.path(filename)) do |col|
      lineCnt=lineCnt+1
      next if(lineCnt==1)

      cartItemObj=CartItem.new( col[0].to_i , col[1], col[2].to_f);
      cartItemObj.calculateTax()
      recList << cartItemObj;
    end


    return recList
  end
end

#OutputFile Class - Used for writing the output csv file with the required fields
class OutputFile

#######################################################################
# MethodName: writeCsVFile
# Task: Creates the output csv file and writes the cartitem object
#       to the output csv file. Calculates the total amount and sales in the     #       input csv file and writes it to the output file.
# Param:  output file name and the array of input cart item objects
# Return: None
#######################################################################

  def writeCsVFile(outFileName,inputRecList)
    totalInclTax=0
    totalSalesTax=0
    totalImportDuty=0
    totalTax=0
    open(outFileName, 'w') do |f|
      f.puts("Quantity,Product, Original Price,SalesTax,ImportDuty, Total Amt incl Tax")
      inputRecList.each { |x|
        f.puts "#{x.item_qty},#{x.item_Product},#{x.item_price},#{x.item_salestax},#{x.item_import_duty},#{x.totalAmtInclTax}"
        totalInclTax=totalInclTax + x.totalAmtInclTax
        totalSalesTax=totalSalesTax + x.item_salestax
        totalImportDuty=totalImportDuty + x.item_import_duty
        totalTax=totalTax + x.item_salestax + x.item_import_duty


      }
      f.puts "Total Tax: #{totalTax.round(2)}"
      f.puts "Sales Tax: #{totalSalesTax.round(2)}"
      f.puts "Import Duty: #{totalImportDuty.round(2)}"
      f.puts "Total Amount Incl Tax: #{totalInclTax}"

    end


  end
end


#######################################################################
# MethodName: Main
# Task: Reads the input csv file. Calculates sales tax , import duty
#       and total tax for the products in the cart and writes the     
#       output to a csv file
# Param:  None
# Return: None
#######################################################################
def Main

  puts "Inside Main Function"

  inFile=InputFile.new()
  inputRecList1=inFile.processCsvFile("inputfile1.txt")
  # inputRecList1.each { |x| puts "#{x}" }

  inFile=InputFile.new()
  inputRecList2=inFile.processCsvFile("inputfile2.txt")
  #inputRecList2.each { |x| puts "#{x}" }

  inFile=InputFile.new()
  inputRecList3=inFile.processCsvFile("inputfile3.txt")
  #inputRecList3.each { |x| puts "#{x}" }

  outFile1=OutputFile.new()
  outFile1.writeCsVFile("outputfile1.txt",inputRecList1)


  outFile2=OutputFile.new()
  outFile2.writeCsVFile("outputfile2.txt",inputRecList2)


  outFile3=OutputFile.new()
  outFile2.writeCsVFile("outputfile3.txt",inputRecList3)

  puts "Generated output files outputfile1.txt, outputfile2.txt,outputfile3.txt"

  puts "Completed Main Function"

end

Main()

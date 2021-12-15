Alexandre Arkhipov, 2021

The splitFlextext.xsl transform splits a single flextext file containing multiple texts into multiple flextext files (one per text).
The splitFlextext.bat file can be used to run the transform using Saxon processor under Java on Windows.
The free "HE" (Home Edition) of the 10 version of Saxon for Java is assumed.
See Saxon page: https://www.saxonica.com/download/download_page.xml
and specifically for this version/edition SaxonHE10-6J:
https://sourceforge.net/projects/saxon/files/Saxon-HE/10/Java/
Extract saxon-he-10.6.jar from the zip archive, e.g. into C:\saxon\saxon-he-10.6.jar.

The command to launch the transform is:

java -cp C:\saxon\saxon-he-10.6.jar net.sf.saxon.Transform -t -s:all.flextext -xsl:splitFlextext.xsl -o:result\result.xml addcounter=no

Here
-- "C:\saxon\saxon-he-10.6.jar" is the path to Saxon
-- "-s:all.flextext": 	name of the source file (here "all.flextext"; add path if in a different folder)
-- "-xsl:splitFlextext.xsl": the script to run ("splitFlextext.xsl", add path if in a different folder)

-- "-o:result\result.xml": where to put the resulting files 
NB: here a subfolder called "result" will be created if doesn't exist; however, instead of the "result.xml" file, multiple flextext files will be created in that subfolder

-- "addcounter=no": this option says not to add any counter to the filename
NB: The script will try to extract the filenames for each flextext from the "Title" and "Title abbreviation" fields on the Info Tab in the Interlinear view. If there are texts with identical names, use the option "addcounter=yes", otherwise there will be a filename conflict.

The filenames are extracted in this way:
-- From the first non-empty "title-abbreviation" field (+counter, if "addcounter=yes" is specified),
-- otherwise from the first non-empty "title" field (+counter, if "addcounter=yes" is specified),
-- otherwise from the internal identifier (guid) of the text preceded with "text_" (without a counter, since guids are unique).

Edit the bat file to specify the path to saxon-he-10.6.jar and the name of the source flextext file to process.
The script (splitFlextext.xsl), the batch file (splitFlextext.bat) and the source flextext should be placed in the same folder (otherwise make sure to specify paths).
Run the bat file (e.g. by double-clicking).

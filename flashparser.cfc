<cfcomponent displayname="swfparser" hint="Parses and modifies swf files">
	<cfset this.temporaldir=GetTempDirectory()>
    <cfset this.javaloader=CreateObject("component","javaloader.JavaLoader")>
    <cfset this.classdir=ExpandPath("./flash/")>
    <cfset this.exportdir=this.temporaldir>
    <cfset this.namespace="co_swfparser">
    <cfset this.swf_file="">
	<!---
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	Name:		SWF Parser Coldfusion Component
	Author:		(c) 2012 Pablo Schaffner Bofill
	Email: 		pschaffner(at)me.com
	Version:	1.0
	License:	LGPL
	CFM Engines supported:	All
	OS supported:			All
	
	Description:
	A Coldfusion component for analyzing and extracting resources from SWF files within Coldfusion.
	Can also update/modify contents of the given swf file using the 'identifier' of the element to update.

	Depends on the following java classes:
	
	flash/AbcInterpreter.java		:	Interprets ActionscriptByteCodes into Classes, variables and opcodes.
	flash/BitOutputStream.java		:	Enables file FLV.java to write audio packet header bits into new FLV file (extractVideos).
	flash/FLV.java					:	Enables to read special byte int types and write new FLV files (extractVideos).
	flash/ImageHelper.java			:	Helps normalize jpg bufferedImages inside swf files.
	flash/transform-3.0.2.jar		:	Flagstone Transform 3.0.2 library, enables to read/modify SWF files.

	Also, uses the excelent Javaloader to use the previous java classes.
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	NOTE: USE IF FREELY, (just give me some credit somewhere for it).
	////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	init(config)	: OK!
		: config struct =
			{
				exportdir = Directory for resource export (images,swfs,.as files,etc),
				tempdir = (optional) Directory for temporal resource processing,
				javaloader = (optional) javaloader object,
				classdir = (optional) location of required classes directory
			}
			
	read(swffile)	: OK!
		: returns this,
		: reads the given swffile (local or URL) into memory
	
	getInfo()		: OK!
		: returns struct with swf information (and metadata).
	
	getElements()	: OK!
		: returns array of struct with processed swf information elements.
			: texts, scripts, images, sounds, fonts, classes, READY!
		
	extractImages([outputdir],[fileprefix])		: OK!
		: extracts the images from the current swf file into (optionally) the defined output dir and prefix.
		: returns array of structs with image files (located in outputdir, or defined exportdir). (and their identifiers)
	
	extractSounds([outputdir],[fileprefix])		: OK!
		: returns array of structs with MP3/WAV/PCM/NEL/SPX audio files defined within the current swf file (and their identifiers).
		: optionally saves them in the defined outputdir.
		
	extractVideos([outputdir],[withsound])		: OK!
		: returns array of structs with H263/SCREEN/VP6/VP6ALPHA video files (outputdir or exportdir) defined within the current swf file (and their identifiers).
		: optionally saves the FLV files in the defined outputdir.
		: optionally you can define if you wish to extract the videos with or without sound (default=false).
	
	extractTexts()		:	OK!
		: returns array of structs with Text Strings and TextFields defined within the current swf file (and their identifiers).

	extractClasses()	:	OK!
		: returns array of structs with Actionscript classes (AS3) found within the current swf file.
		//TODO: optionally saves them as .as files in the defined outputdir (seudo-actionscript).

	queryImages()			:	OK!
		: returns query with images

	private:AS3Classes(data=byte[])	:	OK!
		: returns the dissambled as3 data byte array as an array of structs to be post-processed.

	getVersion()			:	
		: returns struct with CFC version information.

	/////////////////////////////////
	// TODO: maybe next versions...
	/////////////////////////////////

	extractScripts()
		: returns array of structs with scripts (actionscript 2.0) defined within the current swf file (and their identifiers).
		
	extractShapes([outputdir],[fileprefix])		:
		: returns array of structs with png images of found shapes, in exportdir or defined outputdir directory and file prefix.

	getFontShapes(fontname)
		: return array of structs with font glyphs and asociated font shape (for SVG export) :: FOR THE FUTURE.

	//////////////////////////////////////
	/// TODO: FOR FLV VIDEO FILES	//////
	//////////////////////////////////////
	(not done, but can be done - maybe flvparser.cfc ?)
	
	FLV_extractAudio(FLVFile, [outputdir])	:	
		: extracts the sound frames of the given FLV file and saves them in the defined output directory (or defined exportdir).

	FLV_extractFrames(FLVFile, [framerange][timerange], outputdir, [withsound])	:
		: extracts only the given framerange/timerange of the given FLV file, and saves it as a new FLV file in the defined output directory (or defined exportdir).
		: optionally can maintain the sound frames (default=false).
		: you can either define framerange or timerange. Timerange is time in miliseconds.
	
	FLV2Images(FLVFile, [outputdir], [fileprefix])	:
		: extracts the
	
	FLV_create(Images[],FLVFile,FPS)	:
		: creates a new FLV video file in the defined location (FLVFile), from the given images array (all images must be same size).
		: FPS parameter defines the "Frames per second". Each image can also specify the duration (translates to timestamp) for each image.
		
	FLV_image2videoframe(Image)			:
		: returns the videoframe data (encoded in SCREENVIDEO_CODEC only) for the given image.

	//////////////////////
	// TODO: General  ////
	//////////////////////
	
	getVars([specific_var])			:
		: returns all vars found, or the specified one, and their values, within the current swf file.
		: optionally can also 'recurse' within other included swffiles inside the current swf file.

	getXMLs()
		: returns all values that look like an XML (vars,texts,etc).
	
	opcode2script()
		: returns string with seudo-actionscript of the given opcodes string (must come from method AS3Classes or extractClasses method's contents).
		
	downloadFlashFiles(url, [outputdir])
		(requires usage of sparser2.cfc)
		: downloads all swf files in the given url, even inside the swf files themself, and save them in the defined outputdir (or default exportdir).
		: returns array with files for post-processing if you wish to.
	
	queryDirectory(path)
		: returns a cfdirectory query with extended info for swf files on the given path. Allows one to 'query' or search for swf file specifications within a directory.

	////////////////////////////////////////////////
	// TODO: METHODS TO MODIFY CURRENT SWF FILE   //
	////////////////////////////////////////////////

	getFontChars(font_name)
		: returns an array with the characters supported by the given included font_name within the current swf file.
		: needed, because you can only change texts of the given font, using these characters, if not it fails.	

	changeText(text_id, new_text)
		: replaces the given text identifier element, with the given text string.
		: can throw an error if the new text string contains characters that are not contained within the current text font.
	
	changeImage(image_id, new_image_file)
		: replaces the given image identifier element, with the given absolute new image file.

	changeVersion(new_version_number)
		: replace the current swf file version number.
	
	changeFPS(new_frame_rate)
		: modifies the current swf file movie framerate.
	
	changeBackground(new_hex_color)
		: replaces the current swf file movie background color to the provided new hexcolor.
	
	save(new_swf_file)
		: saves the modified swf file into the given location (new_swf_file).
	
	--->
    
    <!--- ********************** --->
    <!--- *** PUBLIC METHODS *** --->
    <!--- ********************** --->
    
    <!--- init(config) : retuns this --->
	<cffunction name="init" access="public" returntype="any" hint="Initializes swf parser with optional configuration struct.">
		<cfargument name="config" type="struct" required="no" hint="Struct configuration">
        <cfset var cp=ArrayNew(1)>
        <!--- --->
		<cfif IsStruct(arguments.config)>
        	<cfif StructKeyExists(arguments.config,"exportdir")><cfset this.exportdir=arguments.config.exportdir></cfif>
        	<cfif StructKeyExists(arguments.config,"tempdir")><cfset this.temporaldir=arguments.config.tempdir></cfif>
        	<cfif StructKeyExists(arguments.config,"javaloader")><cfset this.javaloader=arguments.config.javaloader></cfif>
        	<cfif StructKeyExists(arguments.config,"classdir")><cfset this.classdir=arguments.config.classdir></cfif>
        </cfif>
        <!--- define railo server variables for non-railo engines --->
        <cfif not IsDefined("server.separator")>
        	<cfset server.separator=StructNew()>
            <cfset server.separator.file=CreateObject("java", "java.lang.System").getProperty("file.separator")>
            <cfset server.separator.line=CreateObject("java", "java.lang.System").getProperty("line.separator")>
        </cfif>
        <!--- init swf parser object instances --->
        <cfif not IsDefined("server.#this.namespace#")>
			<!--- define ClassPath for Javaloader --->
            <cfdirectory action="list" directory="#this.classdir#" filter="*.jar|*.java" recurse="no" name="cp_fs"/>
            <cfloop query="cp_fs">
                <cfset cp[arraylen(cp)+1] = this.classdir & cp_fs.name>
            </cfloop>
        	<cfset StructInsert(server,this.namespace,this.javaloader.init(loadPaths=cp,sourceDirectories=[this.classdir]),true)>
        </cfif>
        <cfset this.ref=Evaluate("server.#this.namespace#")>
		<!--- define/map classes --->
		<cfset this.ImageHelper=this.ref.create("ImageHelper")>
        <cfset this.java=StructNew()>
        <cfset this.java.io=StructNew()>
        <cfset this.java.lang=StructNew()>
        <cfset this.java.net=StructNew()>
        <cfset this.java.net.URL=this.ref.create("java.net.URL")>
        <cfset this.java.io.File=this.ref.create("java.io.File")>
        <cfset this.java.io.FileOutputStream=this.ref.create("java.io.FileOutputStream")>
        <!---<cfset this.java.io.PrintWriter=this.ref.create("java.io.PrintWriter")>--->
        <cfset this.java.lang.Byte=this.ref.create("java.lang.Byte")>
		<cfset this.javax=StructNew()>
        <cfset this.javax.imageio=StructNew()>
        <cfset this.javax.imageio.ImageIO=this.ref.create("javax.imageio.ImageIO")>
        <cfset this.flv=StructNew()>
        <cfset this.flv.builder=this.ref.create("FLV")>
        <cfset this.flagstone=StructNew()>
        <cfset this.flagstone.transform=StructNew()>
        <cfset this.flagstone.transform.Movie=this.ref.create("com.flagstone.transform.Movie")>
        <cfset this.flagstone.transform.MovieTag=this.ref.create("com.flagstone.transform.MovieTag")>
        <cfset this.flagstone.transform.ShowFrame=this.ref.create("com.flagstone.transform.ShowFrame")>
        <cfset this.flagstone.transform.sound=structNew()>
        <cfset this.flagstone.transform.sound.SoundStreamBlock=this.ref.create("com.flagstone.transform.sound.SoundStreamBlock")>
		<cfset this.flagstone.transform.util=StructNew()>
        <cfset this.flagstone.transform.util.image=StructNew()>
        <cfset this.flagstone.transform.util.image.BufferedImageEncoder=this.ref.create("com.flagstone.transform.util.image.BufferedImageEncoder")>
        <!--- AS3 bytecode interpreter --->
        <cfset this.flash=StructNew()>
        <cfset this.flash.AbcInterpreter=this.ref.create("AbcInterpreter")>
        <!--- init movie object --->
		<cfset this.movie=this.flagstone.transform.Movie.init()>
        <!--- --->
		<cfreturn this/>
	</cffunction>
    
    <!--- read(swffile) : returns this --->
	<cffunction name="read" access="public" returntype="any" hint="Loads the given swf file/url into memory.">
		<cfargument name="thefile" type="string" required="no" hint="SWF File/URL to parse">
        <cfif isDefined("this.movie")>
        	<cfset this.swf_file=trim(arguments.thefile)>
            <cfif this.swf_file contains "http://" or this.swf_file contains "https://">
	        	<cfset this.movie.decodeFromUrl(this.java.net.URL.init(this.swf_file))>
                <!--- get elements --->
                <cfset this.elements=this.movie.getObjects()>
            <cfelseif FileExists(this.swf_file)>
	        	<cfset this.movie.decodeFromFile(this.java.io.File.init(this.swf_file))>
                <!--- get elements --->
                <cfset this.elements=this.movie.getObjects()>
            <cfelse>
            	<cfthrow type="swfparser:open" message="The given file #thefile# does not exit"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:open" message="You must first call method init()"/>
        </cfif>
        <cfreturn this/>
	</cffunction>
    
    <!--- getVersion() : returns struct --->
    <cffunction name="getVersion" access="public" returntype="struct" hint="Returns component version information.">
    	<cfset var data=StructNew()>
        <cfset data.version="1.0">
        <cfset data.author="Pablo Schaffner B.">
        <cfset data.last_update=CreateDate(2012,6,28)>
        <cfset data.name="swfparser.cfc">
        <cfset data.description="A component to analyze swf local or remote files, and extract their contents.">
        <cfreturn data/>
    </cffunction>
    
    <!--- getInfo() : returns struct --->
    <cffunction name="getInfo" access="public" returntype="any" hint="Returns information about the current swf file.">
    	<cfset var resp=StructNew()>
        <cfset var element=""><cfset var tagtest=""><cfset var temp_str="">
        <cfset var idpos=0><cfset var internal_swf=0><cfset var internal_swc=0><cfset var images_jpg=0><cfset var images_png=0>
        <cfset var n_fonts=""><cfset var n_texts=0><cfset var n_sounds=0><cfset var n_actions=0><cfset var n_videos=0>
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
            	<!--- --->
                <cfset resp.filename=ListLast(this.swf_file,server.separator.file)>
                <cfset resp.elements=arraylen(this.elements)>
                <!--- --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfif tagtest eq "com.flagstone.transform.movieheader">
                    	<!--- SWF Header --->
						<cfset resp.version=element.getVersion()>
                        <cfset resp.framerate=element.getFrameRate()>
                        <cfset resp.compressed=element.isCompressed()>
                        <cfset resp.width=element.getFrameSize().getWidth()>
                        <cfset resp.height=element.getFrameSize().getHeight()>
                        <cfset resp.minX=element.getFrameSize().getMinX()>
                        <cfset resp.minY=element.getFrameSize().getMinY()>
                        <cfset resp.maxX=element.getFrameSize().getMaxX()>
                        <cfset resp.maxY=element.getFrameSize().getMaxY()>
                        <cfset resp.framecount=element.getFrameCount()>
                    <cfelseif tagtest eq "com.flagstone.transform.background">
                    	<!--- Background color --->
	                    <cfset resp.background=StructNew()>
						<cfset resp.background.red=element.getColor().getRed()>
                        <cfset resp.background.green=element.getColor().getGreen()>
                        <cfset resp.background.blue=element.getColor().getBlue()>
                        <cfset resp.background.alpha=element.getColor().getAlpha()>
                    <cfelseif tagtest eq "com.flagstone.transform.moviemetadata">
                    	<!--- Meta information --->
			            <cfset resp.metadata=element.getMetaData()>
                    <cfelseif tagtest eq "com.flagstone.transform.movieattributes">
                    	<!--- Movie Attributes --->
                        <cfset resp.uses=StructNew()>
						<cfset resp.uses.metadata=element.hasMetaData()>
                        <cfset resp.uses.as3=element.hasAS3()>
                        <cfset resp.uses.directblit=element.useDirectBlit()>
                        <cfset resp.uses.gpu=element.useGPU()>
                        <cfset resp.uses.network=element.useNetwork()>
                    <cfelseif tagtest contains "definejpegimage">
                    	<cfset images_jpg=images_jpg+1>
                    <cfelseif tagtest contains "defineimage">
                    	<cfset images_png=images_png+1>
                    <cfelseif tagtest eq "com.flagstone.transform.definedata">
                    	<!--- included flash files (swf,swc) --->
						<cfset temp_str=ToString(element.getData())>
						<cfif left(temp_str,3) eq "FWS">
                        	<cfset internal_swf=internal_swf+1>
                        <cfelseif left(temp_str,3) eq "CWS">
                        	<cfset internal_swc=internal_swc+1>
                        </cfif>
                    <cfelseif tagtest contains ".font.fontname">
                    	<!--- FONT FACES --->
                    	<cfset n_fonts=ListAppend(n_fonts,element.getName(),",")>
                    <cfelseif tagtest contains "text.definetextfield" or tagtest contains ".text.definetext">
                    	<!--- TEXT OR TEXTFIELD --->
                        <cfset n_texts=n_texts+1>
                    <cfelseif tagtest contains "sound.soundstreamhead">
                    	<cfset n_sounds=n_sounds+1>
                    <cfelseif tagtest contains "video.definevideo">
	                    <cfset n_videos=n_videos+1>
                    <cfelseif tagtest contains "transform.doaction" or tagtest contains "transform.doabc">
                    	<cfset n_actions=n_actions+1>
                    </cfif>
                </cfloop>
                <!--- post-processed vars --->
               	<cfset resp.internal=StructNew()>
                <cfset resp.internal.swf=internal_swf>
                <cfset resp.internal.swc=internal_swc>
                <cfset resp.internal.jpg=images_jpg>
                <cfset resp.internal.png=images_png>
                <cfset resp.internal.fonts=n_fonts>
                <cfset resp.internal.texts=n_texts>
                <cfset resp.internal.sounds=n_sounds>
                <cfset resp.internal.videos=n_videos>
                <cfset resp.internal.scripts=n_actions>
                <cfif n_actions gt 0>
               		<cfset resp.uses.as2=true>
                <cfelse>
                	<cfset resp.uses.as2=false>
                </cfif>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:getInfo" message="You must first call method open(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:getInfo" message="You must first call method init()"/>
        </cfif>
        <cfreturn resp/>
    </cffunction>
    
    <!--- extractImages([outputdir],[fileprefix]) : returns array of structs with image files (located in outputdir, or defined exportdir). --->
    <cffunction name="extractImages" access="public" returntype="any" hint="Returns array of structs with images inside current swf file.">
    	<cfargument name="outputdir" type="string" required="no" hint="optional output directory for image files"/>
        <cfargument name="fileprefix" type="string" required="no" hint="file prefix for image files."/>
        <cfset var resp=ArrayNew(1)>
        <cfset var t_outputdir="">
        <cfset var t_prefix="">
        <cfset var idpos=0><cfset var f_number=1>
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
            	<!--- define prefix if defined --->
                <cfif isDefined("arguments.fileprefix")>
                	<cfset t_prefix=arguments.fileprefix>
                </cfif>
                <!--- define output directory for images --->
                <cfif isDefined("arguments.outputdir")>
                	<!--- use defined output directory --->
                	<cfset t_outputdir=arguments.outputdir>
                <cfelse>
					<!--- create temporal file subdirectory --->
					<cfset t_outputdir=this.exportdir & listlast(ListFirst(this.swf_file,"."),server.separator.file) & server.separator.file>
                </cfif>
                <!--- create outputdir if non existant --->
				<cfif not DirectoryExists(t_outputdir)>
                    <cfdirectory action="create" directory="#t_outputdir#"/>
                </cfif>
                <!--- extract images --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfswitch expression="#tagtest#">
                    	<cfcase value="com.flagstone.transform.showframe">
                        	<cfset f_number=f_number+1>
                        </cfcase>
                    	<!--- --->
                        <cfcase value="com.flagstone.transform.image.defineimage,com.flagstone.transform.image.defineimage2">
                        	<!--- IMAGE: DefineImage --->
							<cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].width=element.getWidth()>
                            <cfset resp[arraylen(resp)].height=element.getHeight()>
                            <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
							<!--- --->
                            <cfset enc=this.flagstone.transform.util.image.BufferedImageEncoder.init()>
                            <cfset enc.setImage(element)>
                            <cfset resp[arraylen(resp)].extension=".png">
                            <cfset resp[arraylen(resp)].contentType="image/png">
                            <cfset resp[arraylen(resp)].bufferedImage=enc.getBufferedImage()>
                            <cfset tmp_file=t_outputdir & t_prefix & idpos & ".tmp">
                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".png")>
                            <!--- write bufferedImage to file --->
                            <cfset this.javax.imageio.ImageIO.write(enc.getBufferedImage(),"png",this.java.io.File.init(resp[arraylen(resp)].file))>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.image.definejpegimage,com.flagstone.transform.image.definejpegimage2,com.flagstone.transform.image.definejpegimage3,com.flagstone.transform.image.definejpegimage4">
                        	<!--- IMAGE: DefineJpegImage --->
							<cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].width=element.getWidth()>
                            <cfset resp[arraylen(resp)].height=element.getHeight()>
                            <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
							<!--- --->
                            <cfset resp[arraylen(resp)].extension=".jpeg">
                            <cfset resp[arraylen(resp)].contentType="image/jpeg">
                            <cfset resp[arraylen(resp)].bufferedImage=this.javax.imageio.ImageIO.read(toJava("java.io.ByteArrayInputStream",this.ImageHelper.normalizeJpegImage(element.getImage())))>
                            <cfset tmp_file=t_outputdir & t_prefix & idpos & ".tmp">
                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".jpg")>
                            <!--- write bufferedImage to file --->
                            <cfset this.javax.imageio.ImageIO.write(resp[arraylen(resp)].bufferedImage,"jpeg",this.java.io.File.init(resp[arraylen(resp)].file))>
                        </cfcase>
                        <!--- --->
                    </cfswitch>
                </cfloop>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:extractImages" message="You must first call method read(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:extractImages" message="You must first call method init()"/>
		</cfif>
        <cfreturn resp/>
    </cffunction>

    <!--- extractVideos([outputdir],[fileprefix]) : returns array of structs with video files (located in outputdir, or defined exportdir). --->
    <cffunction name="extractVideos" access="public" returntype="any" hint="Returns array of structs with video files inside current swf file.">
    	<cfargument name="outputdir" type="string" required="no" hint="optional output directory for video files"/>
        <cfargument name="withsound" type="boolean" required="no" default="false" hint="extract videos with sound?"/>
        <cfset var resp=ArrayNew(1)>
        <cfset var t_outputdir="">
        <cfset var t_prefix="">
        <cfset var framerate=0>
        <cfset var frame_ms=0>
        <cfset var idpos=0><cfset var f_number=1>
        <cfset var audio=StructNew()>
        <cfset var frame=StructNew()>
        <cfset var audioframe=StructNew()>
        <cfset var sound_format=0><cfset var sound_rate=0><cfset var sound_size=0><cfset var sound_type=0>
        <cfset var last_type=""><cfset var video_closed=false>
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
                <!--- define output directory for sounds --->
                <cfif isDefined("arguments.outputdir")>
                	<!--- use defined output directory --->
                	<cfset t_outputdir=arguments.outputdir>
                <cfelse>
					<!--- create temporal file subdirectory --->
					<cfset t_outputdir=this.exportdir & listlast(ListFirst(this.swf_file,"."),server.separator.file) & server.separator.file>
                </cfif>
                <!--- create outputdir if non existant --->
				<cfif not DirectoryExists(t_outputdir)>
                    <cfdirectory action="create" directory="#t_outputdir#"/>
                </cfif>
                <!--- extract images --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfswitch expression="#tagtest#">
                    	<cfcase value="com.flagstone.transform.showframe">
                        	<cfset f_number=f_number+1>
                        </cfcase>
	                    <cfcase value="com.flagstone.transform.movieheader">
							<!--- SWF Header --->
                            <cfset framerate=element.getFrameRate()>
                            <cfset frame_ms=1000/framerate>
                        </cfcase>
                        <!--- SOUND --->
                        <cfcase value="com.flagstone.transform.sound.soundstreamblock">
                        	<cfif last_type eq "audio">
                            	<!--- last frame was audio? the video needs to be close then.. --->
								<cfif isDefined("videostream")>
                                	<cftry>
	                                    <cfset videostream.close()>
                                        <cfcatch type="any">
                                        </cfcatch>
                                    </cftry>
                                    <cfset video_closed=true>
                                </cfif>
                        	<cfelseif arguments.withsound><!---  and last_type eq "video" --->
								<!--- AUDIO SOUND FRAME --->
                                <cfset audioframe.pos=idpos>
                                <cfset audioframe.datasize=arraylen(element.getSound())>
                                <!--- translate parameters for flv.builder --->
                                <!--- sound_format --->
                                <cfswitch expression="#lcase(audio.format)#">
                                	<cfcase value="mp3"><cfset sound_format=2></cfcase>
                                	<cfcase value="native_pcm,pcm"><cfset sound_format=0></cfcase>
                                	<cfcase value="adpcm"><cfset sound_format=1></cfcase>
                                	<cfcase value="nellymoser_8k"><cfset sound_format=5></cfcase>
                                	<cfcase value="nellymoser"><cfset sound_format=6></cfcase>
                                    <cfdefaultcase><!--- mp3 --->
										<cfset sound_format=2>
                                    </cfdefaultcase>
                                </cfswitch>
                                <!--- sound_rate --->
                                <cfswitch expression="#audio.playRate#">
                                	<cfcase value="5512"><cfset sound_rate=0></cfcase>
                                	<cfcase value="11025"><cfset sound_rate=1></cfcase>
                                	<cfcase value="22050"><cfset sound_rate=2></cfcase>
                                	<cfcase value="44100"><cfset sound_rate=3></cfcase>
                                    <cfdefaultcase><!--- 11025 --->
										<cfset sound_rate=1>
                                    </cfdefaultcase>
                                </cfswitch>
                                <!--- sound_size --->
                                <cfswitch expression="#audio.sampleSize#">
                                	<cfcase value="2"><cfset sound_size=1></cfcase><!--- 16 bits --->
                                	<cfcase value="1"><cfset sound_size=0></cfcase><!--- 8 bits --->
                                    <cfdefaultcase><!--- 11025 --->
										<cfset sound_size=1>
                                    </cfdefaultcase>
                                </cfswitch>
                                <!--- sound_type --->
                                <cfswitch expression="#audio.channels#">
                                	<cfcase value="2"><cfset sound_type=1></cfcase><!--- Stereo --->
                                	<cfcase value="1"><cfset sound_type=0></cfcase><!--- Mono --->
                                    <cfdefaultcase><!--- Mono --->
										<cfset sound_type=0>
                                    </cfdefaultcase>
                                </cfswitch>
                                <!--- get previous timestamp of video frame --->
                                <cfset audioframe.timestamp=1>
                                <cfloop index="qrr" from="#arraylen(resp)#" to="1" step="-1">
                                    <cfif isDefined("frame.timestamp")>
                                        <cfset audioframe.timestamp=frame.timestamp+1>
                                        <cfbreak/>                        
                                    </cfif>
                                </cfloop>
                                <cfset this.flv.builder.writeAudioFrame(audioframe.datasize, 
																		audioframe.timestamp, 
																		element.getSound(), sound_format, sound_rate, sound_size, sound_type)>
								<cfif arraylen(resp) gt 0>
									<cfset resp[arraylen(resp)].has_audio=true>
                                </cfif>
								<cfset last_type="audio">
                            </cfif>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.sound.soundstreamhead,com.flagstone.transform.sound.soundstreamhead2">
                        	<!--- MP3 SOUND HEADER (represents an audio header) --->
                            <cfif arguments.withsound>
								<cfset audio.frame=f_number>
                                <cfset audio.format=element.getFormat().name()>
                                <cfset audio.playRate=element.getPlayRate()>
                                <cfset audio.channels=element.getPlayChannels()>
                                <cfset audio.sampleSize=element.getPlaySampleSize()>
                                <cfset audio.streamRate=element.getStreamRate()>
                                <cfset audio.streamChannels=element.getStreamChannels()>
                                <cfset audio.streamSampleSize=element.getStreamSampleSize()>
                                <cfset audio.streamSampleCount=element.getStreamSampleCount()>
                            </cfif>
                        </cfcase>
                    	<!--- VIDEO --->
                        <cfcase value="com.flagstone.transform.video.videoframe">
                        	<!--- VIDEO FRAME BLOCK --->
                            <cfset frame.timestamp=Fix(element.getFrameNumber() * frame_ms)>
                            <cfset frame.datasize=arraylen(element.getData())+1>
                            <cfif isDefined("videostream")>
                                <!--- get previous codec_type (header) of video frame --->
                                <cfset frame.codec_type=2>
                                <cfloop index="qrr" from="#arraylen(resp)#" to="1" step="-1">
                                    <cfif isDefined("resp[qrr].codec_type")>
                                        <cfset frame.codec_type=resp[qrr].codec_type>
                                        <cfbreak/>                                    
                                    </cfif>
                                </cfloop>
                                <!--- output video stream block to current stream file --->
                                <cfset this.flv.builder.writeVideoFrame(frame.datasize, frame.timestamp, element.getData(), 1, frame.codec_type)>
								<cfset last_type="video">
                            </cfif>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.video.definevideo">
                        	<!--- VIDEO OBJECT HEADER (represents a video file) --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
							<cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].has_audio=false>
                            <cfset resp[arraylen(resp)].codec=element.getCodec().name()>
                            <cfswitch expression="#resp[arraylen(resp)].codec#">
                            	<cfcase value="H263"><cfset resp[arraylen(resp)].codec_type=2></cfcase>
                            	<cfcase value="VP6"><cfset resp[arraylen(resp)].codec_type=4></cfcase>
                            	<cfcase value="VP6ALPHA"><cfset resp[arraylen(resp)].codec_type=5></cfcase>
                            	<cfcase value="SCREEN"><cfset resp[arraylen(resp)].codec_type=3></cfcase>
                                <cfdefaultcase>
	                                <cfset resp[arraylen(resp)].codec_type=2>
                                </cfdefaultcase>
                            </cfswitch>
                            <cfset resp[arraylen(resp)].width=element.getWidth()>
                            <cfset resp[arraylen(resp)].height=element.getHeight()>
                            <cfset resp[arraylen(resp)].framecount=element.getFrameCount()>
                            <cfset resp[arraylen(resp)].deblocking=element.getDeblocking().name()>
							<cfset resp[arraylen(resp)].smoothed=element.isSmoothed()>
                            <!--- close previous opened stream if there was one --->
                            <cfif isDefined("videostream")>
								<cfset videostream.close()>
                            </cfif>
                            <!--- prepare to write file --->
                            <cfset tmp_file=t_outputdir & idpos & ".tmp">
                            <cfswitch expression="#lcase(resp[arraylen(resp)].codec)#">
                            	<cfcase value="h263">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".flv")>
                                </cfcase>
                            	<cfcase value="screen">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".flv")>
                                </cfcase>
                            	<cfcase value="vp6">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".flv")>
                                </cfcase>
                            	<cfcase value="vp6alpha">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".flv")>
                                </cfcase>
                                <cfdefaultcase>
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".flv")>
                                </cfdefaultcase>
                            </cfswitch>
                            <!--- prepare video stream out --->
                            <cfset videostream=this.java.io.FileOutputStream.init(resp[arraylen(resp)].file)>
                            <!--- write FLV header --->
                            <cfset this.flv.builder.init(videostream,arguments.withsound)>
                        </cfcase>
                        <!--- --->
                    </cfswitch>
                </cfloop>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:extractVideos" message="You must first call method read(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:extractVideos" message="You must first call method init()"/>
		</cfif>
        <cfreturn resp/>
    </cffunction>
    
    <!--- extractSounds([outputdir],[fileprefix]) : returns array of structs with sound files (located in outputdir, or defined exportdir). --->
    <cffunction name="extractSounds" access="public" returntype="any" hint="Returns array of structs with sound files inside current swf file.">
    	<cfargument name="outputdir" type="string" required="no" hint="optional output directory for sound files"/>
        <cfargument name="fileprefix" type="string" required="no" hint="file prefix for sound files."/>
        <cfset var resp=ArrayNew(1)>
        <cfset var t_outputdir="">
        <cfset var t_prefix="">
        <cfset var idpos=0><cfset var f_number=1>
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
            	<!--- define prefix if defined --->
                <cfif isDefined("arguments.fileprefix")>
                	<cfset t_prefix=arguments.fileprefix>
                </cfif>
                <!--- define output directory for sounds --->
                <cfif isDefined("arguments.outputdir")>
                	<!--- use defined output directory --->
                	<cfset t_outputdir=arguments.outputdir>
                <cfelse>
					<!--- create temporal file subdirectory --->
					<cfset t_outputdir=this.exportdir & listlast(ListFirst(this.swf_file,"."),server.separator.file) & server.separator.file>
                </cfif>
                <!--- create outputdir if non existant --->
				<cfif not DirectoryExists(t_outputdir)>
                    <cfdirectory action="create" directory="#t_outputdir#"/>
                </cfif>
                <!--- extract images --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfswitch expression="#tagtest#">
                    	<cfcase value="com.flagstone.transform.showframe">
                        	<cfset f_number=f_number+1>
                        </cfcase>
                    	<!--- --->
                        <cfcase value="com.flagstone.transform.sound.soundstreamblock">
                        	<!--- AUDIO SOUND BLOCK --->
                            <cfif isDefined("stream")>
                                <!--- output audio stream block to current stream file --->
                                <cfset stream.write(element.getSound(), 4, arraylen(element.getSound())-4)>
                            </cfif>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.sound.soundstreamhead,com.flagstone.transform.sound.soundstreamhead2">
                        	<!--- MP3 SOUND HEADER (represents an audio file) --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].format=element.getFormat().name()>
                            <cfset resp[arraylen(resp)].playRate=element.getPlayRate()>
                            <cfset resp[arraylen(resp)].channels=element.getPlayChannels()>
                            <cfset resp[arraylen(resp)].sampleSize=element.getPlaySampleSize()>
                            <cfset resp[arraylen(resp)].streamRate=element.getStreamRate()>
							<cfset resp[arraylen(resp)].streamChannels=element.getStreamChannels()>
							<cfset resp[arraylen(resp)].streamSampleSize=element.getStreamSampleSize()>
							<cfset resp[arraylen(resp)].streamSampleCount=element.getStreamSampleCount()>
                            <!--- close previous opened stream if there was one --->
                            <cfif isDefined("stream")>
								<cfset stream.close()>
                            </cfif>
                            <!--- prepare to write file --->
                            <cfset tmp_file=this.temporaldir & idpos & ".tmp">
                            <cfswitch expression="#lcase(resp[arraylen(resp)].format)#">
                            	<cfcase value="mp3">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".mp3")>
                                </cfcase>
                            	<cfcase value="native_pcm,pcm">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".wav")>
                                </cfcase>
                            	<cfcase value="adpcm">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".vox")>
                                </cfcase>
                            	<cfcase value="nellymoser_8k,nellymoser">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".nel")>
                                </cfcase>
                            	<cfcase value="speex">
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".spx")>
                                </cfcase>
                                <cfdefaultcase>
		                            <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".mp3")>
                                </cfdefaultcase>
                            </cfswitch>
                            <!--- prepare audio stream out --->
                            <cfset stream=this.java.io.FileOutputStream.init(resp[arraylen(resp)].file)>
                        </cfcase>
                        <!--- --->
                    </cfswitch>
                </cfloop>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:extractSounds" message="You must first call method read(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:extractSounds" message="You must first call method init()"/>
		</cfif>
        <cfreturn resp/>
    </cffunction>
    
    <!--- extractClasses() : returns array of structs with sound files (located in outputdir, or defined exportdir). --->
    <cffunction name="extractClasses" access="public" returntype="any" hint="Returns array of structs with actionscript 3 classes inside current swf file.">
        <cfset var resp=ArrayNew(1)>
        <cfset var t_outputdir="">
        <cfset var t_prefix="">
        <cfset var idpos=0>
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
                <!--- extract classes --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfswitch expression="#tagtest#">
                    	<!--- --->
				        <cfcase value="com.flagstone.transform.doabc">
                        	<!--- Actionscript 3, ABC Data Byte --->
							<cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].type="as3">
                            <cfset resp[arraylen(resp)].length=arraylen(element.getData())>
							<cfset resp[arraylen(resp)].classes=AS3Classes(element.getData())>
                        </cfcase>
                        <!--- --->
                    </cfswitch>
                </cfloop>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:extractClasses" message="You must first call method read(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:extractClasses" message="You must first call method init()"/>
		</cfif>
        <cfreturn resp/>
    </cffunction>
    
    <!--- extractTexts() : returns array of structs with sound files (located in outputdir, or defined exportdir). --->
    <cffunction name="extractTexts" access="public" returntype="any" hint="Returns array of structs with texts inside current swf file.">
        <cfset var resp=ArrayNew(1)>
        <cfset var just_texts=ArrayNew(1)>
        <cfset var idpos=0><cfset var f_changed="">
        <cfset var f_number=1><!--- frame number --->
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
                <!--- extract texts --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfswitch expression="#tagtest#">
                    	<cfcase value="com.flagstone.transform.showframe">
                        	<cfset f_number=f_number+1>
                        </cfcase>
                    	<!--- --->
                        <cfcase value="com.flagstone.transform.text.definefont">
                            <!--- FONT DEFINITION --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].type="font">
                            <cfset resp[arraylen(resp)].frame=f_number>
							<cfset resp[arraylen(resp)].name="noname" & element.getIdentifier()>
                            <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                            <cfset resp[arraylen(resp)].codes=Arraynew(1)><!--- font is defined as a group of Shapes, not glypths ... getShapes() --->
                            <cfset resp[arraylen(resp)].shapes=element.getShapes()>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.font.definefont2,com.flagstone.transform.font.definefont3">
                            <!--- FONT DEFINITION --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].type="font">
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].name=element.getName()>
                            <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                            <cfset resp[arraylen(resp)].codes=element.getCodes()>
                            <cfset resp[arraylen(resp)].language=element.getLanguage().name()>
                            <cfset resp[arraylen(resp)].encoding=element.getEncoding().name()>
                            <cfset resp[arraylen(resp)].is_bold=element.isBold()>
                            <cfset resp[arraylen(resp)].is_italic=element.isItalic()>
                            <cfset resp[arraylen(resp)].is_small=element.isSmall()>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.text.definetext,com.flagstone.transform.text.definetext2">
                            <!--- TEXT STRING --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].type="swftext">
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                            <cfset tt=element.getSpans()>
                            <cfset the_text="">
                            <cfset the_word="">
                            <cfset resp[arraylen(resp)].spans=ArrayNew(1)>
							<cfset fontpos=0>
                            <!--- --->
                            <cfloop index="qtt" from="1" to="#arraylen(tt)#" step="+1">
                                <cfset resp[arraylen(resp)].spans[qtt]=StructNew()>
								<!--- PREPARE to decode glyphs TO TEXT --->
                                <cfloop index="qrr" from="#arraylen(resp)#" to="1" step="-1">
                                    <cfif resp[qrr].type eq "font" or resp[qrr].type eq "swffont">
                                    	<cfif resp[qrr].identifier eq tt[qtt].getIdentifier()>
											<cfset fontpos=qrr>
                                            <cfbreak/>
                                        </cfif>
                                    </cfif>
                                </cfloop>
                                <!--- --->
                                <!---<cfset resp[arraylen(resp)].spans[qtt].identifier=tt[qtt].getIdentifier()>--->
                                <cfset resp[arraylen(resp)].spans[qtt].color=StructNew()>
                                <cftry>
	                                <cfset resp[arraylen(resp)].spans[qtt].color.alpha=tt[qtt].getColor().getAlpha()>
                                    <cfcatch type="any">
		                                <cfset resp[arraylen(resp)].spans[qtt].color.alpha=-1>
                                    </cfcatch>
                                </cftry>
                                <cftry>
									<cfset resp[arraylen(resp)].spans[qtt].color.red=tt[qtt].getColor().getRed()>
                                    <cfset resp[arraylen(resp)].spans[qtt].color.green=tt[qtt].getColor().getGreen()>
                                    <cfset resp[arraylen(resp)].spans[qtt].color.blue=tt[qtt].getColor().getBlue()>
                                    <cfcatch type="any">
										<cfset resp[arraylen(resp)].spans[qtt].color.red=-1>
                                        <cfset resp[arraylen(resp)].spans[qtt].color.green=-1>
                                        <cfset resp[arraylen(resp)].spans[qtt].color.blue=-1>
                                    </cfcatch>
                                </cftry>
                                <cfset resp[arraylen(resp)].spans[qtt].offset_x=tt[qtt].getOffsetX()>
                                <cfset resp[arraylen(resp)].spans[qtt].offset_y=tt[qtt].getOffsetY()>
                                <cfset resp[arraylen(resp)].spans[qtt].font_name=resp[fontpos].name>
                                <cfset resp[arraylen(resp)].spans[qtt].font_id=resp[fontpos].identifier>
                                <cfset resp[arraylen(resp)].spans[qtt].font_lang=resp[fontpos].language>
                                <cfset resp[arraylen(resp)].spans[qtt].font_encoding=resp[fontpos].encoding>
                                <cfset resp[arraylen(resp)].spans[qtt].characters=ArrayNew(1)>
                                <cfset tti=tt[qtt].getCharacters()>
                                <cfloop index="qqtt" from="1" to="#arraylen(tti)#" step="+1">
                                	<cftry>
										<cfset resp[arraylen(resp)].spans[qtt].characters[qqtt]=StructNew()>
                                        <!---<cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].advance=tti[qqtt].getAdvance()>--->
                                        <cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].glyph_index=tti[qqtt].getGlyphIndex()>
                                        <!---<cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].font_code=resp[fontpos].codes[tti[qqtt].getGlyphIndex()+1]>--->
                                        <cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].glyph_char=chr(resp[fontpos].codes[tti[qqtt].getGlyphIndex()+1])>
                                        <cfset the_word=the_word & resp[arraylen(resp)].spans[qtt].characters[qqtt].glyph_char>
                                        <cfcatch type="any">
                                        </cfcatch>
                                    </cftry>
                                </cfloop>
                                <cfset resp[arraylen(resp)].spans[qtt].text=the_word>
                                <cfset the_text=ListAppend(the_text,the_word,chr(13))>
                                <cfset the_word="">
                            </cfloop>
                            <cfset the_text=ReplaceNoCase(the_text,chr(13)," " & chr(13))>
                            <cfset resp[arraylen(resp)].text=the_text>
                            <!---<cfset resp[arraylen(resp)].transform=element.getTransform()>--->
                        </cfcase>
                        <cfcase value="com.flagstone.transform.text.definetextfield">
                            <!--- TEXT FIELDS --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].type="textfield">
                            <cfset resp[arraylen(resp)].frame=f_number>
                            <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                            <cfset resp[arraylen(resp)].is=StructNew()>
                            <cfset resp[arraylen(resp)].is.ReadOnly=element.isReadOnly()>
                            <cfset resp[arraylen(resp)].is.HTML=element.isHtml()>
                            <cfset resp[arraylen(resp)].is.Multiline=element.isMultiline()>
                            <cfset resp[arraylen(resp)].is.wordwrapped=element.isWordWrapped()>
                            <cfset resp[arraylen(resp)].is.password=element.isPassword()>
                            <cfset resp[arraylen(resp)].is.selectable=element.isSelectable()>
                            <cfset resp[arraylen(resp)].is.bordered=element.isBordered()>
                            <cfset resp[arraylen(resp)].is.autosize=element.isAutoSize()>
                            <cfset resp[arraylen(resp)].is.embedded=element.isEmbedded()>
                            <cfset resp[arraylen(resp)].indent=element.getIndent()>
                            <cfset resp[arraylen(resp)].width=element.getBounds().getWidth()>
                            <cfset resp[arraylen(resp)].height=element.getBounds().getHeight()>
                            <cfset resp[arraylen(resp)].color=StructNew()>
                            <cfset resp[arraylen(resp)].color.alpha=element.getColor().getAlpha()>
                            <cfset resp[arraylen(resp)].color.red=element.getColor().getRed()>
                            <cfset resp[arraylen(resp)].color.green=element.getColor().getGreen()>
                            <cfset resp[arraylen(resp)].color.blue=element.getColor().getBlue()>
                            <cfset resp[arraylen(resp)].leading=element.getLeading()>
                            <cfset resp[arraylen(resp)].font=element.getFontClass()>
                            <cfset resp[arraylen(resp)].font_height=element.getFontHeight()>
                            <cfset resp[arraylen(resp)].font_identifier=element.getFontIdentifier()>
                            <cfset resp[arraylen(resp)].maxlength=element.getMaxLength()>
                            <cfset resp[arraylen(resp)].alignment=element.getAlignment().toString()>
                            <cfset resp[arraylen(resp)].text=element.getInitialText()>
                            <cfset resp[arraylen(resp)].variable=element.getVariableName()>
                            <!--- if fontname not found, try searching for font_id --->
                            <cfif resp[arraylen(resp)].font_identifier lt element.getIdentifier()><!--- font id is previously defined than ourselfs --->
                                <cfloop index="qrr" from="#arraylen(resp)#" to="1" step="-1">
                                    <cfif resp[qrr].identifier eq resp[arraylen(resp)].font_identifier>
                                    	<cfset resp[arraylen(resp)].font=resp[qrr].name>
                                        <cfbreak/>
                                    </cfif>
                                </cfloop>
                            </cfif>
                        </cfcase>
                        <!--- --->
                    </cfswitch>
                </cfloop>
                <!--- assign just_texts var --->
                <cfloop index="qtext" array="#resp#">
                	<cfif qtext.type eq "swftext">
                    	<cfset f_changed="">
                        <cfloop index="qpar" array="#qtext.spans#">
                            <cfif not FindNoCase(f_changed,qpar.font_name)>
	                        	<cfset f_changed=ListAppend(f_changed,qpar.font_name)>
                            </cfif>
                        </cfloop>
                        <cfif arraylen(qtext.spans) eq ListLen(f_changed)>
							<cfset just_texts[arraylen(just_texts)+1]=StructNew()>
                            <cfset just_texts[arraylen(just_texts)].type=qtext.type>
                            <cfset just_texts[arraylen(just_texts)].frame=qtext.frame>
                            <cfset just_texts[arraylen(just_texts)].text=qtext.text>
                            <cfset just_texts[arraylen(just_texts)].identifier=qtext.identifier>
                            <cfset just_texts[arraylen(just_texts)].font=qtext.spans[1].font_name>
                        <cfelse>
                            <cfloop index="qpar" array="#qtext.spans#">
								<cfset just_texts[arraylen(just_texts)+1]=StructNew()>
                                <cfset just_texts[arraylen(just_texts)].type=qtext.type>
                                <cfset just_texts[arraylen(just_texts)].frame=qtext.frame>
								<cfset just_texts[arraylen(just_texts)].identifier=qtext.identifier>
                                <cfset just_texts[arraylen(just_texts)].text=qpar.text>
                                <cfset just_texts[arraylen(just_texts)].font=qpar.font_name>
                                <cfset just_texts[arraylen(just_texts)].font_id=qpar.font_id>
                                <cfset just_texts[arraylen(just_texts)].text_full=qtext.text>
                            </cfloop>
                        </cfif>
                    <cfelseif qtext.type eq "textfield">
                    	<cfset just_texts[arraylen(just_texts)+1]=StructNew()>
                        <cfset just_texts[arraylen(just_texts)].type=qtext.type>
                        <cfset just_texts[arraylen(just_texts)].frame=qtext.frame>
                        <cfset just_texts[arraylen(just_texts)].text=qtext.text>
                        <cfset just_texts[arraylen(just_texts)].identifier=qtext.identifier>
                        <cfset just_texts[arraylen(just_texts)].font=qtext.font>
                    </cfif>
                </cfloop>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:extractTexts" message="You must first call method read(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:extractTexts" message="You must first call method init()"/>
		</cfif>
        <cfreturn just_texts/>
    </cffunction>
    
    <!--- queryImages() : returns query with images inside current swf file --->
    <cffunction name="queryImages" access="public" returntype="query" hint="Returns query with image elements of current swf file">
    	<cfset var tresp=extractImages(this.temporaldir)>
        <cfset var resp=ArrayNew(1)>
        <cfset var nresp=ArrayNew(1)>
        <cfset var tmtype="">
        <cfloop index="tn" array="#tresp#">
        	<cfset nresp[arraylen(nresp)+1]=StructNew()>
        	<cfset nresp[arraylen(nresp)].contenttype=tn.contenttype>
        	<cfset nresp[arraylen(nresp)].extension=tn.extension>
        	<cfset nresp[arraylen(nresp)].file=tn.file>
        	<cfset nresp[arraylen(nresp)].identifier=tn.identifier>
        	<cfset nresp[arraylen(nresp)].width=tn.width>
        	<cfset nresp[arraylen(nresp)].height=tn.height>
        </cfloop>
        <!--- transform nresp into query --->
		<cfset resp=struct2query(nresp)>        
        <cfreturn resp/>
    </cffunction>
    
    <cffunction name="getTransform" access="public" returntype="any">
    	<cfreturn this.movie/>
    </cffunction>
    
    <!--- processElement(element, array) : adds array registry (with struct) to given array argument with proccessed element (private) --->
	<cffunction name="processElement" access="private" returntype="void" hint="Process the given element node and adds processed info to the given array">
		<cfargument name="element" type="any" required="yes" hint="The element to process"/>
        <cfargument name="toarray" type="array" required="yes" hint="The array where to add the info"/>
        <cfargument name="idpos" type="any" required="yes" hint="ID pos to assign"/>
        <cfset var resp=arguments.toarray>
        <cfset var element=arguments.element>
        <cfset var idpos=arguments.idpos>
        <!--- --->
        <cfset var tagtest=lcase(ListLast(element.getClass()," "))>
        <cfswitch expression="#tagtest#">
            <cfcase value="com.flagstone.transform.movieheader">
                <!--- MOVIE HEADER --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="movieheader">
                <cfset resp[arraylen(resp)].version=element.getVersion()>
                <cfset resp[arraylen(resp)].framerate=element.getFrameRate()>
                <cfset resp[arraylen(resp)].compressed=element.isCompressed()>
                <cfset resp[arraylen(resp)].framecount=element.getFrameCount()>
                <cfset resp[arraylen(resp)].width=element.getFrameSize().getWidth()>
                <cfset resp[arraylen(resp)].height=element.getFrameSize().getHeight()>
                <cfset resp[arraylen(resp)].minX=element.getFrameSize().getMinX()>
                <cfset resp[arraylen(resp)].minY=element.getFrameSize().getMinY()>
                <cfset resp[arraylen(resp)].maxX=element.getFrameSize().getMaxX()>
                <cfset resp[arraylen(resp)].maxY=element.getFrameSize().getMaxY()>
            </cfcase>
            <cfcase value="com.flagstone.transform.movieclip.definemovieclip">
            	<!--- MOVIE CLIP --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="movieclip">
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <cfset resp[arraylen(resp)].objects=ArrayNew(1)>
                <cfset tr=element.getObjects()>
                <cfset resp[arraylen(resp)].objects_raw=tr>
                <cfloop index="qo" from="1" to="#arraylen(tr)#">
                	<cfset processElement(tr[qo],resp[arraylen(resp)].objects,idpos+qo)>
                </cfloop>
            </cfcase>
            <cfcase value="com.flagstone.transform.place2">
            	<!--- PLACE2 --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="place2">
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <cfset resp[arraylen(resp)].placetype=element.getType().name()>
                <!---<cfset resp[arraylen(resp)].transform=element.getTransform()>--->
                <cfset resp[arraylen(resp)].depth=element.getDepth()>
                <cfset resp[arraylen(resp)].events=element.getEvents()>
                <cfset resp[arraylen(resp)].layer=element.getLayer()>
                <!---<cfset resp[arraylen(resp)].color_transform=element.getColorTransform()>--->
            </cfcase>
            <cfcase value="com.flagstone.transform.showframe">
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="showframe">
            </cfcase>
            <cfcase value="com.flagstone.transform.definedata">
                <!--- INCLUDED SWF FILE --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="swffile">
                <cfset resp[arraylen(resp)].compressed=false>
                <cfset tmp_str=ToString(element.getData())>
                <cfset tmp_file=this.temporaldir & idpos & ".tmp">
                <cfif left(tmp_str,3) eq "FWS">
                    <cfset resp[arraylen(resp)].compressed=false>
                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".swf")>
                <cfelseif left(tmp_str,3) eq "CWS">
                    <cfset resp[arraylen(resp)].compressed=true>
                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".swc")>
                <cfelse>
                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".swf")>
                </cfif>
                <!--- write to tmp file --->
                <cffile action="write" file="#resp[arraylen(resp)].file#" output="#element.getData()#"/>
            </cfcase>
            <cfcase value="com.flagstone.transform.doabc">
                <!--- Actionscript 3, ABC Data Byte --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="as3">
                <cfset resp[arraylen(resp)].length=arraylen(element.getData())>
                <cfset resp[arraylen(resp)].classes=AS3Classes(element.getData())>
            </cfcase>
            <cfcase value="com.flagstone.transform.doaction">
                <!--- Actionscript 1-2 actions --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="as2">
                <!---<cfset resp[arraylen(resp)].length=arraylen(element.getData())>--->
                <cfset resp[arraylen(resp)].actions=ArrayNew(1)>
                <cfset resp[arraylen(resp)].actions_interpreted=ArrayNew(1)>
                <cfset eactions=element.getActions()>
                <cfset cuNumAction=0>
                <cfset sawEnd=false>
                <cfset actiontemp=ArrayNew(1)>
                <!---<cfset resp[arraylen(resp)].eactions=eactions>--->
                <cfloop index="qac" from="1" to="#arraylen(eactions)#" step="+1">
                    <cfset tagtesta=lcase(ListLast(eactions[qac].getClass()," "))>
                    <cfif tagtesta eq "com.flagstone.transform.action.basicaction">
                        <cfif eactions[qac].name() eq "END">
                            <cfset sawEnd=true>
                        </cfif>
                    </cfif>
                    <cfif not sawEnd>
                        <!--- add action as a group of (part of the same current command) --->
                        <!--- --->
                        <cfswitch expression="#tagtesta#">
                            <cfcase value="com.flagstone.transform.action.basicaction">
                                <cfset actiontemp[arraylen(actiontemp)+1]=StructNew()>
                                <cfset actiontemp[arraylen(actiontemp)].type=tagtesta>
                                <cfset actiontemp[arraylen(actiontemp)].name=eactions[qac].name()>
                            </cfcase>
                            <cfcase value="com.flagstone.transform.action.geturl">
                                <cfset actiontemp[arraylen(actiontemp)+1]=StructNew()>
                                <cfset actiontemp[arraylen(actiontemp)].type=tagtesta>
                                <cfset actiontemp[arraylen(actiontemp)].url=eactions[qac].getUrl()>
                                <cfset actiontemp[arraylen(actiontemp)].target=eactions[qac].getTarget()>
                            </cfcase>
                            <cfcase value="com.flagstone.transform.action.push">
                                <cfset actiontemp[arraylen(actiontemp)+1]=StructNew()>
                                <cfset actiontemp[arraylen(actiontemp)].type=tagtesta>
                                <cfset actiontemp[arraylen(actiontemp)].values=eactions[qac].getValues()>
                            </cfcase>
                            <cfcase value="com.flagstone.transform.action.geturl2">
                                <cfset actiontemp[arraylen(actiontemp)+1]=StructNew()>
                                <cfset actiontemp[arraylen(actiontemp)].type=tagtesta>
                                <cfset actiontemp[arraylen(actiontemp)].request=eactions[qac].getRequest().name()>
                            </cfcase>
                            <cfcase value="com.flagstone.transform.action.gotolabel">
                                <cfset actiontemp[arraylen(actiontemp)+1]=StructNew()>
                                <cfset actiontemp[arraylen(actiontemp)].type=tagtesta>
                                <cfset actiontemp[arraylen(actiontemp)].label=eactions[qac].getLabel()>
                            </cfcase>
                            <cfdefaultcase>
                                <cfset actiontemp[arraylen(actiontemp)+1]=StructNew()>
                                <cfset actiontemp[arraylen(actiontemp)].type=tagtesta>
                                <cfset actiontemp[arraylen(actiontemp)].value=eactions[qac].toString()>
                                <cfset actiontemp[arraylen(actiontemp)].obj=eactions[qac]>
                            </cfdefaultcase>
                        </cfswitch>
                        <!--- --->
                    <cfelse>
                        <cfset cuNumAction=cuNumAction+1>
                        <cfset sawEnd=false>
                        <!--- interpret the cmd defined in actiontemp --->
                        <cfset interpreted_cmd="">
                        <cfloop index="qcmd" from="1" to="#arraylen(actiontemp)#">
                            <cfswitch expression="#ListLast(actiontemp[qcmd].type,'.')#">
                                <cfcase value="basicaction">
                                    <cfset interpreted_cmd=ListAppend(interpreted_cmd,lcase(actiontemp[qcmd].name) & "();",server.separator.line)>
                                </cfcase>
                                <cfcase value="geturl">
                                    <cfset interpreted_cmd=ListAppend(interpreted_cmd,"getURL(""" & actiontemp[qcmd].url & """, """ & actiontemp[qcmd].target & """);",server.separator.line)>
                                </cfcase>
                                <cfcase value="gotolabel">
                                    <!--- is it is last cmd, is gotoAndStop --->
                                    <cfif arraylen(actiontemp) eq qcmd>
	                                    <cfset interpreted_cmd=ListAppend(interpreted_cmd,"gotoAndStop(""" & actiontemp[qcmd].label & """);",server.separator.line)>
                                    <cfelse>
	                                    <cfset interpreted_cmd=ListAppend(interpreted_cmd,"gotoAndPlay(""" & actiontemp[qcmd].label & """);",server.separator.line)>
                                    </cfif>
                                </cfcase>
                                <cfcase value="push">
                                    <!--- omit, is used by after cmd --->
                                </cfcase>
                                <cfcase value="geturl2">
                                    <!--- search previous push cmd... --->
                                    <cfset prevpush=0>
                                    <cfloop index="qcm" from="#qcmd#" to="1" step="-1">
                                        <cfif ListLast(actiontemp[qcm].type,".") eq "push">
                                            <cfset prevpush=qcm>
                                            <cfbreak/>
                                        </cfif>
                                    </cfloop>
                                    <cfif prevpush neq 0>
                                        <!--- --->
                                        <cfswitch expression="#actiontemp[qcmd].request#">
                                            <cfcase value="MOVIE_TO_TARGET,MOVIE_TO_LEVEL">
                                                <!--- loadMovie(push[1],push[2]); --->
                                                <cfset tmpc="">
                                                <cfloop index="qvva" from="1" to="#arraylen(actiontemp[prevpush].values)#" step="+1">
                                                    <cfset tmpc=ListAppend(tmpc,"""" & actiontemp[prevpush].values[qvva] & """",",")>
                                                </cfloop>
                                                <cfset tmpc=ReplaceNoCase(tmpc,""",""",""", ""","ALL")>
                                                <cfset tmpc="loadMovie(" & tmpc & ");">
                                                <cfset interpreted_cmd=ListAppend(interpreted_cmd,tmpc,server.separator.line)>
                                            </cfcase>
                                            <!--- TODO: maybe more cases needed here --->
                                            <cfdefaultcase>
                                                <!--- loadMovie(push[1],push[2]); --->
                                                <cfset tmpc="">
                                                <cfloop index="qvva" from="1" to="#arraylen(actiontemp[prevpush].values)#" step="+1">
                                                    <cfset tmpc=ListAppend(tmpc,"""" & actiontemp[prevpush].values[qvva] & """",",")>
                                                </cfloop>
                                                <cfset tmpc=ReplaceNoCase(tmpc,""",""",""", ""","ALL")>
                                                <cfset tmpc="loadMovie(" & tmpc & ");">
                                                <cfset interpreted_cmd=ListAppend(interpreted_cmd,tmpc,server.separator.line)>
                                            </cfdefaultcase>
                                        </cfswitch>
                                        <!--- --->
                                    </cfif>
                                </cfcase>
                            </cfswitch>
                        </cfloop>
                        <cfset resp[arraylen(resp)].actions_interpreted[cuNumAction]=interpreted_cmd>
                        <!--- assign --->
                        <cfset resp[arraylen(resp)].actions[cuNumAction]=actiontemp>
                        <cfset actiontemp=ArrayNew(1)>
                    </cfif>
                    <!---
                    --->
                </cfloop>
            </cfcase>
            <cfcase value="com.flagstone.transform.image.defineimage,com.flagstone.transform.image.defineimage2">
                <!--- IMAGE: DefineImage --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="image">
                <cfset resp[arraylen(resp)].width=element.getWidth()>
                <cfset resp[arraylen(resp)].height=element.getHeight()>
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <!--- --->
                <cfset enc=this.flagstone.transform.util.image.BufferedImageEncoder.init()>
                <cfset enc.setImage(element)>
                <cfset resp[arraylen(resp)].extension=".png">
                <cfset resp[arraylen(resp)].contentType="image/png">
                <cfset resp[arraylen(resp)].bufferedImage=enc.getBufferedImage()>
                <cfset tmp_file=this.temporaldir & idpos & ".tmp">
                <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".png")>
                <!--- write bufferedImage to file --->
                <cfset this.javax.imageio.ImageIO.write(enc.getBufferedImage(),"png",this.java.io.File.init(resp[arraylen(resp)].file))>
            </cfcase>
            <cfcase value="com.flagstone.transform.image.definejpegimage,com.flagstone.transform.image.definejpegimage2,com.flagstone.transform.image.definejpegimage3,com.flagstone.transform.image.definejpegimage4">
                <!--- IMAGE: DefineJpegImage --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="image">
                <cfset resp[arraylen(resp)].width=element.getWidth()>
                <cfset resp[arraylen(resp)].height=element.getHeight()>
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <!--- --->
                <cfset resp[arraylen(resp)].extension=".jpeg">
                <cfset resp[arraylen(resp)].contentType="image/jpeg">
                <cfset resp[arraylen(resp)].bufferedImage=this.javax.imageio.ImageIO.read(toJava("java.io.ByteArrayInputStream",this.ImageHelper.normalizeJpegImage(element.getImage())))>
                <cfset tmp_file=this.temporaldir & idpos & ".tmp">
                <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".jpg")>
                <!--- write bufferedImage to file --->
                <cfset this.javax.imageio.ImageIO.write(resp[arraylen(resp)].bufferedImage,"jpeg",this.java.io.File.init(resp[arraylen(resp)].file))>
            </cfcase>
            <cfcase value="com.flagstone.transform.framelabel">
                <!--- FRAME LABEL --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="framelabel">
                <cfset resp[arraylen(resp)].label=element.getLabel()>
                <cfset resp[arraylen(resp)].isAnchor=element.isAnchor()>
            </cfcase>
            <cfcase value="com.flagstone.transform.font.definefont2,com.flagstone.transform.font.definefont3">
                <!--- FONT DEFINITION --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="font">
                <cfset resp[arraylen(resp)].name=element.getName()>
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <cfset resp[arraylen(resp)].codes=element.getCodes()>
                <cfset resp[arraylen(resp)].language=element.getLanguage().name()>
                <cfset resp[arraylen(resp)].encoding=element.getEncoding().name()>
                <cfset resp[arraylen(resp)].is_bold=element.isBold()>
                <cfset resp[arraylen(resp)].is_italic=element.isItalic()>
                <cfset resp[arraylen(resp)].is_small=element.isSmall()>
                <!---<cfset resp[arraylen(resp)].shapes=element.getShapes()>--->
                <!---<cfset resp[arraylen(resp)].advances=element.getAdvances()>--->
                <!---<cfset resp[arraylen(resp)].kernings=element.getKernings()>--->
            </cfcase>
            <cfcase value="com.flagstone.transform.text.definetext,com.flagstone.transform.text.definetext2">
                <!--- TEXT STRING --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="swftext">
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <!--- PREPARE (try) to decode glyphs TO TEXT --->
                <!--- search first matched previous font type --->
                <cfset fontpos=0>
                <cfloop index="qrr" from="#arraylen(resp)#" to="1" step="-1">
                    <cfif resp[qrr].type eq "font" or resp[qrr].type eq "swffont">
                        <cfset fontpos=qrr>
                        <cfbreak/>
                    </cfif>
                </cfloop>
                <cfset tt=element.getSpans()>
                <cfset the_text="">
                <cfset the_word="">
                <cfset resp[arraylen(resp)].spans=ArrayNew(1)>
                <!--- --->
                <cfloop index="qtt" from="1" to="#arraylen(tt)#" step="+1">
                    <cfset resp[arraylen(resp)].spans[qtt]=StructNew()>
                    <cfset resp[arraylen(resp)].spans[qtt].identifier=tt[qtt].getIdentifier()>
                    <cfset resp[arraylen(resp)].spans[qtt].color=StructNew()>
                    <cftry>
	                    <cfset resp[arraylen(resp)].spans[qtt].color.alpha=tt[qtt].getColor().getAlpha()>
                        <cfcatch type="any">
                        	<cfset resp[arraylen(resp)].spans[qtt].color.alpha=-1>
                        </cfcatch>
					</cftry>
                    <cftry>
	                    <cfset resp[arraylen(resp)].spans[qtt].color.red=tt[qtt].getColor().getRed()>
						<cfset resp[arraylen(resp)].spans[qtt].color.green=tt[qtt].getColor().getGreen()>
                        <cfset resp[arraylen(resp)].spans[qtt].color.blue=tt[qtt].getColor().getBlue()>
                        <cfcatch type="any">
	                        <cfset resp[arraylen(resp)].spans[qtt].color.red=-1>
	                        <cfset resp[arraylen(resp)].spans[qtt].color.green=-1>
	                        <cfset resp[arraylen(resp)].spans[qtt].color.blue=-1>
                        </cfcatch>
                    </cftry>
                    <cfset resp[arraylen(resp)].spans[qtt].offset_x=tt[qtt].getOffsetX()>
                    <cfset resp[arraylen(resp)].spans[qtt].offset_y=tt[qtt].getOffsetY()>
                    <cfset resp[arraylen(resp)].spans[qtt].font_name=resp[fontpos].name>
                    <cfset resp[arraylen(resp)].spans[qtt].font_id=resp[fontpos].identifier>
                    <cfset resp[arraylen(resp)].spans[qtt].font_lang=resp[fontpos].language>
                    <cfset resp[arraylen(resp)].spans[qtt].font_encoding=resp[fontpos].encoding>
                    <cfset resp[arraylen(resp)].spans[qtt].characters=ArrayNew(1)>
                    <cfset tti=tt[qtt].getCharacters()>
                    <cfloop index="qqtt" from="1" to="#arraylen(tti)#" step="+1">
                    	<cftry>
							<cfset resp[arraylen(resp)].spans[qtt].characters[qqtt]=StructNew()>
                            <!---<cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].advance=tti[qqtt].getAdvance()>--->
                            <cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].glyph_index=tti[qqtt].getGlyphIndex()>
                            <!---<cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].font_code=resp[fontpos].codes[tti[qqtt].getGlyphIndex()+1]>--->
                            <cfset resp[arraylen(resp)].spans[qtt].characters[qqtt].glyph_char=chr(resp[fontpos].codes[tti[qqtt].getGlyphIndex()+1])>
                            <cfset the_word=the_word & resp[arraylen(resp)].spans[qtt].characters[qqtt].glyph_char>
                            <cfcatch type="any">
                            </cfcatch>
                        </cftry>
                    </cfloop>
                    <cfset resp[arraylen(resp)].spans[qtt].text=the_word>
                    <cfset the_text=ListAppend(the_text,the_word," ")>
                    <cfset the_word="">
                </cfloop>
                <cfset resp[arraylen(resp)].text=the_text>
                <!---<cfset resp[arraylen(resp)].transform=element.getTransform()>--->
            </cfcase>
            <cfcase value="com.flagstone.transform.text.definetextfield">
                <!--- TEXT FIELDS --->
                <cfset resp[arraylen(resp)+1]=StructNew()>
                <cfset resp[arraylen(resp)].pos=idpos>
                <cfset resp[arraylen(resp)].type="textfield">
                <cfset resp[arraylen(resp)].identifier=element.getIdentifier()>
                <cfset resp[arraylen(resp)].is=StructNew()>
                <cfset resp[arraylen(resp)].is.ReadOnly=element.isReadOnly()>
                <cfset resp[arraylen(resp)].is.HTML=element.isHtml()>
                <cfset resp[arraylen(resp)].is.Multiline=element.isMultiline()>
                <cfset resp[arraylen(resp)].is.wordwrapped=element.isWordWrapped()>
                <cfset resp[arraylen(resp)].is.password=element.isPassword()>
                <cfset resp[arraylen(resp)].is.selectable=element.isSelectable()>
                <cfset resp[arraylen(resp)].is.bordered=element.isBordered()>
                <cfset resp[arraylen(resp)].is.autosize=element.isAutoSize()>
                <cfset resp[arraylen(resp)].is.embedded=element.isEmbedded()>
                <cfset resp[arraylen(resp)].indent=element.getIndent()>
                <cfset resp[arraylen(resp)].width=element.getBounds().getWidth()>
                <cfset resp[arraylen(resp)].height=element.getBounds().getHeight()>
                <cfset resp[arraylen(resp)].color=StructNew()>
                <cfset resp[arraylen(resp)].color.alpha=element.getColor().getAlpha()>
                <cfset resp[arraylen(resp)].color.red=element.getColor().getRed()>
                <cfset resp[arraylen(resp)].color.green=element.getColor().getGreen()>
                <cfset resp[arraylen(resp)].color.blue=element.getColor().getBlue()>
                <cfset resp[arraylen(resp)].leading=element.getLeading()>
                <cfset resp[arraylen(resp)].font=element.getFontClass()>
                <cfset resp[arraylen(resp)].font_height=element.getFontHeight()>
                <cfset resp[arraylen(resp)].font_identifier=element.getFontIdentifier()>
                <cfset resp[arraylen(resp)].maxlength=element.getMaxLength()>
                <cfset resp[arraylen(resp)].alignment=element.getAlignment().toString()>
                <cfset resp[arraylen(resp)].text=element.getInitialText()>
                <cfset resp[arraylen(resp)].variable=element.getVariableName()>
                <!--- if fontname not found, try searching for font_id --->
                <cfif resp[arraylen(resp)].font_identifier lt element.getIdentifier()><!--- font id is previously defined than ourselfs --->
                    <cfloop index="qrr" from="#arraylen(resp)#" to="1" step="-1">
                    	<cftry>
							<cfif resp[qrr].identifier eq resp[arraylen(resp)].font_identifier>
                                <cfset resp[arraylen(resp)].font=resp[qrr].name>
                                <cfbreak/>
                            </cfif>
                            <cfcatch type="any">
                            	<cfbreak/>
                            </cfcatch>
                        </cftry>
                    </cfloop>
                </cfif>
            </cfcase>
            <cfdefaultcase>
            </cfdefaultcase>
        </cfswitch>
        <!--- --->
        <cfset arguments.toarray=resp>
    </cffunction>
    
    <!--- getElements() : returns array of struct --->
    <cffunction name="getElements" access="public" returntype="any" hint="Returns processed tag elements of current swf file.">
    	<cfset var resp=ArrayNew(1)>
        <cfset var element=""><cfset var tagtest="">
        <cfset var idpos=0>
        <cfset var tmp_str=""><cfset var tmp_file="">
        <cfset var the_word=""><cfset var the_text="">
        <cfset var t_directory=this.temporaldir>
        <cfset var f_number=1>
        <!--- --->
    	<cfif isDefined("this.movie")>
        	<cfif isDefined("this.elements")>
                <!--- create temporal subdir --->
				<cfset this.temporaldir=this.temporaldir & listlast(ListFirst(this.swf_file,"."),server.separator.file) & server.separator.file>
                <cfif not DirectoryExists(this.temporaldir)>
                	<cfdirectory action="create" directory="#this.temporaldir#"/>
                </cfif>
            	<!--- --->
                <cfloop index="element" array="#this.elements#">
					<cfset idpos=idpos+1>
                    <cfset tagtest=lcase(ListLast(element.getClass()," "))>
                    <cfswitch expression="#tagtest#">
                    	<cfcase value="com.flagstone.transform.showframe">
                        	<cfset f_number=f_number+1>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.sound.soundstreamblock">
                            <!--- AUDIO SOUND BLOCK --->
                            <cfif isDefined("stream")>
                                <!--- output audio stream block to current stream file --->
                                <cfset stream.write(element.getSound(), 4, arraylen(element.getSound())-4)>
                            </cfif>
                        </cfcase>
                        <cfcase value="com.flagstone.transform.sound.soundstreamhead">
                            <!--- MP3 SOUND HEADER (represents an audio file) --->
                            <cfset resp[arraylen(resp)+1]=StructNew()>
                            <cfset resp[arraylen(resp)].pos=idpos>
                            <cfset resp[arraylen(resp)].type="sound">
                            <cfset resp[arraylen(resp)].format=element.getFormat().name()>
                            <cfset resp[arraylen(resp)].playRate=element.getPlayRate()>
                            <cfset resp[arraylen(resp)].channels=element.getPlayChannels()>
                            <cfset resp[arraylen(resp)].sampleSize=element.getPlaySampleSize()>
                            <cfset resp[arraylen(resp)].streamRate=element.getStreamRate()>
                            <cfset resp[arraylen(resp)].streamChannels=element.getStreamChannels()>
                            <cfset resp[arraylen(resp)].streamSampleSize=element.getStreamSampleSize()>
                            <cfset resp[arraylen(resp)].streamSampleCount=element.getStreamSampleCount()>
                            <!--- close previous opened stream if there was one --->
                            <cfif isDefined("stream")>
                                <cfset stream.close()>
                            </cfif>
                            <!--- prepare to write file --->
                            <cfset tmp_file=this.temporaldir & idpos & ".tmp">
                            <cfswitch expression="#lcase(resp[arraylen(resp)].format)#">
                                <cfcase value="mp3">
                                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".mp3")>
                                </cfcase>
                                <cfcase value="native_pcm,pcm">
                                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".wav")>
                                </cfcase>
                                <cfcase value="adpcm">
                                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".vox")>
                                </cfcase>
                                <cfcase value="nellymoser_8k,nellymoser">
                                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".nel")>
                                </cfcase>
                                <cfcase value="speex">
                                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".spx")>
                                </cfcase>
                                <cfdefaultcase>
                                    <cfset resp[arraylen(resp)].file=ReplaceNoCase(tmp_file,".tmp",".mp3")>
                                </cfdefaultcase>
                            </cfswitch>
                            <!--- prepare audio stream out --->
                            <cfset this.stream=this.java.io.FileOutputStream.init(resp[arraylen(resp)].file)>
                        </cfcase>
                        <cfdefaultcase>
                            <cfset processElement(element,resp,idpos)>
                            <cfset resp[arraylen(resp)].frame=f_number>
                        </cfdefaultcase>
                    </cfswitch>
                </cfloop>
                <!--- close audio stream if one was found --->
                <cfif isDefined("stream")>
					<cfset stream.close()>
                </cfif>
                <!--- --->
            <cfelse>
	        	<cfthrow type="swfparser:getElements" message="You must first call method read(swffile)"/>
            </cfif>
        <cfelse>
        	<cfthrow type="swfparser:getElements" message="You must first call method init()"/>
        </cfif>
        <!--- --->
        <cfset this.temporaldir=t_directory>
        <cfreturn resp/>
	</cffunction>
    
    <!--- AS3Classes() : returns string --->
    <cffunction name="AS3Classes" access="public" returntype="any" hint="Dissasambles the given binary ABC data byte into an array of structured classes.">
    	<cfargument name="data" type="binary" required="yes" hint="Binary ABC data to dissasamble."/>
    	<cfset var resp="">
        <cfset var the_data=ToBinary(ToBase64(arguments.data))><!--- tobase64 and againt tobinary, to forcely cast binary to java byte[] --->
		<cfset var temp=this.flash.AbcInterpreter.init(toJava("java.lang.Byte[]",the_data),false,7,false)>
        <cfset ttt=temp.getClasses()>
        <cfset the_classes=ArrayNew(1)>
        <cfloop index="qc" from="1" to="#arraylen(ttt)#" step="+1">
        	<cfset the_classes[qc]=StructNew()>
            <cfset the_classes[qc].name=ttt[qc].getName()>
            <cfset the_classes[qc].extends=ttt[qc].getExtends()>
            <cfset the_classes[qc].implements=ttt[qc].getImplements()>
            <!--- vars --->
            <cfset the_vars=ttt[qc].getVars()>
            <cfset the_classes[qc].vars=ArrayNew(1)>
            <cftry>
                <cfloop index="qvv" from="1" to="#arraylen(the_vars)#" step="+1">
                	<cfif trim(the_vars[qvv].getName()) neq "">
						<cfset the_classes[qc].vars[arraylen(the_classes[qc].vars)+1]=StructNew()>
                        <cfset the_classes[qc].vars[arraylen(the_classes[qc].vars)].name=the_vars[qvv].getName()>
                        <cfset the_classes[qc].vars[arraylen(the_classes[qc].vars)].type=the_vars[qvv].getType()>
                        <cfset the_classes[qc].vars[arraylen(the_classes[qc].vars)].value=the_vars[qvv].getValue()>
                    </cfif>
                </cfloop>
            	<cfcatch type="any">
                </cfcatch>
            </cftry>
            <!--- methods --->
            <cfset the_classes[qc].functions=ArrayNew(1)>
            <cfset the_met=ttt[qc].getMethods()>
            <cftry>
                <cfloop index="qvv" from="1" to="#arraylen(the_met)#" step="+1">
                	<cfif trim(the_met[qvv].getName()) neq ""><!---  --->
						<cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)+1]=StructNew()>
                        <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].name=the_met[qvv].getName()>
                        <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].class=the_met[qvv].getClassname()>
                        <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].returntype=the_met[qvv].getReturntype()>
                        <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].content=the_met[qvv].getContent()>
						<!--- method params --->
                        <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].params=ArrayNew(1)>
                        <cftry>
							<cfset tmp_params=the_met[qvv].getParams()>
                            <cfloop index="qpa" from="1" to="#arraylen(tmp_params)#" step="+1">
                                <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].params[qpa]=tmp_params[qpa]>
                            </cfloop>
                            <cfcatch type="any">
                            </cfcatch>
                        </cftry>
                        <!--- method vars --->
                        <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].vars=ArrayNew(1)>
                        <cftry>
							<cfset tmp_vars=the_met[qvv].getVars()>
                            <cfloop index="qpa" from="1" to="#arraylen(tmp_vars)#" step="+1">
                                <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].vars[qpa]=StructNew()>
                                <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].vars[qpa].name=tmp_vars[qpa].getName()>
                                <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].vars[qpa].type=tmp_vars[qpa].getType()>
                                <cfset the_classes[qc].functions[arraylen(the_classes[qc].functions)].vars[qpa].value=tmp_vars[qpa].getValue()>
                            </cfloop>
                            <cfcatch type="any">
                            </cfcatch>
                        </cftry>
                    </cfif>
                </cfloop>
            	<cfcatch type="any">
                	<cfthrow type="swfparser:AS3Classes:method:#qvv#" message="#cfcatch.Message#"/>
                </cfcatch>
            </cftry>
        </cfloop>
        <!--- --->
        <cfreturn the_classes/>
	</cffunction>
    
    <cffunction name="opcode2script" access="public" returntype="string" hint="Tries to convert the given opcodes tags into readable actionscript">
    	<cfargument name="opcode" type="string" required="yes" hint="opcode tags to decode"/>
        <!--- METHOD TO BE DONE --->
		<cfset var thecodes=arguments.opcode>
        <cfset var sparser2_exists=false>
        <cfset var sparser2="">
        <cfset var resp="">
        <cfset var tmp_code="">
        <cftry>
        	<cfset sparser2=CreateObject("component","sparser2")>
            <cfset sparser2_exists=true>
            <cfcatch type="any">
            </cfcatch>
        </cftry>
        <cfif sparser2_exists>
        	<!--- process opcodes --->
            <!--- --->
        </cfif>
        <cfreturn resp/>
    </cffunction>
    
    <!--- private helper methods --->
	<!--- --->
    <cffunction name="toJava" access="public" returntype="any" output="false" hint="I convert the given ColdFusion data type to Java using a more robust conversion set than the native javaCast() function.">
        <cfargument name="type" type="string" required="true" hint="I am the Java data type being cast. I can be a core data type, a Java class. [] can be appended to the type for array conversions."/>
        <cfargument name="data" type="any" required="true" hint="I am the ColdFusion data type being cast to Java."/>
     	<cfargument name="initHint" type="string" required="false" default="" hint="When creating Java class instances, we will be using your ColdFusion values to initialize the Java instances. By default, we won't use any explicit casting. However, you can provide additional casting hints if you like (for use with JavaCast())."/>
        <!--- Define the local scope. --->
        <cfset var local = {} />
        <cfif !len( arguments.type )>
            <!--- Return given value, no casting at all. --->
            <cfreturn arguments.data />
        </cfif>
        <cfif reFindNoCase(("^(bigdecimal|boolean|byte|char|int|long|" & "float|double|short|string|null)(\[\])?"),arguments.type)>
            <cfreturn javaCast( arguments.type, arguments.data ) />
        </cfif>
        <cfif !reFind( "\[\]$", arguments.type )>
            <cfreturn createObject( "java", arguments.type ).init(toJava( arguments.initHint, arguments.data ))/>
        </cfif>
        <cfset arguments.type = listFirst( arguments.type, "[]" ) />
        <cfif !isArray( arguments.data )>
            <cfset local.tempArray = [ arguments.data ] />
            <cfset arguments.data = local.tempArray />
        </cfif>
        <cfset local.javaClass = createObject( "java", arguments.type ) />
        <cfset local.reflectArray = createObject("java","java.lang.reflect.Array") />
        <cfset local.javaArray = local.reflectArray.newInstance(local.javaClass.getClass(),arrayLen( arguments.data )) />
        <cfloop index="local.index" from="1" to="#arrayLen( arguments.data )#" step="1">
            <cfset local.reflectArray.set(local.javaArray,javaCast( "int", (local.index - 1) ),toJava(arguments.type,arguments.data[ local.index ],arguments.initHint)) />
        </cfloop>
        <!--- Return the Java array. --->
        <cfreturn local.javaArray />
    </cffunction>
	<cfscript>
    function struct2query(theArray){
        var columnNames = "";
        var columnList = "";
        var theQuery = queryNew("");
        var i=0;
        var j=0;
        if(NOT arrayLen(theArray))
            return theQuery;
    
        columnNames = structKeyArray(theArray[1]);
        columnList = ReplaceNoCase(arrayToList(columnNames),":","_","ALL"); //replace attribute names with : to _
        theQuery = queryNew(columnList);
        queryAddRow(theQuery, arrayLen(theArray));
        for(i=1; i LTE arrayLen(theArray); i=i+1){
            for(j=1; j LTE arrayLen(columnNames); j=j+1){
                // this is not the best way to do it!! :: skipping if column is invalid
                try {
                    querySetCell(theQuery, ReplaceNoCase(columnNames[j],":","_","ALL"), theArray[i][columnNames[j]], i);
                } catch(Any e) {
                }
            }
        }
        return theQuery;
    }
    </cfscript>
    <!--- --->
</cfcomponent>
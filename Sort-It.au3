#cs
   (c) Karl Hendrix M. Zarate
	  BS Computer Science 4th year, Season 1
	  2017

   Sort-it
#ce

#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <GUIButton.au3>
#include <File.au3>
#include <Array.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiListView.au3>
#include <Misc.au3>
#include <WinAPIFiles.au3>
#include <GuiTreeView.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <TrayConstants.au3>

splash()

Global $aFileList, $lv, $iI, $exten = "", $fileExtenArray[0]
Global $sDir = ""
Global $fileDir = ""
Global $hGUI
Global $lv2
Global $2d[0][2], $arr
Global $fileName = "", $iFileSize = ""
Global $file_ext = ""
Global $dir_size = 0
Global $tv_files ;TreeView Ctrl variable
Global $tv_parent, $tv_parent_cons = ""
Global $file_count_in, $file_count_final
Global $item_handle[0][2], $tv_child_item ;stores the item handle for treeview child items
Global $selected_items[0]
Global $working_directory = ""
Global $excluded_files[0]
Global $selected_string = ""
Global $archive_gui
Global $archive_opt, $password_field, $reenter_pw, $output_dir

Global $archive_name, $archive_type, $archive_password
HotKeySet("{x}", "close")
;HotKeySet("{o}", "OPEN")


Global $ft_class[0]

#cs
Global $ft_documents[] = [".docx", ".doc", ".pptx", ".ppt", ".xls", ".xlsx", ".pdf", ".pub", ".txt"]
Global $ft_pics[] = [".png", ".gif", ".jpeg", ".jpg", ".ai", ".psd"]
Global $ft_vid[] = [".mp4", ".MP4", ".avi", ".mov"]
Global $ft_music[] = [".mp3", ".aac", ".wav"]
Global $ft_compressed[] = [".rar", ".zip", ".7z", ".tar", ".iso", ".zipx"]
#ce

Global $ft_music[] = [".mp3", ".aac", ".wav", ".3ga", ".m4a", ".midi", ".m4p", ".ogg", ".wma", ".rec"]
Global $ft_vid[] = [".264", ".3gp", ".avi", ".dat", ".dvr", ".flv", ".h264", ".m4v", ".mkv", ".mov", ".mp4", ".mpeg", ".mpg", ".prproj", ".swf", ".wmv"]
Global $ft_pics[] = [".bmp", ".gif", ".ico", ".icon", ".jpeg", ".jpg", ".pcx", ".png", ".psd", ".psdx", ".raw"]
Global $ft_documents[] = [".txt", ".xml", ".text", ".doc", ".docm", ".docx", ".dot", ".dotm", ".dotx", ".epub", ".ind", ".indd", ".mpp", ".pdf", ".pmd", ".pot", ".potx", ".pps", ".ppsx", ".ppt", ".pptm", ".pptx", ".pub", ".wps", ".xps", ".xls", ".xlsx", "xlsm", ".accdb", ".accdt", ".mdb"]
Global $ft_compressed[] = [".7z", ".gz", ".gzip", ".jar", ".rar", ".tar", ".zip", ".iso"]

;unclassified
Global $ft_raw[] = [".arw", ".cr2", ".crw", ".dcr", ".dng", ".nef", ".orf", ".ptx", ".raf", ".raw", ".rw2"]

;global filter
Global $fileTypes[] = ["1", ".mp3", ".aac", ".wav", ".3ga", ".m4a", ".midi", ".m4p", ".ogg", ".wma", ".rec", ".264", ".3gp", ".avi", ".dat", ".dvr", ".flv", ".h264", ".m4v", ".mkv", ".mov", ".mp4", ".mpeg", ".mpg", ".prproj", ".swf", ".wmv", ".bmp", ".gif", ".ico", ".icon", ".jpeg", ".jpg", ".pcx", ".png", ".psd", ".psdx", ".raw", ".txt", ".xml", ".text", ".doc", ".docm", ".docx", ".dot", ".dotm", ".dotx", ".epub", ".ind", ".indd", ".mpp", ".pdf", ".pmd", ".pot", ".potx", ".pps", ".ppsx", ".ppt", ".pptm", ".pptx", ".pub", ".wps", ".xps", ".xls", ".xlsx", "xlsm", ".accdb", ".accdt", ".mdb", ".7z", ".gz", ".gzip", ".jar", ".rar", ".tar", ".zip", ".iso", "unclassified", ".au3"]

;file type arrays used for classifying file types
;Global $ft_source_codes[] = [".php", ".html", ".htm", ".sql", ".js", ".css"]

Global $_fileDetails[0][7] ;storess all the information of all the files listed
Global $_fd1[0][5] ;test

#cs
$_fileDetails cols
   col 0 - Name
   col 1 - size
   col 2 - type
   col 3 - full path
   col 4 - date
   col 5 - file classification
   col 6 - item handle (treeView)
#ce

;Global $fileTypes[] = ["1", ".docx", ".doc", ".pptx", ".ppt", ".pub", ".xls", ".xlsx", ".pdf", ".png", ".gif", ".jpeg", ".jpg", ".JPG", ".psd", ".mp3", ".rar", ".tar", ".zip", ".zipx", ".iso", ".7z", ".mp4", ".MP4", ".AVI", ".avi", ".wav", ".aac", ".mov", ".flv", ".mpg", ".ai", ".txt", ".au3", ".csv"]
;global array for file types used for file filtering

;test directory - lazy problems
;Global $test_dir = "C:\Users\Karl Hendrix\Desktop\test folder"

Func splash() ;splash screen
   Local $gui_splash = GUICreate("", 300, 150, -1, -1, BitOR($WS_SYSMENU, $WS_POPUP), 0)
   Local $image_splash = GUICtrlCreatePic(@ScriptDir & "\Resources\banner.jpg", 0, 0, 300, 150, BitOR($SS_NOTIFY, $WS_CLIPSIBLINGS))
   Local $prog_splash = GUICtrlCreateProgress(56, 104, 193, 9)
   GUISetState(@SW_SHOW, $gui_splash)
   For $i = 20 To 100 Step 20
	  GUICtrlSetData($prog_splash, $i)
	  Sleep(500)
   Next
   GUISetState(@SW_HIDE, $gui_splash)
EndFunc


Main()


Func Main()
Opt("GUIOnEventMode", 1)
    Local $hGUI = GUICreate("SortIt" ,620, 420)
	GUISetIcon(@ScriptDir & "\Resources\icon.ico")
	TraySetIcon(@ScriptDir & "\Resources\icon.ico")

	  FileDelete("C:\Users\Karl Hendrix\Desktop\asd\*")

	;buttons
	Local $btn_dsgn = BitOR($BS_ICON, $BS_BITMAP)
    Local $open_diag = GUICtrlCreateButton("Choose Directory", 20, 20, 40, 40, BitOR($BS_ICON, $BS_BITMAP, $BS_FLAT))
	#cs
	Local $ico_list = _GUIImageList_Create(24, 24)
	_GUIImageList_AddIcon($ico_list, @ScriptDir & "\Resources\open1.ico")
	_GUICtrlButton_SetImageList($open_diag, $ico_list)
	#ce
	GUICtrlSetTip(-1, "Open Directory")
	GUICtrlSetOnEvent($open_diag, "OPEN")
	_GUICtrlButton_SetImage($open_diag, @ScriptDir & "/Resources/open1.ico")
	_GUICtrlButton_SetText($open_diag, "Choose Directory")
	;Local $idClose = GUICtrlCreateButton("Exit", 475, 20, 120, 40)
   ;GUICtrlSetOnEvent($idClose, "close")

    Local $sort_btn = GUICtrlCreateButton("Sort", 453, 255, 120, 35, BitOR($BS_ICON, $BS_BITMAP, $BS_FLAT))
	GUICtrlSetOnEvent($sort_btn, "Sort")
	GUiCtrlSetTip(-1, "Sort")
	_GUICtrlButton_SetImage($sort_btn, @ScriptDir & "/Resources/sort.ico")
	Local $id_size = _GUICtrlButton_GetIdealSize($sort_btn)
	ConsoleWrite($id_size)

	Local $archive_btn = GUICtrlCreateButton("Compress", 453, 295, 120, 35, BitOR($BS_ICON, $BS_BITMAP, $BS_FLAT))
    GUICtrlSetOnEvent($archive_btn, "archive_diag")
	GUICtrlSetTip(-1, "Archive")
	_GUICtrlButton_SetImage($archive_btn, @ScriptDir & "/Resources/compress.ico")



;label
GUICtrlCreateLabel("Directory", 70, 35)



;menu
Local $idFilemenu = GUICtrlCreateMenu("&File")
Local $exit_item = GUICtrlCreateMenuItem("Exit", $idFilemenu)
GUICtrlSetOnEvent($exit_item, "close")
Local $idFilemenu = GUICtrlCreateMenu("&Menu")
Local $idFilemenu = GUICtrlCreateMenu("&Help")
Local $idFilemenu = GUICtrlCreateMenu("&Settings")


;listview for content
   #cs
   $lv = GUICtrlCreateListView("File Name", 20, 75, 385, 300)
   _GUICtrlListView_AddColumn($lv, "Size", 50)
   _GUICtrlListView_AddColumn($lv, "Extension", 65)
   _GUICtrlListView_AddColumn($lv, "Directory", 175)
   #ce

   ;Sample code for TreeView
   Local $tv_parent, $tv_child
   Local $iStyle = BitOR($TVS_HASBUTTONS, $TVS_HASLINES, $TVS_LINESATROOT, $TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES) ;TreeView Style declared as a variable
   $tv_files = GUICtrlCreateTreeView(20, 75, 385, 300, $iStyle, $WS_EX_CLIENTEDGE) ;$iStyle declared for TreeView Style

;listview for number of content
$lv2 = GUICtrlCreateListView("File Type", 430, 75, 165, 170)
   _GUICtrlListView_AddColumn($lv2, "File Count", 75)

    $hImage = _GUIImageList_Create(16, 16, 5, 3)


    _GUICtrlTreeView_SetNormalImageList($tv_files, $hImage)

   _GUICtrlTreeView_BeginUpdate($tv_files)
   _GUIImageList_AddIcon($hImage, "shell32.dll", 70)
   _GUIImageList_AddIcon($hImage, "shell32.dll", 266)
   _GUICtrlTreeView_EndUpdate($tv_files)

;close
    GUISetState(@SW_SHOW, $hGUI)

Local $iWait = 20; wait 20ms for next progressstep
    Local $iSavPos = 0; progressbar-saveposition

    Local $idMsg, $idM
    ; Loop until the user exits.
	#cs
    Do
        $idMsg = GUIGetMsg()
        If $idMsg = $idButton Then
            GUICtrlSetData($idButton, "STOP")
            For $i = $iSavPos To 100

                $idM = GUIGetMsg()

                If $idM = -3 Then ExitLoop

                If $idM = $idButton Then
                    GUICtrlSetData($idButton, "SORT")
                    $iSavPos = $i;save the current bar-position to $iSavPos
                    ExitLoop
                Else
                    $iSavPos = 0
                    GUICtrlSetData($idProgressbar1, $i)
                    Sleep($iWait)
                EndIf
            Next
            If $i > 100 Then
                ;       $iSavPos=0
                GUICtrlSetData($idButton, "SORT")
            EndIf
        EndIf
    Until $idMsg = $GUI_EVENT_CLOSE
	#ce
	  ;Call("sam", $test_dir)
   While 1
	  Sleep(100)
   WEnd

EndFunc

Func close() ;force close function
   Exit 0
EndFunc



 Func OPEN()
    ; Create a constant variable in Local scope of the message to display in FileSelectFolder.
    Local Const $sMessage = "Select a folder"

    ; Display an open dialog to select a file.
    Local $sFileSelectFolder = FileSelectFolder($sMessage, "")
	$working_directory = $sFileSelectFolder
    If @error Then
        ; Display the error message.
        MsgBox($MB_SYSTEMMODAL, "", "No folder was selected.")
    Else
        ; Display the selected folder.
        ;MsgBox($MB_SYSTEMMODAL, "", "You chose the following folder:" & @CRLF & $sFileSelectFolder)
		If DirGetSize($sFileSelectFolder) == 0 Then
		   MsgBox(0 + 16, "Empty Directory", "Directory is empty!")
		 Else
			Call("sam", $sFileSelectFolder) ;calls the sam() function and passes the value of the selected folder to the
			GUICtrlCreateLabel($sFileSelectFolder, 70, 35)
		EndIf
	 EndIf
  EndFunc

Func reset_all()
   _GUICtrlTreeView_DeleteAll($tv_files)
   $aFileList = ""
   $working_directory = ""
   $aItems = ""
EndFunc




 Func sam($dir)
   $sDir = $dir
   Dim $file_class = ""
   Dim $temp_files[0]
   Dim $files, $folders, $tv_parent, $tv_child
   $file_count_in = UBound(_FileListToArrayRec($sDir, "*", $FLTAR_FILES, $FLTAR_RECUR, 0, $FLTAR_NOPATH)) - 1
   $aFileList = _FileListToArrayRec($sDir, "*", $FLTAR_FILESFOLDERS, $FLTAR_RECUR,  0, $FLTAR_FULLPATH)
   ;ArrayDisplay($aFileList)

   $tv_parent = _GUICtrlTreeView_Add($tv_files, 0, $sDir, 1, 1)
   $tv_parent_cons = $tv_parent
   _SearchFolder($sDir)
   _GUICtrlTreeView_Expand($tv_files)
   $dir_size = DirGetSize($sDir)
   if @error = 1 Then
	  MsgBox(0, "Error", @error)
	  Exit
   EndIf
   if @error = 4 Then
	  MsgBox(0, "Error", @error)
	  Exit
   EndIf
   $aFileList = Call("_FilterFileTypes", $aFileList)
   Local $i
     Local $aItems[5000][5]
	 Local $cArray[1]

    For $iI = 0 To UBound($aFileList) - 1
        $aItems[$iI][0] = Call("_FileGetName", $sDir & "\" & $aFileList[$iI]) ;File Name
		$aItems[$iI][1] = Call("_FileGetExt", $aFileList[$iI]) ;File Extension
		$aItems[$iI][2] = Call("_FileGetSize", $aFileList[$iI]) ; File size
		$aItems[$iI][3] = $aFileList[$iI] ;File Directory
		_ArrayAdd($fileExtenArray, Call("_FileGetExt", $sDir & "\" & $aFileList[$iI]))
		$file_class = Call("file_cat", $aItems[$iI][1])
		;ConsoleWrite($aItems[$iI][1] & " - " & $iI & @CR)
		_ArrayAdd($_FileDetails, $aItems[$iI][0] & "|" & $aItems[$iI][1] & "|" & $aItems[$iI][2] & "|" & $aFileList[$iI] & "|" & FileGetTime($aFileList[$iI], $FT_MODIFIED, $FT_STRING) & "|" & $file_class);cl
		;FileCopy($aFileList[$iI], @TempDir & "\" & "Au3Files\")
	Next
    ;_GUICtrlListView_AddArray($lv, $aItems)

	_ArraySort($fileExtenArray) ; sorts the array first before counting all the file extensions
	Local $x
	Local $fileExten [5000][1]
	Local $Exten = Call("countElements", $fileExtenArray)
   _GUICtrlListView_AddArray($lv2, $Exten)
EndFunc

Func _FileGetExt($fileDir) ;function that will take the file extension for each file in the directory
   Local $source = $fileDir
   Local $aDrive = "", $aDir = "", $aFileName = "", $aExtension = ""
   Local $aPathSplit = _PathSplit($source, $aDrive, $aDir, $aFileName, $aExtension)
   $exten = $aPathSplit[4]
   Return $exten
EndFunc

Func _FileGetName($fileDir) ;function that will take the file extension for each file in the directory
   Local $source = $fileDir
   Local $aDrive = "", $aDir = "", $aFileName = "", $aExtension = ""
   Local $aPathSplit = _PathSplit($source, $aDrive, $aDir, $aFileName, $aExtension)
   $fileName = $aPathSplit[3]
   Return $fileName
EndFunc

Func _FileGetSize($fileDir) ;function that will get the filenae of each file in the chosen directory
   $iFileSize = FileGetSize($fileDir)
	Local $iIndex = 0, $aArray = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
	While $iFileSize > 1023
		$iIndex += 1
		$iFileSize /= 1024
	WEnd
	Return Round($iFileSize) & $aArray[$iIndex]
EndFunc

Func countElements($_fileExten) ;function that will count all the unique file types in a directory
   Local $fileExten = $_fileExten
   $arr = $2d
   Local $x, $cnt = 0, $current = Null
   For $x = 0 To UBound($fileExten) - 1
	  If $fileExten[$x] <> $current Then
		 If $cnt > 0 Then
		 _ArrayAdd($arr, $current & "|" & $cnt)
		 EndIf
	  $current = $fileExten[$x]
	  $cnt = 1
   Else
	  $cnt += 1
   EndIf
   Next

   If $cnt > 0 Then
	  _ArrayAdd($arr, $current & "|" & $cnt)
	  Return $arr
   EndIf
EndFunc


Func _FilterFileTypes($fileDir) ;Filter Function referring from fileTypes array that contains all the accepted file types for the system
   Local $x, $y, $z, $ext, $x = 0
   Local $found, $found1
   Local $exten_array[0]
   Local $fileList = $fileDir
   _ArrayDelete($fileList, 0)
   Local $fileList_count = UBound($fileList) - 1

   For $x = 0 To $fileList_count Step 1
	  $ext = Call("_FileGetExt", $fileList[$x])
	  $found = _ArraySearch($fileTypes, $ext)
	  If $found <= 0 Then
		 $found1 = _ArraySearch($fileList, $fileList[$x])
		_ArrayDelete($fileList, $found1)
		$x -= 1
	 EndIf
	  If $x = UBound($fileList) - 1 Then
		 ExitLoop
	  EndIf
   Next
   Return $fileList
EndFunc

#cs
Func _GenerateLog($Items)
   Local $hFile = FileOpen(@ScriptDir & "\Example.txt", 1)
_FileWriteLog($hFile, $Items) ; Write to the logfile passing the filehandle returned by FileOpen.
FileClose($hFile) ; Close the filehandle to release the file.
EndFunc
#ce

Func file_cat($file_ext) ;file classifier function
   Dim $class
   Dim $fileExt = $file_ext
	  If _ArraySearch($ft_documents, $fileExt) >= 0 Then
		 ;ConsoleWrite("Document" & " - " & $_fileDetails[$x][2] & @CR)
		 ;_ArrayAdd($ft_class, "Document")
		 $class = "Document"

	  ElseIf _ArraySearch($ft_pics, $fileExt) >= 0 Then
		 ;ConsoleWrite("Picture" & " - " & $_fileDetails[$x][2] & @CR)
		 ;_ArrayAdd($ft_class, "Picture")
		 $class = "Picture"
	  ElseIf _ArraySearch($ft_vid, $fileExt) >= 0 Then
		 ;ConsoleWrite("Video" & " - " & $_fileDetails[$x][2] & @CR)
		 ;_ArrayAdd($ft_class, "Video")
		 $class = "Video"
	  ElseIf _ArraySearch($ft_music, $fileExt) >= 0 Then
		 ;ConsoleWrite("Music" & " - " & $_fileDetails[$x][2] & @CR)
		 ;_ArrayAdd($ft_class, "Music")
		 $class = "Music"
	  Elseif _ArraySearch($ft_compressed, $fileExt) >= 0 Then
		 ;ConsoleWrite("Compressed" & " - " & $_fileDetails[$x][2] & @CR)
		 ;_ArrayAdd($ft_class, "Compressed")
		 $class = "Compressed"
	  Else
		 ;ConsoleWrite("null" & " - " & $_fileDetails[$x][2] & @CR)
		 ;_ArrayAdd($ft_class, "None")
		 $class = "Null"

	  EndIf
	  ;ConsoleWrite($_fileDetails[$x][2] & @CR)
   Return $class
   ;_ArrayDisplay($ft_class, "")
EndFunc



Func Sort() ;Start of main sort function
   Dim $working_dir = $sDir
   Dim $f_class[0], $x, $y, $z, $a
   Dim $sub_dir[0]
   Dim $fd_array, $file_year, $file_month
   Dim $year_array[0]
   Dim $keyword
   Dim $slctd_opt = 2 ;use this control variable for the user-selected option in to which the document folder will be sorted

If $working_dir == "" OR $_fileDetails == Null Then
	  MsgBox(0 + 16, "Error", "No Selected Directory!")
   Else

   DirCopy($working_dir, @TempDir & "\Au3Files", $FC_OVERWRITE) ;copies the whole directory to a temp folder

   For $x = 0 To UBound($_fileDetails) - 1
	 _ArrayAdd($f_class, $_fileDetails[$x][5])
  Next


  For $y = 0 To UBound($f_class) - 1 ;creates directories based on file classifications
   If $f_class[$y] <> "Null" Then
	 If DirGetSize($working_dir & "\" & $f_class[$y]) <> -1 Then
		 ConsoleWrite("ok")
	  Else
		 DirCreate($working_dir & "\" & $f_class[$y])
	  EndIf
   Else
	  If DirGetSize($working_dir & "\" & $f_class[$y]) <> - 1 Then
		 ConsoleWrite("Null - ok")
	  Else
		 DirCreate($working_dir & "\Unclassified")
	  EndIf
   EndIf
Next


For $x = 0 To UBound($_fileDetails) - 1
   If $_fileDetails[$x][5] == "Picture" Then
	  $fd_array = FileGetTime($_fileDetails[$x][3], $FT_MODIFIED, $FT_ARRAY)
	  $file_year = $fd_array[0]
	  $file_month = $fd_array[1]
	  DirCreate($working_dir & "\Picture\" & $file_year)

   ElseIf $_fileDetails[$x][5] == "Document" Then

   If $slctd_opt == 1 Then
	  $fd_array = FileGetTime($_fileDetails[$x][3], $FT_MODIFIED, $FT_ARRAY)
	  $file_year = $fd_array[0]
	  DirCreate($working_dir & "\Document\" & $file_year)
	  FileMove($_fileDetails[$x][3], $working_dir & "\Document\" & $file_year)

   ElseIf $slctd_opt == 2 Then
			$fd_array = FileGetTime($_fileDetails[$x][3], $FT_MODIFIED, $FT_ARRAY)
			$file_year = $fd_array[0]
			DirCreate($working_dir & "\Document\" & $file_year)

			$keyword = StringSplit($_fileDetails[$x][0], "-")
			If @error == 1 Then
			   FileMove($_fileDetails[$x][3], $working_dir & "\Document\" & $file_year)
			Else
			   DirCreate($working_dir & "\Document\" & $file_year & "\" & $keyword[1])
			   FileMove($_fileDetails[$x][3], $working_dir & "\Document\" & $file_year & "\" & $keyword[1])
			EndIf

   ElseIf $slctd_opt == 3 Then
	  If $_fileDetails[$x][1] == ".docx" Or $_fileDetails[$x][1] == ".doc" Then
		 DirCreate($working_dir & "\Document\Word Documents")
		 FileMove($_fileDetails[$x][3], $working_dir & "\Document\Word Documents")

	  ElseIf $_fileDetails[$x][1] == ".pptx" Or $_fileDetails[$x][1] == ".ppt" Then
		 DirCreate($working_dir & "\Document\PowerPoint Presentations")
		 FileMove($_fileDetails[$x][3], $working_dir & "\Document\PowerPoint Presentations")

	  ElseIf $_fileDetails[$x][1] == ".xls" Or $_fileDetails[$x][1] == ".xlsx" Then
		 DirCreate($working_dir & "\Document\Excel Spreadsheets")
		 FileMove($_fileDetails[$x][3], $working_dir & "\Document\Excel Spreadsheets")

	  ElseIf $_fileDetails[$x][1] == ".pdf" Then
		 DirCreate($working_dir & "\Document\PDF Files")
		 FileMove($_fileDetails[$x][3], $working_dir & "\Document\PDF Files")

	  ElseIf $_fileDetails[$x][1] == ".txt" Then
		 DirCreate($working_dir & "\Document\Text Files")
		 FileMove($_fileDetails[$x][3], $working_dir & "\Document\Text Files")
	  EndIf
   EndIf
EndIf
Next
;_ArrayDisplay($year_array)



For $z = 0 To UBound($_fileDetails) - 1
   #cs
	  If $_fileDetails[$z][5] == "Document" Then
		  $fd_array = FileGetTime($_fileDetails[$z][3], $FT_MODIFIED, $FT_ARRAY)
		 $file_year = $fd_array[0]
		 FileMove($_fileDetails[$z][3], $working_dir & "\Document\" & $file_year)
   #ce
	 If $_fileDetails[$z][5] == "Picture" Then
		 $fd_array = FileGetTime($_fileDetails[$z][3], $FT_MODIFIED, $FT_ARRAY)
		 $file_year = $fd_array[0]
		 $file_month = $fd_array[1]
			FileMove($_fileDetails[$z][3], $working_dir & "\Picture\" & $file_year)
	  ElseIf $_fileDetails[$z][5] == "Video" Then
		 FileMove($_fileDetails[$z][3], $working_dir & "\" & $_fileDetails[$z][5])

	  ElseIf $_fileDetails[$z][5] == "Music" Then
		 FileMove($_fileDetails[$z][3], $working_dir & "\" & $_fileDetails[$z][5])

	  ElseIf $_fileDetails[$z][5] == "Compressed" Then
		 FileMove($_fileDetails[$z][3], $working_dir & "\" & $_fileDetails[$z][5])

	  ElseIf $_fileDetails[$z][5] == "Null" Then
		 FileMove($_fileDetails[$z][3], $working_dir & "\Unclassified")
	  EndIf
   Next

   $sub_dir = _FileListToArrayRec($working_dir, "*", $FLTAR_FOLDERS, $FLTAR_RECUR,  0, $FLTAR_FULLPATH) ;still have problems deleting subdirectories
   For $a = 0 To UBound($sub_dir) - 1
		 DirRemove($sub_dir[$a], $DIR_DEFAULT = 1)
	  Next

	  $file_count_final = UBound(_FileListToArrayRec($working_dir, "*", $FLTAR_FILES, $FLTAR_RECUR, 0, $FLTAR_NOPATH)) - 1
	  If $file_count_final <> $file_count_in Then
		 MsgBox(0 + 16, "Files Missing", "The System Will Restore Changes to the Directory")
		 DirRemove($working_dir)
		 DirCopy(@TempDir & "\Au3Files", 1)
		 DirRemove(@TempDir & "\Au3Files", 1)
	  Else
		 DirRemove(@TempDir & "\Au3Files", 1)
	  EndIf
   _GUICtrlTreeView_DeleteAll($tv_files)
   _ResTreeView()
   MsgBox(0, "Complete", "Sorting Complete!")
EndIf
EndFunc

Func _SearchFolder($folder)
    $files = _FileListToArray($folder,"*", $FLTAR_FILES,$FLTAR_NOPATH)
    $folders = _FileListToArray($folder,"*", $FLTAR_FOLDERS,$FLTAR_NOPATH)
	_FileFunc($files, $folder)
    _FolderFunc($folders,$folder)
EndFunc

Func _FileFunc($files,$folder)
   Dim $cnt
   Local $items[5000][5]
   $files = Call("_FilterFileTypes", $files)
   For $x = 0 To UBound($files) - 1
	  _GUICtrlTreeView_BeginUpdate($tv_files)
		 $tv_child_item = _GUICtrlTreeView_AddChild($tv_files, $tv_parent, $files[$x], 0, 0)
		 _ArrayAdd($_fd1, $folder & "\" & "|" & $files[$x] & "|" & $tv_child_item)
	  _GUICtrlTreeView_EndUpdate($tv_files)
   Next
EndFunc

Func _FolderFunc($folders,$parentdir)
    Local $x = UBound($folders) - 1
   Local $y

   If $x >= 1 Then
	  $y = $tv_parent
   EndIf

    For $i = 1 To UBound($folders) - 1
	  _GUICtrlTreeView_BeginUpdate($tv_files)
	  $tv_parent = _GUICtrlTreeView_AddChild($tv_files, $y, $folders[$i], 1, 1)
	  _GUICtrlTreeView_EndUpdate($tv_files)

	  _SearchFolder($parentdir & "\" & $folders[$i])
	 Next
	 $tv_parent = $tv_parent_cons
  EndFunc


Func get_checked() ;function to get the checked items in the treeView checkbox
   For $x = 0 To UBound($_fd1) - 1
	 If _GUICtrlTreeView_GetChecked($tv_files, $_fd1[$x][2]) == TRUE Then
		_ArrayAdd($selected_items, $_fd1[$x][0] & $_fd1[$x][1])
		$selected_string = $selected_string & '"' & $_fd1[$x][0] & $_fd1[$x][1] & '"' & " "
	  EndIf
   Next
EndFunc


Func _ResTreeView() ;function to reset treeview after sorting the files
   $tv_parent = _GUICtrlTreeView_Add($tv_files, 0, $working_directory, 1, 1)
   $tv_parent_cons = $tv_parent
   _SearchFolder($sDir)
   _GUICtrlTreeView_Expand($tv_files)
EndFunc


Func archive_diag() ;archive dialog box
   Opt("GUIOnEventMode", 1)
   Local $ES_PASSWORD = 0x0020

$Form1 = GUICreate("Archive", 283, 307, 192, 120)
GUICtrlCreateLabel("File Name:", 16, 20, 54, 17)
$archive_name = GUICtrlCreateInput("", 104, 16, 169, 21)

GUICtrlCreateLabel("Output Directory:", 16, 50, 84, 17)
$output_dir = GUICtrlCreateInput($working_directory, 104, 48, 169, 21)
Local $change_dir = GUICtrlCreateButton("Choose Directory", 176, 77, 99, 25, $WS_GROUP)
GUICtrlSetOnEvent($change_dir, "choose_output_dir")


$archive_opt = GUICtrlCreateCheckbox("Archive Whole Directory?", 16, 82, 153, 17)

$Group1 = GUICtrlCreateGroup("Encryption", 8, 120, 265, 137)
GUICtrlCreateLabel("Enter Password:", 16, 144, 81, 17)
$password_field = GUICtrlCreateInput("", 16, 160, 249, 21, $ES_PASSWORD)
GUICtrlCreateLabel("Re-enter Password:", 16, 200, 97, 17)
$reenter_pw = GUICtrlCreateInput("", 16, 216, 249, 21, $ES_PASSWORD)

GUICtrlCreateGroup("", -99, -99, 1, 1)
Local $ok_button = GUICtrlCreateButton("OK", 160, 264, 57, 33, $WS_GROUP)
GUICtrlSetOnEvent($ok_button, "Archive")
Local $close = GUICtrlCreateButton("Cancel", 216, 264, 57, 33, $WS_GROUP)
GUICtrlSetOnEvent($close, "close_archive_gui")
GUISetState(@SW_SHOW)


   ;Local $file_diag = FileOpenDialog("Open Files", $working_directory, "All(*.*)", $FD_MULTISELECT)
Endfunc

Func close_archive_gui()
   GUIDelete("Archive")
EndFunc

Func choose_output_dir()
   Local $dir = FileSelectFolder("Select Output", "")
   GUICtrlSetData($output_dir, $dir)
EndFunc


Func Archive()
   $archive_name = GUICtrlRead($archive_name)
   $archive_type = ".zip"
   $output_dir = GUICtrlRead($output_dir)
   $password_field = GUICtrlRead($password_field)
   $reenter_pw = GUICtrlRead($reenter_pw)
   get_checked()
   If $archive_name <> "" And $archive_type <> "" Then
	  If $password_field == "" And $reenter_pw == "" Then
		 If GUICtrlRead($archive_opt) = 1 Then
			RunWait('"' & @ScriptDir & '\Archive\zip' & '"' & " a " & $archive_name & $archive_type & " " & '"' & $working_directory & '/*' & '"' & " -mx1")
			;RunWait('"' & @ScriptDir & '\Archive\7za' & '"' & " a " & $archive_name & $archive_type & " " & '"' & $working_directory & '/*' & '"')
		 Else
			RunWait('"' & @ScriptDir & '\Archive\zip' & '"' & " a " & $archive_name & $archive_type & " " & $selected_string & " -mx1")
		 EndIf
			   If @error = 0 Then
				  FileMove(@ScriptDir & "\" & $archive_name & $archive_type, $output_dir)
				  get_compression_data()
				  $selected_string = ""
				  close_archive_gui()
			   EndIf
	  ElseIf $password_field <> "" And $reenter_pw <> "" Then
			If $password_field == $reenter_pw Then
			    If GUICtrlRead($archive_opt) = 1 Then
				  RunWait('"' & @ScriptDir & '\Archive\zip' & '"' & " a " & $archive_name & $archive_type & " " & '"' & $working_directory & '/*' & '"' & " " & "-p" & $password_field & "-mx1")
			   Else
				  RunWait('"' & @ScriptDir & '\Archive\zip' & '"' & " a " & $archive_name & $archive_type & " " & $selected_string & " " & "-p" & $password_field & " -mx1")
			   EndIf
			   If @error = 0 Then
				  FileMove(@ScriptDir & "\" & $archive_name & $archive_type, $output_dir)
				  get_compression_data()
				  $selected_string = ""
				  close_archive_gui()
			   EndIf
			Else
			   MsgBox(0 + 16, "Error", "Password Mismatch!")
			   $selected_string = ""
			   close_archive_gui()
			   archive_diag()
			EndIf
	  EndIf
   Else
	  MsgBox(0 + 16, "Error", "Fields are empty!")
   EndIf
   $selected_string = ""
EndFunc


Func get_compression_data() ;function to get compression numbers
   Local $initial_size, $compressed_size
   Local $compression_ratio, $compression_factor, $saving_percentage
   Local $dir_size
   If GUICtrlRead($archive_opt) = 1 Then
	  $initial_size = DirGetSize($working_directory) / 1048576
	  $initial_size = Round($initial_size, 2)
	  $compressed_size = (FileGetSize($working_directory & "\" & $archive_name & $archive_type)) / 1048576
	  $compressed_size = Round($compressed_size, 2)
   Else
	  For $x = 0 To UBound($selected_items) - 1
		 $initial_size = $initial_size + (FileGetSize($selected_items[$x]) / 1048576 )
		 $initial_size = Round($initial_size, 2)
	 Next
   $compressed_size = (FileGetSize($working_directory & "\" & $archive_name & $archive_type)) / 1048576
   $compressed_size = Round($compressed_size, 2)
   EndIf

   $compression_ratio = $compressed_size / $initial_size
   $compression_factor = $initial_size / $compressed_size
   $saving_percentage = (($initial_size - $compressed_size) / $initial_size) * 100
   $saving_percentage = Round($saving_percentage, 2)
   ConsoleWrite($compression_ratio)

   MsgBox(0 + 64, "Complete", "Archive Complete" & @CRLF & @CRLF & "Size Before Compression: " & $initial_size & " MB" & @CRLF & "Size after Compression: " & $compressed_size & " MB" & @CRLF & "Saving Percentage: " & $saving_percentage & "%")
EndFunc

















$check_connection =
{
    $connection = adb devices | findstr '\<device\>'
		if ($connection -gt 0)
		{
			echo ''
		}
		else
		{	
			echo 'Unable to connect'
            Read-Host 'Connect device and press any key...'
			&$script
		}
}

$script =
{
	adb disconnect
	adb connect

    &$check_connection

    $pos_id_array = @('0','1','2', '3', '10', '13')

	echo 'Enter pos ID:'
    while ($pos_id -notin $pos_id_array)
    {
        $pos_id = Read-Host "[$pos_id_array]"
    }
           
    $folder = "eyepos_ID_$pos_id"

    Clear-Variable -Name 'pos_id'

    $captures = '/data/data/com.payeye.biopaytestapp.tester/files/captures'
    $files = adb shell ls $captures
    if ($files -gt 0)    
    {
        echo 'Files on device:'
        adb shell ls $captures
        while ($confirm_copy -ne 'y' -and $confirm_copy -ne 'n')
        {
            $confirm_copy = Read-Host 'Copy files? (y / n)'
        }

    
        switch ($confirm_copy)
        {
            'y'
            {
                echo "I am not stuck or freezed, look at your folder: C:\BioTest_2023\$folder. Do not click anything, let me work!"

		        if ( -not (Test-Path -Path C:\BioTest_2023\$folder) )
		        {
    	            New-Item -Type Directory -Path C:\BioTest_2023\$folder
                    adb pull $captures C:\BioTest_2023\$folder
		            echo "Files copied to C:\BioTest_2023\$folder"
		            }
                else 
                {
                    adb pull $captures C:\BioTest_2023\$folder
		            echo "Files copied to C:\BioTest_2023\$folder" 
                }
                Clear-Variable -Name 'confirm_copy'
            }
            'n'
            {
                echo 'Aborted, not copied'
                Clear-Variable -Name 'confirm_copy'
		        #&$script
            }
        }

        Clear-Variable -Name 'files'


        while ($confirm_delete -ne 'y' -and $confirm_delete -ne 'n')
        {
            $confirm_delete = Read-Host 'Delete files? (y / n)'
        }	    

        switch ($confirm_delete)
        {
            'y'
            {
			    adb shell rm -r $captures
			    echo 'Files deleted'
                Clear-Variable -Name 'confirm_delete'
		    }
            'n'
            {
                echo 'Aborted, disconnecting'
                Clear-Variable -Name 'confirm_delete'
		        &$script
            }
        }




    }
    else 
    {
        echo 'Nothing to copy'
        &$script
    }

    Clear-Variable -Name 'files'

  
	Read-Host 'Done, press any key...'
    echo ''
    &$script
}
&$script


param(
    [int]$DaysToStart = 7,
    [int]$DaysToMaximizeWindow = 3,
    [int]$DaysToRemovePostpone = 0,
    [int]$MaxPasswordAge = 90
    )
#Region XAML
[xml]$XAMLsmall = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="MainWindow" Height="360" Width="900"
	WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        BorderBrush="#b81237"
        Background="White"
        BorderThickness="10"
        AllowsTransparency="True"
        >
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="70" />
            <RowDefinition Height="70" />
            <RowDefinition Height="120" />
            <RowDefinition Height="100" />
        </Grid.RowDefinitions>
        <Image
            Grid.Row="0"
            Height="70"
            HorizontalAlignment="Center"
            VerticalAlignment="Center"
            Source="Logo.png"
        />
         <TextBlock Grid.Row="1"
            Name="ExpiredTXT"
            Text="Your Window password wiill expire in 0 days" 
            HorizontalAlignment="Center"
            TextAlignment="Center"
            VerticalAlignment="Bottom"
            TextWrapping="Wrap"
            FontWeight="Bold"
            FontSize="30"
            Margin="10" 
        />
        <TextBlock Grid.Row="2"
            Name="InstructionsTXT"
            Text="Please press Ctrl+Alt+Del on your keyboard and select 'Change a Password'"
            HorizontalAlignment="Center"
            VerticalAlignment="Center"
            TextWrapping="Wrap"
            TextAlignment="Center"
            FontSize="30" 
            Margin="10" 
        />
        <Button
            Grid.Row="3"
            Name="OkayBTN" 
            Content=" Postpone " 
            HorizontalAlignment="Center" 
            Margin="58,0,77,14" 
            VerticalAlignment="Top" 
            BorderThickness="0" 
            FontSize="20"
            />
    </Grid>
</Window>
'@

[xml]$XAMLbig = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Check-Password" Height="118.627" Width="453.431"
        WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        WindowState="Maximized"
        BorderBrush="#b81237"
        Background="White"
        BorderThickness="30"
        AllowsTransparency="True"
        >
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="1*" />
            <RowDefinition Height="1*" />
            <RowDefinition Height="1*" />
            <RowDefinition Height="1*" />
        </Grid.RowDefinitions>
        <Image
            Grid.Row="0"
            Height="200"
            HorizontalAlignment="Center"
            VerticalAlignment="Center"
            Source="Logo.png"
        />
        <TextBlock
			Grid.Row="1"
            Name="ExpiredTXT"
            Text="" 
            HorizontalAlignment="Center"
            TextAlignment="Center"
            VerticalAlignment="Center"
			TextWrapping="Wrap"
			FontWeight="Medium"
            FontSize="80" 
            Margin="10" 
        />
        <TextBlock
	    Grid.Row="2"
            Name="InstructionsTXT"
            Text="Please press Ctrl+Alt+Del on your keyboard and select 'Change a Password'"
            HorizontalAlignment="Center"
            VerticalAlignment="Center"
            TextWrapping="Wrap"
            TextAlignment="Center"
	    FontWeight="Light"
            FontSize="70" 
            Margin="10" 
        />
	    <TextBlock
		    Grid.Row="3"
		    Name="SubTXT"
		    Text="This screen will disappear when you change your password"
		    HorizontalAlignment="Center"
		    VerticalAlignment="Center"
		    TextWrapping="Wrap"
		    TextAlignment="Center"
		    FontSize="60"
		    FontWeight="Light"
		    Margin="10" 
	    />
	    <Button
	        Grid.Row="3"
	        Name="OkayBTN" 
	        Content=" Postpone " 
	        HorizontalAlignment="Center" 
	        Margin="58,0,77,14" 
	        VerticalAlignment="Center" 
	        BorderThickness="0" 
	        FontSize="30"
        />
    </Grid>
</Window>
'@
Function Load-XAML ( $days )
	{
	[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
	#Read XAML
	if ( $days -ge $DaysToMaximizeWindow )
		{
		$XAML = $XAMLsmall
		$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
		try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
		catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
		$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
		$ExpiredTXT.Text = "Your Windows password will expire in $timeleft days."
		$OkayBTN.Visibility = "Visible"
		}
	elseif ( $days -gt $DaysToRemovePostpone )
		{
		$XAML = $XAMLbig
		$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
		try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
		catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
		$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
		$ExpiredTXT.Text = "Your Windows password will expire in $timeleft days."
		$SubTXT.Visibility = "Visible"
		$SubTXT.VerticalAlignment = "Center"
		$OkayBTN.Visibility = "Visible"
		$OkayBTN.VerticalAlignment = "Bottom"
		}
	elseif ( $days -lt $DaysToDisablePostpone )
		{
		$daysleft = $days*-1
		$XAML = $XAMLbig
		$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
		try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
		catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
		$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
		$ExpiredTXT.Text = "Your Windows password has expired."
		$SubTXT.Visibility = "Visible"
		$OkayBTN.Visibility = "Hidden"
		}
	else
		{
		$XAML = $XAMLbig
		$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
		try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
		catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
		$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
		$ExpiredTXT.Text = "Your Windows password expires today!"
		$SubTXT.Visibility = "Visible"
		$OkayBTN.Visibility = "Hidden"
		}
	If ( (Get-WmiObject win32_DesktopMonitor).pixelsperxlogicalinch -gt 96 )
		{
		$ExpiredTXT.FontSize = $ExpiredTXT.FontSize/1.25
		$InstructionsTXT.FontSize = $InstructionsTXT.FontSize/1.25
		$SubTXT.FontSize = $SubTXT.FontSize/1.25
		}
	$OkayBTN.add_Click({$form.Close()})
	$Form.ShowDialog() | out-null
	}
#endregion

#Region CheckIfChanged Scriptblock
$scriptblock =
{	
Function Check-IfChanged
	{
	$username = [Environment]::UserName
	$searcher=New-Object DirectoryServices.DirectorySearcher
	$searcher.Filter="(&(samaccountname=$username))"
	$results=$searcher.findone()
	$lastset = [datetime]::fromfiletime($results.properties.pwdlastset[0])
	$timeleft = $MaxPasswordAge - ( ( Get-Date ) - $lastset ).days
	If ( $timeleft -eq $MaxPasswordAge )
		{
		rundll32.exe user32.dll,LockWorkStation
		Get-Process | ? { $_.mainwindowtitle -eq "Check-Password" } | Stop-Process
		}
	Else
		{
		Sleep -Seconds 3
		Check-IfChanged
		}
	}
Check-IfChanged
}
#endregion

#Region InitialCheck
try
	{
	$username = [Environment]::UserName
	$searcher=New-Object DirectoryServices.DirectorySearcher
	# Only Get Users with Passwords set to Expire
	$searcher.Filter="(&(samaccountname=$username)(!(userAccountControl:1.2.840.113556.1.4.803:=65536)))"
	$results=$searcher.findone()
	$lastset = [datetime]::fromfiletime($results.properties.pwdlastset[0])
	$timeleft = $MaxPasswordAge - ( ( Get-Date ) - $lastset ).days
	}
catch
	{
	exit
	}
#endregion

#region MainFlow
if ( $timeleft -le $DaysToStart )
	{
	Start-Job -ScriptBlock $scriptblock -Name CheckIfChanged
	Load-XAML -Days $timeleft
	}
else
	{
	exit
	}
#endregion

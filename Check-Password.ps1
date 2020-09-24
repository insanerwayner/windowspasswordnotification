<#
.SYNOPSIS

    Check AD user's password expiration status and prompt the user to change if needed.

.DESCRIPTION
    
    Displays a notification window for the user indicating that their password is about to or is expired, if within the defined parameters. It calculates the days remaining by using the date password was last set with the domain password policy's MaxPasswordAge. The window notification gives instructions to user on how to change their password and gives them the choice to wait for the password change and make the window go away. On the last day remaining the choice to postpone will be removed, forcing the user to change the password to remove the window. The window will disappear automatically if it detects the user has changed their password.

.PARAMETER DaysToStart

    The DaysToStart parameter specifies when to fist display the window based on how many days left until their password will expire.  

.PARAMETER DaysToMaximizeWindow
    
    The DaysToMaximizeWindow specifies when to maximize the notification window to fullscreen based on how many days left until their password will expire.

.PARAMETER LockScreenOnPasswordChange

    The LockScreenOnPasswordChange will lock the screen after the user has changed their password, forcing them to re-enter the new password they created.

.NOTES
  
  Author: Wayne Reeves

.EXAMPLE

  Check-Password

  Description: Will run with default values with no parameters specified. The window will not pop up until password expiration is less than or equal to 7 days remaining. The window will not maximize to Fullscreen until less than or equal to 3 days remaining.

 
.EXAMPLE

  Check-Password -DaysToStart 4 -DaysToMaximizeWindow 2

  Description: The window will not pop up until password expiration is less than or equal to 4 days remaining. The window will not maximize to Fullscreen until less than or equal to 2 days remaining.

.EXAMPLE

  Check-Password -DaysToStart 4 -DaysToMaximizeWindow 2 -LockScreenOnPasswordChange

  Description: Same as Example 2, however, once the user has changed their password it will lock their workstation, forcing them to sign back in with their newly created password.

#>

Param(
    [int]$DaysToStart = 7,
    [int]$DaysToMaximizeWindow = 3,
    [switch]$LockScreenOnPasswordChange
    )
[bool]$LockScreenOnPasswordChange = $LockScreenOnPasswordChange.IsPresent
#Region XAML
[xml]$XAMLsmall = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Check-Password" Height="200" Width="800"
	WindowStartupLocation="CenterScreen"
        WindowStyle="None"
        BorderBrush="#b81237"
        Background="White"
        BorderThickness="10"
        AllowsTransparency="True"
        >
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="1*" />
            <RowDefinition Height="1*" />
            <RowDefinition Height="1*" />
        </Grid.RowDefinitions>
        <TextBlock Grid.Row="0"
            Name="ExpiredTXT"
            Text="Your Window password wiill expire in 0 days" 
            HorizontalAlignment="Center"
            TextAlignment="Center"
            VerticalAlignment="Top"
            TextWrapping="Wrap"
            FontWeight="Bold"
            FontSize="30"
            Margin="10" 
        />
        <TextBlock Grid.Row="1"
            Name="InstructionsTXT"
            Text="Press Ctrl+Alt+Del on your keyboard and select 'Change a Password'"
            HorizontalAlignment="Center"
            VerticalAlignment="Top"
            TextWrapping="Wrap"
            TextAlignment="Center"
            FontSize="20" 
            Margin="10" 
        />
        <Button
            Grid.Row="2"
            Name="OkayBTN" 
            Content=" Postpone " 
            HorizontalAlignment="Center" 
            Margin="58,0,77,14" 
            VerticalAlignment="Bottom" 
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
        </Grid.RowDefinitions>
        <TextBlock
	    Grid.Row="0"
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
	    Grid.Row="1"
            Name="InstructionsTXT"
            Text="Press Ctrl+Alt+Del on your keyboard and select 'Change a Password'"
            HorizontalAlignment="Center"
            VerticalAlignment="Center"
            TextWrapping="Wrap"
            TextAlignment="Center"
	    FontWeight="Light"
            FontSize="70" 
            Margin="10" 
        />
	<TextBlock
	    Grid.Row="2"
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
	    Grid.Row="2"
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
Function Load-XAML 
	{
	param(
	    [int]$Days,
	    [int]$Scale
	    )
	$DaysToRemovePostpone = 1
	[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
	#Read XAML
	if ( $days -gt $DaysToMaximizeWindow )
		{
		$Scale = 100
		$XAML = $XAMLsmall
		$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
		try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
		catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
		$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
		$ExpiredTXT.Text = "Your Windows password will expire in $days days."
		$OkayBTN.Visibility = "Visible"
		}
	elseif ( $days -gt $DaysToRemovePostpone )
		{
		$XAML = $XAMLbig
		$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
		try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
		catch{Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}
		$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}
		$ExpiredTXT.Text = "Your Windows password will expire in $days days."
		$SubTXT.Visibility = "Visible"
		$SubTXT.VerticalAlignment = "Center"
		$OkayBTN.Visibility = "Visible"
		$OkayBTN.VerticalAlignment = "Bottom"
		}
	elseif ( $days -lt $DaysToRemovePostpone )
		{
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
		$ExpiredTXT.Text = "Your Windows password expires today."
		$SubTXT.Visibility = "Visible"
		$OkayBTN.Visibility = "Hidden"
		}
	$FontDivide = $Scale/100
	$ExpiredTXT.FontSize = $ExpiredTXT.FontSize/$FontDivide
	$InstructionsTXT.FontSize = $InstructionsTXT.FontSize/$FontDivide
	if ( $SubTXT ) { $SubTXT.FontSize = $SubTXT.FontSize/$FontDivide }
	$OkayBTN.add_Click({$form.Close(); Stop-Job -Name CheckIfChanged})
	$Form.ShowDialog() | out-null
	}
#endregion

# Region GetDPISetting
Function Get-DPISetting
    {
    Add-Type `
@'
    using System;
    using System.Runtime.InteropServices;
    using System.Drawing;

    public class DPI 
	{
	[DllImport("gdi32.dll")]
	static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

	public enum DeviceCap 
	    {
	    VERTRES = 10,
	    DESKTOPVERTRES = 117
	    }

	public static float scaling() 
	    {
	    Graphics g = Graphics.FromHwnd(IntPtr.Zero);
	    IntPtr desktop = g.GetHdc();
	    int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
	    int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);
	    return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
	    }
	}
'@ -ReferencedAssemblies 'System.Drawing.dll'

    $Scale = [Math]::round([DPI]::scaling(), 2) * 100
    return $Scale
    }
#endregion
#Region CheckIfChanged Scriptblock
$InitializationScript =
{	
Function Check-IfChanged
	{
	param(
	    [bool]$LockScreenOnPasswordChange
	    )
	$username = [Environment]::UserName
	$searcher=New-Object DirectoryServices.DirectorySearcher
	$searcher.Filter="(&(samaccountname=$username))"
	$results=$searcher.findone()
	$lastset = [datetime]::fromfiletime($results.properties.pwdlastset[0])
	If ( ( Get-Date $lastset -Format MM/dd/yy ) -eq (Get-Date -Format MM/dd/yy) )
		{
		if ( $LockScreenOnPasswordChange )
		    {
		    rundll32.exe user32.dll,LockWorkStation
		    }
		Get-Process | ? { $_.mainwindowtitle -eq "Check-Password" } | Stop-Process
		}
	Else
		{
		Sleep -Seconds 3
		Check-IfChanged -LockScreenOnPasswordChange $LockScreenOnPasswordChange
		}
	}
}
#endregion

#Region Get Max Password Age
Function Get-PasswordPolicy
    {
    $domainname = $env:userdomain  
    #connect to the $domain 
    [ADSI]$domain = "WinNT://$domainname"
    $PasswordPolicy = $domain | Select @{Name="Name";Expression={$_.name.value}},
    @{Name="PwdHistory";Expression={$_.PasswordHistoryLength.value}},
    @{Name="MinPasswordAge";Expression={New-Timespan -seconds $_.MinPasswordAge.value}},
    @{Name="MaxPasswordAge";Expression={New-Timespan -seconds $_.MaxPasswordAge.value}}
    if ( !$PasswordPolicy -or ( $PasswordPolicy -eq $Null) )
	{
	exit
	}
    else
	{
	return $PasswordPolicy
	}
    }

#Region InitialCheck
try
	{
	$PasswordPolicy = Get-PasswordPolicy
	$MaxPasswordAge = $PasswordPolicy.MaxPasswordAge.Days
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
if ( ( $timeleft -le $DaysToStart ) -and ( $timeleft -ne $null ) -and ( $timeleft -ne "" ) )
	{
	$Scale = Get-DPISetting
	Start-Job -InitializationScript $InitializationScript -ScriptBlock { Check-IfChanged -LockScreenOnPasswordChange $args[0] } -Name CheckIfChanged -ArgumentList $LockScreenOnPasswordChange
	Load-XAML -Days $timeleft -Scale $Scale
	}
else
	{
	exit
	}
#endregion

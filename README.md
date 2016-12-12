# windowspasswordnotification
This is a login script or Unlock Script(Using Scheduled Task), that checks to see if the password is expiring soon and notifies the user. If the user changes the password it will detect the change, clear the window, lock the computer so they have to type in their new password and the password gets committed to Windows cache.

Within 14 to 4 days until password expiration it will have a little popup window with instructions on how to change password, but they also have a "Postpone" button that will close the window.

WIthin 3-1 days until password expiration it will FILL The screen with the instructions on how to change the password. They will still have a "Postpone" button

On the last day or beyond of password expiration it will again fill the screen but they will not be able to get past the screen until they change their password.

If you want to change the branding go to the XAML section change the location of the logo.png file in the script to whatever you like and I have set the Border to a hex red color to match our logo but you can put whatever you like there, even plain text colors like "Blue," "DarkRed," or even "Mint Rose" 
You will need to do this on both $XAMLsmall and $XAMLbig

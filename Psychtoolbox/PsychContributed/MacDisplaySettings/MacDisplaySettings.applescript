(*
MacDisplaySettings.applescript
Denis G. Pelli, denis.pelli@nyu.edu
June 11, 2020.

INTRODUCTION
This applescript run handler allows you read and set seven parameters of
the macOS System Preferences Displays panel: Brightness (slider),
"Automatically adjust brightness" (checkbox), True Tone (checkbox)
(present only on some Macs made in 2018 or later),  Night Shift (pop up
and checkbox), Color Profile (by name or row number), and the "Show
Profiles For This Display Only" checkbox. Apple invites users to use these
parameters to personally customize their experience by enabling dynamic
adjustments of all displayed images in response to personal preference,
ambient lighting, and time of day. Users seem to like that, but those
adjustments could defeat our efforts to calibrate the display one day
and, at a later date, use our calibrations to reliably present an
accurately specified stimulus. MacDisplaySettings aims to satisfy
everyone, by allowing your calibration and test programs to use the
computer in a fixed state, unaffected by user whims, ambient lighting,
and time of day, while saving and restoring whatever custom states the
users have customized it to. MacDisplaySettings reports and controls
these five settings. It allows you to read their current states, set
them to standard values for your critical work, and, when you're done,
restore them to their original values.

I wrote this script to be invoked from MATLAB, but you could call it
from any application running under macOS. To support an external monitor
the caller must provide the global rect of the external screen; that's not
necessary for the main screen.

MacDisplaySettings allows you to temporarily override any macOS user
customization of the display, to allow calibration and user testing with
stable display settings. It allows you to peek and poke seven settings in
the System Preferences:Displays panel by using the corresponding fields
in the oldXXX and newXXX arguments, where XXX is as follows:

  DISPLAY
brightness            the Brightness slider
automatically         the "Automatically adjust brightness" checkbox (true or false)
trueTone              the "True Tone" checkbox (true or false)
  NIGHT SHIFT
nightShiftSchedule    the Night Shift Schedule pop up menu  ('Off','Custom', or 'Sunset to Sunrise')
nightShiftManual      the Night Shift Manual checkbox (true or false)
  COLOR
showProfilesForThisDisplayOnly	the checkbox (true or false)
profile               name of selection in Color Profile menu (text)
profileRow            row # of selection in Color Profile menu (integer)

INPUT ARGS: The screenNumber, if provided, must be an integer of an
available screen, i.e. one of the values returned by Screen('Screens'). If
newProfileRow is specified then newProfile is ignored. True Tone is not
available on Macs manufactured before 2018.

OUTPUT ARGS: The variables oldXXX (where XXX stands for any of the fields
listed above) report the prior state of all available parameters. errorMsg
is the last output argument. If everything worked then errorMsg is an empty
string. Otherwise it will describe one failure, even if there were
several. In peeking, the fields corresponding to parameters that could
not be read will be empty [], and is not flagged as an error. Any omission
in poking is flagged as an error. If you get an error while poking, you
might call MacDisplaySettings again to compare the new peek with what you
poked.


SCREENNUMBER (AND GLOBAL RECT): We endeavor to interpret
screenNumber in the same way as Psychtoolbox Screen does (0 for main
screen, 1 for first external monitor, etc.). To achieve this we
request the global rect of the desired monitor as 4 input
arguments. We anticipate that the rect will be provided by
Screen('GlobalRect',screenNumber). We use this rect to select
whichever window of System Preferences: Displays is on the
desired monitor. This is reliable, provided the user
does not move those windows to different screens.
This applescript code works with whichever Displays
window is currently on the desired monitor. (If there are
several, it will arbitrarily pick one.)

BRIGHTNESS is a slider on the Displays panel, allowing users to easily
adjust the "Brightness" of Apple Macintosh displays.
Setting this parameter is equivalent to manually opening the System
Preference:Displays and adjusting the "brightnes" slider.
The "brightness" setting controls the luminance of the fluorescent light
that is behind the liquid crystal display. I believe that this
"brightness" setting controls only the luminance of the source, and does
not affect the liquid crystal display. The screen luminance is
presumably the product of the two factors: luminance of the source and
transmission of the liquid crystal, at each wavelength.

AUTOMATICALLY is a checkbox on the Displays panel. WHen enabled the
macOS adjusts the display luminance to track ambient lighting. I find
that pleasant as a user, but it's terrible for calibrationg.

TRUE TONE checkbox on the Displays panel.

NIGHT SHIFT panel has a "Schedule" pop-up menu and a "Manual"
checkbox.

DISPLAY PROFILE is a menu of named profiles on the "Color" panel.

Most of these controls don't interact. However,
showProfilesForThisDisplayOnly affects the choices available for
selecting a Profile. When you call MacDisplaySettings with a setting for
showProfilesForThisDisplayOnly, that setting is applied before it peeks
or pokes the Profile selection.

ERROR CHECKING. Most of the controls are straightforward. You are just
peeking and poking a Boolean (0 or 1) or a small integer with a known
range. Brightness and Profile are more subtle, so MacDisplaySettings
always checks by peeking immediately after poking Brightness (float)
or Profile (whether by name or by row). A discrepancy will be flagged
by a string in errorMsg. Note that you provide a float to Brightness
but within the macOS it's quantized to roughly 18-bit precision. The
peek of Brightness is considered erroneous only if it differes by more
than 0.001 from what we poked.

SYSTEM PREFERENCES TAKES 30 S TO OPEN: This script uses the "System
Preferences: Displays" panel, which takes 30 s to launch, if it isn't
already running. We leave it running.

All returned values are [] if your application (e.g. MATLAB) does not
have permission to control your computer (see APPLE SECURITY below).

In MATLAB, you should call MacDisplaySettings.m, which calls this
applescript.:

oldSettings=MacDisplaySettings(screenNumber,newSettings);

To call this applescript directly from MATLAB:

[status, errorMsg, oldBrightness, oldAutomatically, oldTrueTone, ...
	oldNightSchedule, oldNightShiftManual, oldProfileRow, oldProfile] ...
	= ...
	system(['osascript MacDisplaySettings.applescript ' ...
	num2str(screenNumber) ' '...
	num2str(newBrightness) ' ' ...
	num2str(newAutomatically) ' '...
	num2str(newTrueTone) ' '...
	num2str(newNightShiftSchedule) ' ' ...
	num2str(ewNightShiftManual) ' '...
	num2str(newShowProfilesForThisDisplayOnly) ' '...
	num2str(newProfileRow) ' ' ...
	'"' newProfile '"']);

Calling from any other language is very similar. Ignore the returned
"status", which seems to always be zero.

COMPATIBILITY: macOS VERSION: Works on Mavericks, Yosemite, El Capitan,
and Mojave (macOS 10.9 to 10.14). Not yet tested on macOS 10.8 or
earlier, or on Catalina (10.15). INTERNATIONAL: It is designed (but not
yet tested) to work internationally, with macOS localized for any
language, not just English. (For example, that is why we select the
Display/Colors panel by the internal name "displaysDisplayTab" instead
using the localized name "Display".) MULTIPLE SCREENS: All my computers
have only one screen, so I haven't yet tested it with values of
screenNumber other than zero.

FOR SPEED WE LEAVE SYSTEM PREFERENCES OPEN: This script uses the
System Preferences app, which takes 30 s to open, if it isn't already
open, so we leave it open.

APPLE PRIVACY. Unless the application (e.g. MATLAB) has the needed
user-granted permissions to control the computer, attempts by
MacDisplaySettings to change settings will be blocked by the macOS.
The needed permissions include Accessibility, Full Disk Access, and
Automation, all in System Preferences: Security & Privacy: Privacy.
Here are Apple pages on privacy in general, and accessibility in particular:
https://support.apple.com/guide/mac-help/change-privacy-preferences-on-mac-mh32356/mac
https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/mac
New versions of macOS may demand more permissions. In some cases
MacDisplaySettings will detect the missing permission, open the
appropriate Security and Privacy System Preference panel, and provide an
error dialog window asking the user to provide the permission. In other
cases MacDisplaySettings merely prints the macOS error message. The
granting of permission needs to be done only once for your specific
MATLAB app. When you upgrade MATLAB it typically has a new name, and will
be treated as a new app, requiring newly granted permissions. Only
users with administation privileges can grant permission. When you grant
permission, sometimes the macOS doesn't seem to notice right away, and
keeps claiming MATLAB lacks permission. It may help to restart MATLAB or
reboot.

Psychtoolbox Screen.mex. Screen(... 'Brightness'): The Psychtoolbox for
MATLAB and macOS has a Screen call to get and set the brightness.

THANKS to Mario Kleiner for explaining how macOS "brightness" works.
Thanks to nick.peatfield@gmail.com for sharing his applescript code for
dimmer.scpt and brighter.scpt.

SEE ALSO:
Script Debugger app from Late Night Software. https://latenightsw.com/
UI Browser app from UI Browser by PFiddlesoft. https://pfiddlesoft.com/uibrowser/
ScriptingAllowed.applescript (http://psych.nyu.edu/pelli/software.html)
The Psychtoolbox call to get and set the Macintosh brightness:
[oldBrightness]=Screen('ConfigureDisplay','Brightness', ...);
http://www.manpagez.com/man/1/osascript/
https://developer.apple.com/library/mac/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html
https://discussions.apple.com/thread/6418291
https://stackoverflow.com/questions/13415994/how-to-get-the-number-of-items-in-a-pop-up-menu-without-opening-it-using-applesc

HISTORY
May 21, 2015. Wrote AutoBrightness to control the "Automatically adjust
brightness" checkbox of the Displays panel.

May 29, 2015 Enhanced to allow specification of screenNumber.

June 1, 2015. Polished the comments.

July 25, 2015 Previously worked on Mavericks (Mac OS X 10.9). Now
enhanced to also support Yosemite (Mac OS X 10.10.4).

August 3, 2015 Now uses try-blocks to try first group 1 and then group 2
to cope with variations in Apple's macOS. I find that under macOS 10.9
the checkbox is always in group 1. Under macOS 10.10 I have previously
found it in group 2, but now I find it in group 1, so it seems best for
the program to keep trying groups until it finds the checkbox: first 1,
then 2, then give up.

February 29, 2016 Improved the wording of the pop-up screen to spell out
what the user needs to do to allow MATLAB to control the computer.

June 25, 2017. First version of Brightness, based on my
AutoBrightness.applescript

April 9, 2020. Now called MacDisplaySettings.applescript merging code
from Brightness and AutoBrightness, and adding code for True Tone and
Night Shift.

April 14, 2020. Added loops to wait "until exists tab group 1 of window
windowNumber" before accessing it. This change has enormously increased
the reliability. I think the old failures were timeouts, and the wait
loops seem to have almost entirely fixed that.

May 2, 2020. Watching it work, I notice that the operations on the
System Preferences panel are glacially slow while it's in background,
behind MATLAB, but zippy, like a fast human operator, when System
Preferences is foremost. Observing that, I now "activate" System
Preferences at the beginning (and reactivate the former app when we
exit), and this runs much faster. Formerly delays of 60 s were common.
Now it reliably takes 3 s.

May 5, 2020. Return an error message if anything went wrong. The user
will know that everything's ok if the error string is empty. Also apply
the user's setting of newShowProfilesForThisDisplayOnly before peeking
and poking.

May 9, 2020. Improved speed (from 3 to 1.6 s) by replacing fixed delays
in applescript with wait loops. Enhanced the built-in peek of brightness
afer poking. Now if the peek differs by more than 0.001,
MacDisplaySettings waits 100 ms and tries again, to let the value settle,
as the visual effect is a slow fade. Then it reports in errorMsg if the
new peek differs by more than 0.001. In limited testing, waiting for a
good answer works: the peek-poke difference rarely exceeds +/-5e-6 and
never exceeds 0.001. It's my impression that if we always waited 100 ms,
then the discrepancy would always be less than +/-5e-6.

May 15, 2020. MacDisplaySettings.m now also passes a flag indicating
whether Psychtoolbox has a window on the main screen. In that case,
AppleScript will not try to show a dialog. Added a loop in AppleScript
to wait for System Preferences window to open; this fixes a rare error.
Replaced every error code with a message in errorMsg.

May 20, 2020. MacDisplaySettings hung up on my student Benji Luo
with the Night Shift panel showing. I suspect it was in an endless
loop waiting for the menu to pop up after a click. I rewrote the
loop to throw an error if the menu doesn't appear after three attempts
of clicking and waiting up to 500 ms each time.

June 9, 2020. Cosmetic. Improved explanation of APPLE PRIVACY,
*)

on run argv
	-- INPUT ARGUMENTS: screenNumber, screen rect, newBrightness, newAutomatically, newTrueTone,
	-- newNightShiftSchedule, newNightShiftManual,
	-- newShowProfilesForThisDisplayOnly, newProfileRow, newProfile.
	-- OUTPUT ARGUMENTS: olsdBrightness, oldAutomatically, oldTrueTone, oldNightShift,
	-- oldShowProfilesForThisDisplayOnly, oldProfileRow, oldProfile, errorMSG.
	-- integer screenNumber. Zero for main screen. Default is zero.
	--integer 4 values for global rect of desired screen. (Can be -1 -1 -1 -1 for main screen.)
	-- float newBrightness: -1.0 (ignore) or 0.0 to 1.0 value of brightness slider.
	-- integer newAutomatically: -1 (ignore) or 0 or 1 logical value of checkbox.
	-- integer newTrueTone: -1 (ignore) or 0 or 1 logical value of checkbox.
	-- A value of -1 leaves the setting unchanged.
	-- Returns oldBrightness (-1, or 0.0 to 1.0), oldAutomatically (-1, or 0 or 1),
	-- oldTrueTone (-1, or 0 or 1), oldNightShiftSchedule (-1, or 1, 2, or 3),
	-- oldNightShiftManual (-1 or 0 or 1),
	-- oldShowProfilesForThisDisplayOnly (-1, or 0 or 1),
	-- oldProfileRow (-1 or integer), oldProfile (string).
	-- TrueTone only exists on some Macs manufactured 2018 or later. When not
	-- available, oldTrueTone is [].

	tell application "Finder"
		set mainRect to bounds of window of desktop
	end tell

	--GET ARGUMENTS
	set theRect to {-1, -1, -1, -1}
	try
		set screenNumber to item 1 of argv as integer
	on error
		set screenNumber to 0 -- Default is the main screen.
	end try
	try
		set item 1 of theRect to item 2 of argv as integer
	on error
		set item 1 of theRect to item 1 of mainRect -- Default is the main screen.
	end try
	try
		set item 2 of theRect to item 3 of argv as integer
	on error
		set item 2 of theRect to item 2 of mainRect -- Default is the main screen.
	end try
	try
		set item 3 of theRect to item 4 of argv as integer
	on error
		set item 3 of theRect to item 3 of mainRect -- Default is the main screen.
	end try
	try
		set item 4 of theRect to item 5 of argv as integer
	on error
		set item 4 of theRect to item 4 of mainRect -- Default is the main screen.
	end try
	try
		set windowIsOpenOnMainScreen to item 6 of argv as integer
		if windowIsOpenOnMainScreen > 0 then
			set windowIsOpenOnMainScreen to true
		else
			set windowIsOpenOnMainScreen to false
		end if
	on error
		set windowIsOpenOnMainScreen to true
	end try
	try
		set newBrightness to item 7 of argv as real
	on error
		set newBrightness to -1.0 -- Unspecified value, so don't change the setting.
	end try
	try
		set newAutomatically to item 8 of argv as integer
	on error
		set newAutomatically to -1 -- Unspecified value, so don't change the setting.
	end try
	try
		set newTrueTone to item 9 of argv as integer
	on error
		set newTrueTone to -1 -- Unspecified value, so don't change the setting.
	end try
	try
		--To ease passing the Night Shift Schedule menu choice back and forth
		--between MATLAB and AppleScript (and for compatibility with international
		--variations of macOS), we receive and pass just the integer index into
		--the list: {'Off','Custom','Sunset to Sunrise'}. This should work in
		--international (i.e. translated) versions of macOS.
		set newNightShiftSchedule to item 10 of argv as integer
	on error
		set newNightShiftSchedule to -1 -- Unspecified value, so don't change the setting.
	end try
	try
		set newNightShiftManual to item 11 of argv as integer
	on error
		set newNightShiftManual to -1 -- Unspecified value, so don't change the setting.
	end try
	try
		set newShowProfilesForThisDisplayOnly to item 12 of argv as integer
	on error
		set newShowProfilesForThisDisplayOnly to -1 -- Unspecified value, so don't change the setting.
	end try
	try
		set newProfileRow to item 13 of argv as integer
	on error
		set newProfileRow to -1 -- Unspecified value is ignored.
	end try
	try
		set newProfile to item 14 of argv as string
	on error
		set newProfile to -1 -- Unspecified value is ignored.
	end try
	if newProfile as string is equal to "" then
		set newProfile to -1
	end if

	-- CHECK ARGUMENTS
	if newNightShiftSchedule is not in {-1, 1, 2, 3} then
		set errorMsg to "newNightShiftSchedule " & newNightShiftSchedule & " should be one of -1, 1, 2, 3."
		return {oldBrightness, oldAutomatically, ¬
			oldTrueTone, oldNightShiftSchedule, oldNightShiftManual, ¬
			oldShowProfilesForThisDisplayOnly, oldProfileRow, ¬
			"|" & oldProfile & "|", "|" & errorMsg & "|"}
	end if
	set leaveSystemPrefsRunning to true -- This could be made a further argument.
	set versionString to system version of (system info)
	considering numeric strings
		set isMojaveOrBetter to versionString ≥ "10.14.0"
		set isNightShiftAvailable to versionString ≥ "10.12.4"
	end considering
	-- Default values. The value -1 means don't modify this setting.
	set oldBrightness to -1.0
	set oldAutomatically to -1
	set oldTrueTone to -1
	set oldProfile to ""
	set oldProfileRow to -1
	set oldShowProfilesForThisDisplayOnly to -1
	set oldNightShiftSchedule to -1
	set oldNightShiftManual to -1
	set errorMsg to ""

	-- The "ok" flags help track what failed. We return an error message if
	-- any failed (that shouldn't).
	set trueToneOk to false
	set groupOk to false
	set brightnessOk to false
	set profileOk to false
	set manualOk to false
	set scheduleOk to false

	-- GET NAME OF CURRENT APP.
	-- Save name of current active application (probably MATLAB) to
	-- restore at end as the frontmost. Apparently this
	-- works reliably only if saved "as text".
	--https://stackoverflow.com/questions/44017508/set-application-to-frontmost-in-applescript
	--https://stackoverflow.com/questions/13097426/activating-an-application-in-applescript-with-the-application-as-a-variable
	set currentApp to path to frontmost application as text

	--ACTIVATE SYSTEM PREFERENCES APP
	tell application "System Preferences"
		activate -- Bring it to the front, which makes the rest MUCH faster.
		-- This is the international way to get to the desired pane of Displays,
		-- immune to language localizations.
		set current pane to pane id "com.apple.preference.displays"
		set wasRunning to running
		reveal anchor "displaysDisplayTab" of pane id "com.apple.preference.displays"
	end tell

	-- FIND THE SYSTEM PREFS WINDOWS ON THE DESIRED SCREEN.
	-- theRect is received as an argument. In MATLAB theRect=Screen('GlobalRect',screen).
	-- Formerly we always referred to "window windowNumber" but windowNumber changes
	-- if a window is brought forward. The frontmost window always has number 1. So now
	-- we refer to theWindow which is stable, even after we bring the window to the front.
	-- We know a window is on the desired screen by checking whether its x y position
	-- is inside the global rect of the desired screen, which is received as an
	-- argument when MacDisplayScreen.applescript is called. (If the global rect is not
	-- provided, the default is the rect of the main screen, which we compute above.)
	set theWindow to -1
	set mainWindow to -1
	if screenNumber is equal to 0 then
		set theRect to mainRect
	end if
	--set theRect to {1000, 0, 3600, 1000} -- for debugging
	tell application "System Events"
		tell application process "System Preferences"
			repeat until exists window 1
				delay 0.05
			end repeat
			repeat with w from 1 to (count windows)
				set winPos to position of window w
				set x to item 1 of winPos
				set y to item 2 of winPos
				if (x ≥ item 1 of theRect and x ≤ item 3 of theRect and ¬
					y ≥ item 2 of theRect and y ≤ item 4 of theRect) then
					set theWindow to window w
				end if
				-- We never use the variable "mainWindow", but it's cheap to
				-- find it, and it's handy to have when debugging.
				if (x ≥ item 1 of mainRect and x ≤ item 3 of mainRect and ¬
					y ≥ item 2 of mainRect and y ≤ item 4 of mainRect) then
					set mainWindow to window w
				end if
			end repeat
		end tell
	end tell
	if theWindow is equal to -1 then
		set AppleScript's text item delimiters to space
		set theString to theRect as string
		set AppleScript's text item delimiters to ""
		set errorMsg to "Could not find System Preferences window on screenNumber " & screenNumber & " with rect [" & theString & "]."
		activate application currentApp -- Restore active application.
		--delay 0.1 -- May not be needed.
		return {oldBrightness, oldAutomatically, ¬
			oldTrueTone, oldNightShiftSchedule, oldNightShiftManual, ¬
			oldShowProfilesForThisDisplayOnly, oldProfileRow, ¬
			"|" & oldProfile & "|", "|" & errorMsg & "|"}
	end if

	-- PERMISSION CHECK, TRUE TONE, BRIGHTNESS & AUTOMATIC,
	tell application "System Events"

		-- CHECK FOR PERMISSION
		set applicationName to item 1 of (get name of processes whose frontmost is true)
		if not UI elements enabled then
			tell application "System Preferences"
				activate
				reveal anchor "Privacy_Accessibility" of pane id "com.apple.preference.security"
				if windowIsOpenOnMainScreen then
					-- Psychtoolbox has a window open that might obscure
					-- our dialog window. So we return instead and let
					-- MacDisplaySettings close all windows.
					set errorMsg to "To set Displays preferences, " & applicationName & ¬
						" needs your permission to control this computer. " & ¬
						"Please unlock System Preferences: Security & Privacy: " & ¬
						"Privacy and click the boxes to grant " & applicationName & " permission for Full Disk Access and Automation. "
					return {oldBrightness, oldAutomatically, ¬
						oldTrueTone, oldNightShiftSchedule, oldNightShiftManual, ¬
						oldShowProfilesForThisDisplayOnly, oldProfileRow, ¬
						"|" & oldProfile & "|", "|" & errorMsg & "|"}
				end if
				display alert "To set Displays preferences, " & applicationName & ¬
					" needs your permission to control this computer. " & ¬
					"BEFORE you click OK below, please unlock System Preferences: Security & Privacy: " & ¬
					"Privacy and click the boxes to grant permission for Full Disk Access and Automation. " & ¬
					"THEN click OK."
			end tell
			return {oldBrightness, oldAutomatically, ¬
				oldTrueTone, oldNightShiftSchedule, oldNightShiftManual, ¬
				oldShowProfilesForThisDisplayOnly, oldProfileRow, ¬
				"|" & oldProfile & "|", "|" & errorMsg & "|"}
		end if

		--DISPLAY PANEL
		-- TRUE TONE, BRIGHTNESS & AUTOMATIC
		set screenNumber to 1
		tell process "System Preferences"
			repeat 10 times
				if exists theWindow then exit repeat
				delay 0.05
			end repeat
			if not (exists theWindow) then
				set errorMsg to "screenNumber " & screenNumber & " is not available."
				activate application currentApp -- Restore active application.
				--delay 0.1
				return {oldBrightness, oldAutomatically, ¬
					oldTrueTone, oldNightShiftSchedule, oldNightShiftManual, ¬
					oldShowProfilesForThisDisplayOnly, oldProfileRow, ¬
					"|" & oldProfile & "|", "|" & errorMsg & "|"}
			end if

			repeat until exists tab group 1 of theWindow
				delay 0.05
			end repeat
			tell tab group 1 of theWindow

				-- TRUE TONE
				set trueToneOk to false
				try
					tell checkbox 1
						set oldTrueTone to value
						if newTrueTone is in {0, 1} and newTrueTone is not oldTrueTone then
							click -- It's stale, so update it.
						end if
					end tell
					--Succeeded with True Tone.
					set trueToneOk to true
				on error
					-- Don't report True Tone error.
					-- Just return oldTrueTone=-1.
					set trueToneOk to false
				end try

				-- BRIGHTNESS & AUTOMATIC
				repeat with iGroup from 1 to 2
					-- Find the right group
					-- 1 works on macOS 10.9 and 10.14, and some versions of 10.10.
					-- 2 works on macOS 10.11 through 10.13, and some versions of 10.10.
					try
						tell group iGroup
							set oldBrightness to slider 1's value -- Get brightness
						end tell
						set groupOk to true
						set theGroup to iGroup
						exit repeat
					on error errorMessage
						set groupOk to false
					end try
				end repeat
				if groupOk is false then
					set errorMsg to "Could not find valid group for brightness."
				else
					try
						tell group theGroup

							-- BRIGHTNESS
							set brightnessOk to false
							set oldBrightness to slider 1's value -- Get brightness
							if newBrightness > -1 then
								set slider 1's value to newBrightness -- Set brightness
								-- Check the poke by peeking.
								-- We can't demand equality (of peek and poke)  because
								-- macOS uses only about 18-bit precision internally.
								--Visually, moving the slider causes a slow
								--fade. (Maybe that's why they gave it such high precision.)
								--It's possible that the value we
								--read similarly takes time to reach the
								--requested setting. So when we read a bad
								--value (different by at least 0.001 from the newBrightness we poked)
								--then we wait a bit and try again. After 2000
								--poke-peek pairs with random brightnesses (0.0 to 1.0),
								--only 5 immediate peeks differed by at least 0.01, and only 11 differed
								-- by at least 0.0001. The rest were within
								--+/- 5e-6 of the value poked. (The outliers were all
								--brighter than desired, suggesting that dimming is
								--slower than brightening.) In limited testing, this delay
								--seems to have eliminated the outliers, so the peek-poke
								--difference never exceeds +/- 5e-6. Given
								--that the brightness always settles to the desired value
								--perhaps the extra peek is superfluous. I'm leaving it in
								--because MacDisplaySettings is slow anyway, due to applescript,
								--so the extra up to 200 ms of the peek seems good insurance
								--for detecting unanticipated problems in particular Macs,
								--or different versions of the macOS.

								set b to slider 1's value -- Get brightness
								set bErr to (b - newBrightness)
								--is the peek bad?
								if bErr > 1.0E-3 or bErr < -1.0E-3 then
									-- yep, it's bad. Wait and peek again.
									delay 0.1
									set b to slider 1's value -- Get brightness
									set bErr to (b - newBrightness)
									if bErr > 1.0E-3 or bErr < -1.0E-3 then
										error "Poked Brightness " & newBrightness & " but peeked " & b & "."
									end if
								end if
							end if
							--Succeeded with Brightness.

							-- AUTOMATICALLY
							tell checkbox 1 -- Enable/disable Automatically adjust brightness
								set oldAutomatically to value
								if newAutomatically is in {0, 1} and ¬
									newAutomatically is not oldAutomatically then
									click -- It's stale, so update it.
								end if
							end tell -- checkbox 1
							--Succeeded with Automatically.

						end tell -- group iGroup
						--Succeeded with Brightness and Automatically.
						set brightnessOk to true
					on error errorMessage
						set errorMsg to errorMessage
						set brightnessOk to false
					end try
				end if

			end tell
		end tell
	end tell

	-- This block of code selects the right window (a System Preferences window on
	-- the desired screen) and selects the Color pane within it.
	tell application "System Events"
		tell process "System Preferences"
			tell theWindow
				select
				perform action "AXRaise" of theWindow
				tell tab group 1
					tell radio button 2
						--This click selects color.
						click
					end tell
				end tell
			end tell
		end tell
	end tell

	-- COLOR PANEL
	tell application "System Events"
		tell process "System Preferences"
			repeat until exists tab group 1 of theWindow
				delay 0.05
			end repeat
			tell tab group 1 of theWindow
				-- Show all profiles.
				try
					repeat until exists checkbox 1
						delay 0.05
					end repeat
					tell checkbox 1 -- Yes/no: Show profiles for this display only.
						set oldShowProfilesForThisDisplayOnly to value
						if newShowProfilesForThisDisplayOnly is not equal to -1 then
							-- Set new value.
							if newShowProfilesForThisDisplayOnly is not equal to oldShowProfilesForThisDisplayOnly ¬
								then
								click
							end if
						end if
					end tell -- checkbox 1
					-- Read selection and select new Display Profile
					repeat until exists row 1 of table 1 of scroll area 1
						delay 0.05
					end repeat
					tell table 1 of scroll area 1
						set oldProfile to value of static text 1 of ¬
							(row 1 where selected is true)
						repeat with profileRow from 1 to 101
							if selected of row profileRow then exit repeat
						end repeat
						set oldProfileRow to profileRow
						if oldProfileRow is 101 then
							set oldProfileRow to -1
							error "Could not select Profile by row."
						end if
						if newProfileRow is not equal to -1 then
							--newProfileRow specifies Profile row.
							if selected of row newProfileRow is true then
								-- If the desired row is already selected
								-- then we first select and activate another row,
								-- and then reselect and activate the one we want.
								-- This makes sure that a fresh copy of the profile
								-- is loaded from disk.
								if newProfileRow is equal to 1 then
									select last row
								else
									select row 1
								end if
								activate
								click
							end if
							select row newProfileRow
							activate
							click
							if selected of row newProfileRow is false then
								error "Could not set Profile row."
							end if
						else
							--newProfile specifies Profile name.
							if newProfile is not equal to -1 then
								try
									if selected of ¬
										(row 1 where value of static text 1 is newProfile) then
										if oldProfileRow is equal to 1 then
											select last row
										else
											select row 1
										end if
										activate
									end if
									select (row 1 where value of static text 1 is newProfile)
									activate
									click
								on error
									error "Could not select Profile '" & newProfile & "' by name."
								end try
								if newProfile is not equal to value ¬
									of static text 1 of (row 1 where selected is true) then
									error "Could not select Profile '" & newProfile & "' by name."
								end if
							end if
						end if
					end tell
					set profileOk to true
				on error errorMessage number errorNumber
					set profileOk to false
					set errorMsg to errorMessage
				end try
			end tell
		end tell
	end tell

	-- NIGHT SHIFT PANEL
	tell application "System Preferences"
		reveal anchor "displaysNightShiftTab" of pane id "com.apple.preference.displays"
	end tell
	tell application "System Events"
		tell process "System Preferences"
			repeat until exists tab group 1 of theWindow
				delay 0.05
			end repeat
			tell tab group 1 of theWindow

				-- NIGHT SHIFT MANUAL
				try
					tell checkbox 1 -- Enable/disable Night Shift Manual
						set oldNightShiftManual to value
						--display alert "4 Read!"
						if newNightShiftManual is in {0, 1} and ¬
							newNightShiftManual is not oldNightShiftManual then
							click -- It's stale, so update it.
							--display alert "5 Wrote!"
						end if
					end tell
					--Succeeded with Night Shift Manual.
					set manualOk to true
				on error
					set manualOk to false
				end try

				-- NIGHT SHIFT SCHEDULE
				try
					repeat until exists pop up button 1
						delay 0.05
					end repeat
					tell pop up button 1 -- Select Night Shift Schedule
						-- We get the selection value, i.e. text which may
						-- be in foreign language.
						set theLabel to value
						-- Then we find it in the pop up menu and keep its index.
						-- The nested repeat loops are my attempt to
						-- eliminate a hang that I think was due to waiting
						-- forever, after a click, for the menu to appear.
						-- When I manually click a pop-up menu the menu appears
						-- and remains forever. But after the applescript "click"
						-- command, the menu appears only briefly.
						-- My hypothesis is that perhaps the menu came and went
						-- before my loop started waiting for it to appear. The new
						-- code waits for up to 500 ms, and then tries again
						-- (up to twice more) to click and wait. If, after three tries,
						-- the menu still hasn't appeared, then we fail with an
						-- applescript error, so i'll get some diagnostic information.
						repeat 3 times
							click -- reveal pop up menu
							repeat 10 times
								if exists menu 1 then exit repeat
								delay 0.05
							end repeat
							if exists menu 1 then exit repeat
						end repeat
						repeat with i from 1 to 3
							set x to name of menu item i of menu 1
							if theLabel is x then
								set oldNightShiftSchedule to i
								exit repeat
							end if
						end repeat
						--Hit escape key to hide the menu.
						key code 53
						if newNightShiftSchedule > 0 then
							repeat 3 times
								click -- reveal pop up menu
								repeat 10 times
									if exists menu 1 then exit repeat
									delay 0.05
								end repeat
								if exists menu 1 then exit repeat
							end repeat
							click menu item newNightShiftSchedule of menu 1
						end if
					end tell
					--Succeeded with Night Shift Schedule.
					set scheduleOk to true
				on error
					set scheduleOk to false
				end try

			end tell
		end tell
	end tell

	--SHOW MAIN DISPLAYS PANEL AS WE LEAVE
	tell application "System Preferences"
		reveal anchor "displaysDisplayTab" of pane id "com.apple.preference.displays"
	end tell

	if wasRunning or leaveSystemPrefsRunning then
		-- Leave it running.
	else
		quit application "System Preferences"
	end if

	if errorMsg as string is equal to "" then
		if not profileOk then set errorMsg to "Could not peek/poke Profile selection."
		if isNightShiftAvailable then
			if not manualOk then set errorMsg to "Could not peek/poke Night Shift manual."
			if not scheduleOk then set errorMsg to "Could not peek/poke Night Shift schedule."
		end if
		-- Many computers don't support True Tone, so we don't flag this as an error.
		-- It's enough that the field is left empty.
		--if not trueToneOk then set errorMsg to "Could not peek/poke True Tone."
		if not brightnessOk then set errorMsg to "Could not peek/poke Brightness and Automatically."
	end if

	-- RESTORE FRONTMOST APPLICATION (PROBABLY MATLAB).
	activate application currentApp -- Restore active application.
	--delay 0.1 --Not sure if we need this at all.

	return {oldBrightness, oldAutomatically, ¬
		oldTrueTone, oldNightShiftSchedule, oldNightShiftManual, ¬
		oldShowProfilesForThisDisplayOnly, oldProfileRow, ¬
		"|" & oldProfile & "|", "|" & errorMsg & "|"}
end run

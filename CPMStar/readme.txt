CPMStar Flash Advertising Preplay Integration Kit

Instructions for Actionscript 3 (Flash 9+):

1) Create a 300x250 movieclip symbol within your library.
2) Drag the symbol into your loader where you want the ad to show and give it an instance name 'adBox'.
3) Copy the as3/CPMStar subdirectory into the directory where your fla resides. (If your fla is in C:\test\my.fla, place it in C:\test\CPMStar)
4) Copy the the actionscript code from frame 1 of the example file as3/adloadas3.fla into your loader.
5) Replace the CPMStarContentSpotID variable value with the content spot id assigned to you by CPMStar.
6) Placing a call to removeChild("adBox") at the apropriate time in your loader will terminate the ad display and restore the framerate

Note: In Actionscript 3 your swf's framerate will temporarily switch to match the advertisement while the ad shows.


CPMStarContentSpotID variable is: 2404QBCF1B64B